import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:api_client/api_client.dart' as api_client;
import 'package:companion_connect/app/bloc/app_bloc.dart';

import 'contacts_event.dart';
import 'contacts_state.dart';
import '../models/contact.dart' as contact_models;

class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  final api_client.ApiClient _apiClient;
  final AppBloc _appBloc;

  ContactsBloc({
    required api_client.ApiClient apiClient,
    required AppBloc appBloc,
  }) : _apiClient = apiClient,
       _appBloc = appBloc,
       super(const ContactsInitial()) {
    on<RequestContactsPermission>(_onRequestContactsPermission);
    on<LoadContacts>(_onLoadContacts);
    on<UploadContacts>(_onUploadContacts);
    on<RetryUpload>(_onRetryUpload);
  }

  Future<void> _onRequestContactsPermission(
    RequestContactsPermission event,
    Emitter<ContactsState> emit,
  ) async {
    try {
      print('ContactsBloc: Requesting contacts permission...');

      // Check current permission status first
      final status = await Permission.contacts.status;

      if (status.isGranted) {
        print('ContactsBloc: Permission already granted, loading contacts...');
        add(const LoadContacts());
        return;
      }

      if (status.isPermanentlyDenied) {
        print('ContactsBloc: Permission permanently denied');
        emit(const ContactsPermissionDenied());
        return;
      }

      // Request permission
      final permission = await Permission.contacts.request();

      if (permission.isGranted) {
        print('ContactsBloc: Permission granted, loading contacts...');
        add(const LoadContacts());
      } else if (permission.isPermanentlyDenied) {
        print('ContactsBloc: Permission permanently denied');
        emit(const ContactsPermissionDenied());
      } else {
        print('ContactsBloc: Permission denied');
        emit(const ContactsPermissionDenied());
      }
    } catch (e) {
      print('ContactsBloc: Error requesting permission: $e');
      emit(ContactsError(message: 'Failed to request contacts permission: $e'));
    }
  }

  Future<void> _onLoadContacts(
    LoadContacts event,
    Emitter<ContactsState> emit,
  ) async {
    try {
      print('ContactsBloc: Loading contacts...');
      emit(const ContactsLoading());

      final contacts = await ContactsService.getContacts();
      print('ContactsBloc: Loaded ${contacts.length} contacts');

      // Convert to our Contact model
      final contactList = contacts
          .map((contact) => _convertToContact(contact))
          .toList();

      // Calculate batches (50 contacts per batch)
      final totalBatches = (contactList.length / 50).ceil();

      emit(
        ContactsLoaded(
          contacts: contactList,
          totalContacts: contactList.length,
          uploadedBatches: 0,
          totalBatches: totalBatches,
        ),
      );
    } catch (e) {
      print('ContactsBloc: Error loading contacts: $e');
      emit(ContactsError(message: 'Failed to load contacts: $e'));
    }
  }

  Future<void> _onUploadContacts(
    UploadContacts event,
    Emitter<ContactsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ContactsLoaded) return;

    try {
      print('ContactsBloc: Starting contacts upload...');
      emit(currentState.copyWith(isUploading: true));

      final appState = _appBloc.state;
      if (appState is! AppAuthenticated) {
        emit(const ContactsError(message: 'User not authenticated'));
        return;
      }
      final accessToken = appState.session.accessToken;
      if (accessToken == null) {
        emit(const ContactsError(message: 'No access token available'));
        return;
      }

      final batches = _createBatches(currentState.contacts, 50);
      int uploadedBatches = 0;

      for (int i = 0; i < batches.length; i++) {
        final batch = batches[i];
        print(
          'ContactsBloc: Uploading batch ${i + 1}/${batches.length} with ${batch.length} contacts',
        );

        try {
          await _uploadBatch(batch, accessToken);
          uploadedBatches++;

          emit(
            currentState.copyWith(
              uploadedBatches: uploadedBatches,
              isUploading:
                  i < batches.length - 1, // Still uploading if not last batch
            ),
          );

          print('ContactsBloc: Successfully uploaded batch ${i + 1}');
        } catch (e) {
          print('ContactsBloc: Error uploading batch ${i + 1}: $e');
          emit(ContactsError(message: 'Failed to upload batch ${i + 1}: $e'));
          return;
        }
      }

      print('ContactsBloc: All batches uploaded successfully');
      emit(
        currentState.copyWith(
          uploadedBatches: uploadedBatches,
          isUploading: false,
        ),
      );
    } catch (e) {
      print('ContactsBloc: Error during upload: $e');
      emit(ContactsError(message: 'Failed to upload contacts: $e'));
    }
  }

  Future<void> _onRetryUpload(
    RetryUpload event,
    Emitter<ContactsState> emit,
  ) async {
    add(const UploadContacts());
  }

  contact_models.Contact _convertToContact(Contact contact) {
    return contact_models.Contact(
      id: contact.identifier,
      displayName: contact.displayName,
      givenName: contact.givenName,
      familyName: contact.familyName,
      middleName: contact.middleName,
      prefix: contact.prefix,
      suffix: contact.suffix,
      company: contact.company,
      jobTitle: contact.jobTitle,
      emails:
          contact.emails
              ?.map(
                (email) => contact_models.ContactEmail(
                  label: email.label,
                  value: email.value,
                  type: null, // contacts_service doesn't have type field
                ),
              )
              .toList() ??
          [],
      phones:
          contact.phones
              ?.map(
                (phone) => contact_models.ContactPhone(
                  label: phone.label,
                  value: phone.value,
                  type: null, // contacts_service doesn't have type field
                ),
              )
              .toList() ??
          [],
      addresses:
          contact.postalAddresses
              ?.map(
                (address) => contact_models.ContactAddress(
                  label: address.label,
                  street: address.street,
                  city: address.city,
                  region: address.region,
                  postcode: address.postcode,
                  country: address.country,
                  type: null, // contacts_service doesn't have type field
                ),
              )
              .toList() ??
          [],
      websites: [], // contacts_service doesn't have websites
      socialMedia: [], // contacts_service doesn't have socialProfiles
      notes: null, // contacts_service doesn't have note field
      birthday: contact.birthday?.toIso8601String(),
      avatar: null, // contacts_service avatar is Uint8List, not String
    );
  }

  List<List<contact_models.Contact>> _createBatches(
    List<contact_models.Contact> contacts,
    int batchSize,
  ) {
    final batches = <List<contact_models.Contact>>[];
    for (int i = 0; i < contacts.length; i += batchSize) {
      final end = (i + batchSize < contacts.length)
          ? i + batchSize
          : contacts.length;
      batches.add(contacts.sublist(i, end));
    }
    return batches;
  }

  Future<void> _uploadBatch(
    List<contact_models.Contact> batch,
    String accessToken,
  ) async {
    final dio = Dio();

    // Convert contacts to JSON
    final contactsJson = batch.map((contact) => contact.toJson()).toList();

    print('ContactsBloc: Uploading batch with ${contactsJson.length} contacts');
    print(
      'ContactsBloc: Sample contact data: ${contactsJson.isNotEmpty ? contactsJson.first : 'No contacts'}',
    );

    // Debug: Check for any null values that might cause issues
    for (int i = 0; i < contactsJson.length; i++) {
      final contact = contactsJson[i];
      print('ContactsBloc: Contact $i keys: ${contact.keys.toList()}');

      // Check for null values in required fields
      if (contact['id'] == null) {
        print('ContactsBloc: WARNING - Contact $i has null id');
      }
      if (contact['displayName'] == null) {
        print('ContactsBloc: WARNING - Contact $i has null displayName');
      }
    }

    // Validate JSON structure
    try {
      final jsonString = jsonEncode(contactsJson);
      print(
        'ContactsBloc: JSON validation successful, length: ${jsonString.length}',
      );
    } catch (e) {
      print('ContactsBloc: JSON validation failed: $e');
      throw Exception('Invalid JSON structure: $e');
    }

    print('ContactsBloc: Full contacts JSON: $contactsJson');

    // Try different request formats to see what the server expects
    dynamic requestData;
    Response response;

    // Format 1: Content field (based on database schema)
    requestData = {
      'content': contactsJson,
    };

    print('ContactsBloc: Trying format 1 - Content field: $requestData');

    try {
      response = await dio.post(
        '${_apiClient.ciServerBaseUrl}/etl/contacts',
        data: requestData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );
    } catch (e) {
      print('ContactsBloc: Format 1 failed: $e');

      // Format 2: Direct array
      requestData = contactsJson;
      print('ContactsBloc: Trying format 2 - Direct array: $requestData');

      try {
        response = await dio.post(
          '${_apiClient.ciServerBaseUrl}/etl/contacts',
          data: requestData,
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json',
            },
          ),
        );
      } catch (e2) {
        print('ContactsBloc: Format 2 failed: $e2');

        // Format 3: Contacts field
        requestData = {
          'contacts': contactsJson,
        };
        print('ContactsBloc: Trying format 3 - Contacts field: $requestData');

        response = await dio.post(
          '${_apiClient.ciServerBaseUrl}/etl/contacts',
          data: requestData,
          options: Options(
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json',
            },
          ),
        );
      }
    }

    if (response.statusCode != 200 && response.statusCode != 201) {
      print('ContactsBloc: Upload failed with status: ${response.statusCode}');
      print('ContactsBloc: Response data: ${response.data}');
      print('ContactsBloc: Response headers: ${response.headers}');
      print('ContactsBloc: Request URL: ${response.requestOptions.uri}');
      print(
        'ContactsBloc: Request headers: ${response.requestOptions.headers}',
      );
      print('ContactsBloc: Request data: ${response.requestOptions.data}');
      throw Exception(
        'Upload failed with status: ${response.statusCode} - ${response.data}',
      );
    }

    print('ContactsBloc: Successfully uploaded batch');
  }
}
