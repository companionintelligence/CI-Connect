import 'package:flutter/material.dart';
import 'package:api_client/api_client.dart';

/// {@template ios_import_page}
/// Page for importing iOS backup data to CI-Server
/// {@endtemplate}
class IOSImportPage extends StatefulWidget {
  /// {@macro ios_import_page}
  const IOSImportPage({
    required this.ciServerClient,
    required this.studioId,
    super.key,
  });

  /// CI-Server client for API calls
  final CIServerClient ciServerClient;
  
  /// Studio ID for imports
  final String studioId;

  @override
  State<IOSImportPage> createState() => _IOSImportPageState();
}

class _IOSImportPageState extends State<IOSImportPage> {
  late IOSImportService _importService;
  List<IOSBackupInfo>? _availableBackups;
  IOSBackupInfo? _selectedBackup;
  IOSImportProgress? _currentProgress;
  IOSImportSummary? _lastImportSummary;
  bool _isDiscovering = false;
  bool _isImporting = false;

  // Import options
  bool _importContacts = true;
  bool _importContactsAsPersons = false;
  bool _importMessages = true;
  bool _importMedia = true;
  bool _importPlaces = true;

  @override
  void initState() {
    super.initState();
    _importService = IOSImportService(
      ciServerClient: widget.ciServerClient,
      studioId: widget.studioId,
    );
    _importService.progressStream.listen(_onProgressUpdate);
    _discoverBackups();
  }

  @override
  void dispose() {
    _importService.dispose();
    super.dispose();
  }

  void _onProgressUpdate(IOSImportProgress progress) {
    if (mounted) {
      setState(() {
        _currentProgress = progress;
        
        if (progress.stage == IOSImportStage.completed) {
          _isImporting = false;
        } else if (progress.stage == IOSImportStage.error) {
          _isImporting = false;
        }
      });
    }
  }

  Future<void> _discoverBackups() async {
    setState(() {
      _isDiscovering = true;
    });

    try {
      final backups = await _importService.discoverBackups();
      setState(() {
        _availableBackups = backups;
        _isDiscovering = false;
      });
    } catch (e) {
      setState(() {
        _isDiscovering = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to discover backups: $e')),
        );
      }
    }
  }

  Future<void> _startImport() async {
    if (_selectedBackup == null) return;

    setState(() {
      _isImporting = true;
      _lastImportSummary = null;
    });

    try {
      final options = IOSImportOptions(
        importContacts: _importContacts,
        importContactsAsPersons: _importContactsAsPersons,
        importMessages: _importMessages,
        importMedia: _importMedia,
        importPlaces: _importPlaces,
      );

      final summary = await _importService.importFromBackup(
        _selectedBackup!,
        options: options,
      );

      setState(() {
        _lastImportSummary = summary;
        _isImporting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Import completed successfully!')),
        );
      }
    } catch (e) {
      setState(() {
        _isImporting = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('iOS Import'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isDiscovering ? null : _discoverBackups,
            tooltip: 'Refresh backups',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Backup selection section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select iOS Backup',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    if (_isDiscovering)
                      const Center(child: CircularProgressIndicator())
                    else if (_availableBackups?.isEmpty ?? true)
                      const Text('No iOS backups found on this system.')
                    else ...[
                      for (final backup in _availableBackups!)
                        RadioListTile<IOSBackupInfo>(
                          title: Text(backup.deviceName),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Last backup: ${backup.lastBackupDate}'),
                              if (backup.isEncrypted)
                                const Text(
                                  'Encrypted backup',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                          value: backup,
                          groupValue: _selectedBackup,
                          onChanged: _isImporting ? null : (value) {
                            setState(() {
                              _selectedBackup = value;
                            });
                          },
                        ),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Import options section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Import Options',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: const Text('Import Contacts'),
                      value: _importContacts,
                      onChanged: _isImporting ? null : (value) {
                        setState(() {
                          _importContacts = value ?? false;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Also import Contacts as People'),
                      value: _importContactsAsPersons,
                      onChanged: _isImporting || !_importContacts ? null : (value) {
                        setState(() {
                          _importContactsAsPersons = value ?? false;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Import Messages'),
                      value: _importMessages,
                      onChanged: _isImporting ? null : (value) {
                        setState(() {
                          _importMessages = value ?? false;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Import Media'),
                      value: _importMedia,
                      onChanged: _isImporting ? null : (value) {
                        setState(() {
                          _importMedia = value ?? false;
                        });
                      },
                    ),
                    CheckboxListTile(
                      title: const Text('Import Places from Addresses'),
                      value: _importPlaces,
                      onChanged: _isImporting ? null : (value) {
                        setState(() {
                          _importPlaces = value ?? false;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Import progress section
            if (_currentProgress != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Import Progress',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Text(_currentProgress!.toString()),
                      if (_currentProgress!.percentage != null) ...[
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: _currentProgress!.percentage! / 100,
                        ),
                      ] else if (_isImporting) ...[
                        const SizedBox(height: 8),
                        const LinearProgressIndicator(),
                      ],
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Import summary section
            if (_lastImportSummary != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Last Import Summary',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Text('Contacts imported: ${_lastImportSummary!.contactsImported}'),
                      if (_lastImportSummary!.personsImported > 0)
                        Text('Persons imported: ${_lastImportSummary!.personsImported}'),
                      Text('Messages imported: ${_lastImportSummary!.messagesImported}'),
                      Text('Media imported: ${_lastImportSummary!.mediaImported}'),
                      Text('Places imported: ${_lastImportSummary!.placesImported}'),
                      Text('Import duration: ${_lastImportSummary!.importDuration}'),
                    ],
                  ),
                ),
              ),
            
            const Spacer(),
            
            // Start import button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedBackup != null && !_isImporting
                    ? _startImport
                    : null,
                child: _isImporting 
                    ? const Text('Importing...')
                    : const Text('Start Import'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}