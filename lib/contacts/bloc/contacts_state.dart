import 'package:equatable/equatable.dart';
import '../models/contact.dart' as contact_models;

abstract class ContactsState extends Equatable {
  const ContactsState();

  @override
  List<Object?> get props => [];
}

class ContactsInitial extends ContactsState {
  const ContactsInitial();
}

class ContactsLoading extends ContactsState {
  const ContactsLoading();
}

class ContactsPermissionDenied extends ContactsState {
  const ContactsPermissionDenied();
}

class ContactsLoaded extends ContactsState {
  final List<contact_models.Contact> contacts;
  final int totalContacts;
  final int uploadedBatches;
  final int totalBatches;
  final bool isUploading;

  const ContactsLoaded({
    required this.contacts,
    required this.totalContacts,
    required this.uploadedBatches,
    required this.totalBatches,
    this.isUploading = false,
  });

  @override
  List<Object?> get props => [
    contacts,
    totalContacts,
    uploadedBatches,
    totalBatches,
    isUploading,
  ];

  ContactsLoaded copyWith({
    List<contact_models.Contact>? contacts,
    int? totalContacts,
    int? uploadedBatches,
    int? totalBatches,
    bool? isUploading,
  }) {
    return ContactsLoaded(
      contacts: contacts ?? this.contacts,
      totalContacts: totalContacts ?? this.totalContacts,
      uploadedBatches: uploadedBatches ?? this.uploadedBatches,
      totalBatches: totalBatches ?? this.totalBatches,
      isUploading: isUploading ?? this.isUploading,
    );
  }
}

class ContactsError extends ContactsState {
  final String message;

  const ContactsError({required this.message});

  @override
  List<Object?> get props => [message];
}
