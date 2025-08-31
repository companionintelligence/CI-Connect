import 'package:api_client/src/firebase_extensions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';

/// {@template api_client}
/// A Very Good Project created by Very Good CLI.
/// {@endtemplate}
class ApiClient {
  /// Creates an instance of [ApiClient].
  ApiClient({
    required FirebaseFirestore firestore,
    String? ciServerBaseUrl,
    Dio? httpClient,
  })  : _firestore = firestore,
        _ciServerBaseUrl = ciServerBaseUrl ?? 'https://api.companion-intelligence.com',
        _dio = httpClient ?? Dio();

  final FirebaseFirestore _firestore;
  final String _ciServerBaseUrl;
  final Dio _dio;

  /// Generates a new firestore document ID.
  String generateId() => _firestore.generateId();

  /// Checks if CI Server is reachable.
  Future<bool> isConnectedToCiServer() async {
    try {
      final response = await _dio.get(
        '$_ciServerBaseUrl/health',
        options: Options(
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Gets CI Server status information.
  Future<Map<String, dynamic>?> getCiServerStatus() async {
    try {
      final response = await _dio.get(
        '$_ciServerBaseUrl/api/status',
        options: Options(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Sends data to CI Server.
  Future<bool> sendDataToCiServer(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        '$_ciServerBaseUrl/api/data',
        data: data,
        options: Options(
          contentType: Headers.jsonContentType,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }
}
