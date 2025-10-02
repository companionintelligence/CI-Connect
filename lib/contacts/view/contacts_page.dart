import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:api_client/api_client.dart';
import 'package:companion_connect/app/bloc/app_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

import '../bloc/contacts_bloc.dart';
import '../bloc/contacts_event.dart';
import '../bloc/contacts_state.dart';
import '../models/contact.dart' as contact_models;

class ContactsPage extends StatelessWidget {
  const ContactsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ContactsBloc(
        apiClient: context.read<ApiClient>(),
        appBloc: context.read<AppBloc>(),
      ),
      child: const _ContactsPageContent(),
    );
  }
}

class _ContactsPageContent extends StatelessWidget {
  const _ContactsPageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<ContactsBloc, ContactsState>(
        builder: (context, state) {
          if (state is ContactsInitial) {
            return _buildInitialView(context);
          } else if (state is ContactsLoading) {
            return _buildLoadingView();
          } else if (state is ContactsPermissionDenied) {
            return _buildPermissionDeniedView(context);
          } else if (state is ContactsLoaded) {
            return _buildContactsLoadedView(context, state);
          } else if (state is ContactsError) {
            return _buildErrorView(context, state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildInitialView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.contacts,
              size: 80,
              color: Colors.blue[600],
            ),
            const SizedBox(height: 24),
            const Text(
              'Upload Your Contacts',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'We\'ll help you upload your contacts in batches of 50 to keep your data organized.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ContactsBloc>().add(
                  const RequestContactsPermission(),
                );
              },
              icon: const Icon(Icons.upload),
              label: const Text('Request Permission & Load Contacts'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading contacts...'),
        ],
      ),
    );
  }

  Widget _buildPermissionDeniedView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.block,
              size: 80,
              color: Colors.red[600],
            ),
            const SizedBox(height: 24),
            const Text(
              'Permission Denied',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'We need access to your contacts to upload them. Please grant permission in your device settings.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ContactsBloc>().add(
                  const RequestContactsPermission(),
                );
              },
              icon: const Icon(Icons.settings),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () async {
                await openAppSettings();
              },
              icon: const Icon(Icons.settings_applications),
              label: const Text('Open App Settings'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactsLoadedView(BuildContext context, ContactsLoaded state) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with stats
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.contacts, color: Colors.blue[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Contacts Loaded',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        'Total',
                        '${state.totalContacts}',
                        Icons.people,
                      ),
                      _buildStatCard(
                        'Batches',
                        '${state.totalBatches}',
                        Icons.layers,
                      ),
                      _buildStatCard(
                        'Uploaded',
                        '${state.uploadedBatches}',
                        Icons.cloud_upload,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Upload progress
          if (state.isUploading) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(width: 16),
                        Text(
                          'Uploading batch ${state.uploadedBatches + 1} of ${state.totalBatches}...',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: state.totalBatches > 0
                          ? state.uploadedBatches / state.totalBatches
                          : 0,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: state.isUploading
                      ? null
                      : () {
                          context.read<ContactsBloc>().add(
                            const UploadContacts(),
                          );
                        },
                  icon: const Icon(Icons.cloud_upload),
                  label: Text(
                    state.isUploading ? 'Uploading...' : 'Upload All Contacts',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.read<ContactsBloc>().add(const LoadContacts());
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Contacts preview
          Expanded(
            child: Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.list, color: Colors.blue[600]),
                        const SizedBox(width: 8),
                        Text(
                          'Contacts Preview (${state.contacts.length})',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.contacts.length,
                      itemBuilder: (context, index) {
                        final contact = state.contacts[index];
                        return _buildContactTile(contact);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue[600]),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildContactTile(contact_models.Contact contact) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue[100],
        child: Text(
          (contact.displayName?.isNotEmpty == true ||
                  contact.givenName?.isNotEmpty == true)
              ? ((contact.displayName ?? contact.givenName ?? '?')[0])
                    .toUpperCase()
              : '?',
          style: TextStyle(
            color: Colors.blue[600],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        contact.displayName ??
            '${contact.givenName ?? ''} ${contact.familyName ?? ''}'.trim(),
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (contact.company?.isNotEmpty == true)
            Text('Company: ${contact.company}'),
          if (contact.phones.isNotEmpty)
            Text('Phone: ${contact.phones.first.value ?? ''}'),
          if (contact.emails.isNotEmpty)
            Text('Email: ${contact.emails.first.value ?? ''}'),
        ],
      ),
      isThreeLine: true,
    );
  }

  Widget _buildErrorView(BuildContext context, ContactsError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[600],
            ),
            const SizedBox(height: 24),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<ContactsBloc>().add(const RetryUpload());
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    context.read<ContactsBloc>().add(const LoadContacts());
                  },
                  icon: const Icon(Icons.contacts),
                  label: const Text('Load Contacts'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
