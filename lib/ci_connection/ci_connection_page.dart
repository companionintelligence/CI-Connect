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
    _apiClient = ApiClient();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    setState(() {
      _isLoading = true;
      _lastMessage = 'Checking CI Server connection...';
    });

    try {
      // Test connection by trying to get people
      final people = await _apiClient.getPeople(limit: 1);

      setState(() {
        _isConnected = true;
        _serverStatus = {
          'people_count': people.length,
          'base_url': _apiClient.ciServerBaseUrl,
        };
        _isLoading = false;
        _lastMessage = 'Connected to CI Server successfully!';
      });
    } on Exception catch (e) {
      setState(() {
        _isConnected = false;
        _serverStatus = null;
        _isLoading = false;
        _lastMessage = 'Failed to connect to CI Server: $e';
      });
    }
  }

  Future<void> _sendTestData() async {
    setState(() {
      _isLoading = true;
      _lastMessage = 'Sending test data to CI Server...';
    });

    try {
      // Create a test person to send to the server
      final testPerson = Person(
        id: _apiClient.generateId(),
        name: 'Test User',
        email: 'test@example.com',
      );

      final createdPerson = await _apiClient.createPerson(testPerson);

      setState(() {
        _isLoading = false;
        _lastMessage =
            'Test data sent successfully! '
            'Created person: ${createdPerson.name}';
      });
    } on Exception catch (e) {
      setState(() {
        _isLoading = false;
        _lastMessage = 'Error sending data: $e';
      });
    }
  }

  Future<void> _testApiEndpoints() async {
    setState(() {
      _isLoading = true;
      _lastMessage = 'Testing CI Server API endpoints...';
    });

    try {
      final messages = <String>[];

      // Test People API
      final people = await _apiClient.getPeople(limit: 3);
      messages.add('People API: Success (${people.length} items)');

      // Test Places API
      final places = await _apiClient.getPlaces(limit: 3);
      messages.add('Places API: Success (${places.length} items)');

      // Test Content API
      final content = await _apiClient.getContent(limit: 3);
      messages.add('Content API: Success (${content.length} items)');

      // Test Contact API
      final contacts = await _apiClient.getContacts(limit: 3);
      messages.add('Contact API: Success (${contacts.length} items)');

      // Test Things API
      final things = await _apiClient.getThings(limit: 3);
      messages.add('Things API: Success (${things.length} items)');

      setState(() {
        _isLoading = false;
        _lastMessage = messages.join('\n');
      });
    } on Exception catch (e) {
      setState(() {
        _isLoading = false;
        _lastMessage = 'Error testing endpoints: $e';
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _isLoading || !_isConnected ? null : _testApiEndpoints,
              icon: const Icon(Icons.api),
              label: const Text('Test API Endpoints'),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
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
                      SelectableText(
                        _lastMessage,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
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
