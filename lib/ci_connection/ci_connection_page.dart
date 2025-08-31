import 'package:api_client/api_client.dart';
import 'package:flutter/material.dart';

/// {@template ci_connection_page}
/// A page that demonstrates CI Server connectivity functionality.
/// {@endtemplate}
class CiConnectionPage extends StatefulWidget {
  /// {@macro ci_connection_page}
  const CiConnectionPage({super.key});

  @override
  State<CiConnectionPage> createState() => _CiConnectionPageState();
}

class _CiConnectionPageState extends State<CiConnectionPage> {
  late final ApiClient _apiClient;
  bool _isConnected = false;
  Map<String, dynamic>? _serverStatus;
  bool _isLoading = false;
  String _lastMessage = '';

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient(
      firestore: FirebaseFirestore.instance,
    );
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    setState(() {
      _isLoading = true;
      _lastMessage = 'Checking CI Server connection...';
    });

    try {
      final connected = await _apiClient.isConnectedToCiServer();
      Map<String, dynamic>? status;
      
      if (connected) {
        status = await _apiClient.getCiServerStatus();
      }

      setState(() {
        _isConnected = connected;
        _serverStatus = status;
        _isLoading = false;
        _lastMessage = connected 
          ? 'Connected to CI Server successfully!' 
          : 'Failed to connect to CI Server';
      });
    } catch (e) {
      setState(() {
        _isConnected = false;
        _serverStatus = null;
        _isLoading = false;
        _lastMessage = 'Error: $e';
      });
    }
  }

  Future<void> _sendTestData() async {
    setState(() {
      _isLoading = true;
      _lastMessage = 'Sending test data to CI Server...';
    });

    try {
      final testData = {
        'action': 'test_connection',
        'timestamp': DateTime.now().toIso8601String(),
        'client_version': '1.0.0',
      };

      final success = await _apiClient.sendDataToCiServer(testData);

      setState(() {
        _isLoading = false;
        _lastMessage = success 
          ? 'Test data sent successfully!' 
          : 'Failed to send test data';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _lastMessage = 'Error sending data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CI Server Connection'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isConnected ? Icons.check_circle : Icons.error,
                          color: _isConnected ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Connection Status',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isConnected ? 'Connected' : 'Disconnected',
                      style: TextStyle(
                        color: _isConnected ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_serverStatus != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Server Info:',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 4),
                      ...(_serverStatus!.entries.map(
                        (entry) => Text('${entry.key}: ${entry.value}'),
                      )),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _checkConnection,
              icon: const Icon(Icons.refresh),
              label: const Text('Check Connection'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _isLoading || !_isConnected ? null : _sendTestData,
              icon: const Icon(Icons.send),
              label: const Text('Send Test Data'),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last Message:',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    if (_isLoading)
                      const Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Loading...'),
                        ],
                      )
                    else
                      Text(_lastMessage),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}