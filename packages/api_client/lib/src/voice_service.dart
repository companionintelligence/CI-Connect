import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// {@template voice_service}
/// Service for handling voice and audio functionality with CI-Server backend.
/// {@endtemplate}
class VoiceService {
  /// Creates an instance of [VoiceService].
  VoiceService({
    required Dio dio,
    required FirebaseStorage storage,
    String? ciServerUrl,
  })  : _dio = dio,
        _storage = storage,
        _ciServerUrl = ciServerUrl ?? 'wss://ci-server.companionintelligence.com';

  final Dio _dio;
  final FirebaseStorage _storage;
  final String _ciServerUrl;
  
  final SpeechToText _speechToText = SpeechToText();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  WebSocketChannel? _wsChannel;
  StreamSubscription<dynamic>? _wsSubscription;
  
  // Stream controllers for voice data
  final _voiceCommandController = StreamController<String>.broadcast();
  final _audioDataController = StreamController<Uint8List>.broadcast();
  final _connectionStatusController = StreamController<bool>.broadcast();

  /// Stream of recognized voice commands
  Stream<String> get voiceCommands => _voiceCommandController.stream;
  
  /// Stream of audio data for real-time processing
  Stream<Uint8List> get audioData => _audioDataController.stream;
  
  /// Stream of connection status with CI-Server
  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  /// Initialize voice service and request permissions
  Future<bool> initialize() async {
    try {
      // Request microphone permissions
      final micPermission = await Permission.microphone.request();
      if (!micPermission.isGranted) {
        throw Exception('Microphone permission not granted');
      }

      // Initialize speech to text
      final speechAvailable = await _speechToText.initialize(
        onError: (error) => _voiceCommandController.addError(error),
        onStatus: (status) {
          // Handle speech recognition status changes
        },
      );

      if (!speechAvailable) {
        throw Exception('Speech recognition not available');
      }

      return true;
    } catch (e) {
      _voiceCommandController.addError(e);
      return false;
    }
  }

  /// Connect to CI-Server WebSocket for real-time voice communication
  Future<void> connectToServer() async {
    try {
      _wsChannel = WebSocketChannel.connect(Uri.parse(_ciServerUrl));
      
      _wsSubscription = _wsChannel!.stream.listen(
        (data) {
          // Handle incoming voice data from server
          if (data is List<int>) {
            _audioDataController.add(Uint8List.fromList(data));
          } else if (data is String) {
            // Handle text responses or commands
            _voiceCommandController.add(data);
          }
        },
        onError: (error) {
          _connectionStatusController.add(false);
          _voiceCommandController.addError(error);
        },
        onDone: () {
          _connectionStatusController.add(false);
        },
      );

      _connectionStatusController.add(true);
    } catch (e) {
      _connectionStatusController.add(false);
      throw Exception('Failed to connect to CI-Server: $e');
    }
  }

  /// Disconnect from CI-Server
  Future<void> disconnect() async {
    await _wsSubscription?.cancel();
    await _wsChannel?.sink.close();
    _connectionStatusController.add(false);
  }

  /// Start listening for voice commands
  Future<void> startListening() async {
    if (!_speechToText.isAvailable) {
      throw Exception('Speech recognition not available');
    }

    await _speechToText.listen(
      onResult: (result) {
        if (result.finalResult) {
          final command = result.recognizedWords;
          _voiceCommandController.add(command);
          
          // Send voice command to CI-Server
          _wsChannel?.sink.add(command);
        }
      },
      listenMode: ListenMode.confirmation,
      cancelOnError: false,
      partialResults: true,
      onDevice: false,
    );
  }

  /// Stop listening for voice commands
  Future<void> stopListening() async {
    await _speechToText.stop();
  }

  /// Send audio data to CI-Server for processing
  Future<void> sendAudioData(Uint8List audioData) async {
    if (_wsChannel != null) {
      _wsChannel!.sink.add(audioData);
    }
  }

  /// Play audio response from CI-Server
  Future<void> playAudioResponse(Uint8List audioData) async {
    try {
      // Create temporary file for audio playback
      final tempDir = Directory.systemTemp;
      final audioFile = File('${tempDir.path}/response_${DateTime.now().millisecondsSinceEpoch}.wav');
      await audioFile.writeAsBytes(audioData);

      // Play the audio file
      await _audioPlayer.setFilePath(audioFile.path);
      await _audioPlayer.play();

      // Clean up temporary file after playback
      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          audioFile.deleteSync();
        }
      });
    } catch (e) {
      throw Exception('Failed to play audio response: $e');
    }
  }

  /// Upload audio file to Firebase Storage
  Future<String> uploadAudioFile(File audioFile, String fileName) async {
    try {
      final ref = _storage.ref('audio/$fileName');
      final uploadTask = ref.putFile(audioFile);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload audio file: $e');
    }
  }

  /// Download audio file from Firebase Storage
  Future<Uint8List> downloadAudioFile(String downloadUrl) async {
    try {
      final response = await _dio.get<List<int>>(
        downloadUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      return Uint8List.fromList(response.data!);
    } catch (e) {
      throw Exception('Failed to download audio file: $e');
    }
  }

  /// Get available voice locales
  List<LocaleName> getAvailableLocales() {
    return _speechToText.locales;
  }

  /// Set voice recognition locale
  Future<void> setLocale(String localeId) async {
    // Store locale preference for next listening session
  }

  /// Dispose of resources
  void dispose() {
    _wsSubscription?.cancel();
    _wsChannel?.sink.close();
    _audioPlayer.dispose();
    _voiceCommandController.close();
    _audioDataController.close();
    _connectionStatusController.close();
  }
}