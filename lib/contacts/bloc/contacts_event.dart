import 'package:equatable/equatable.dart';

abstract class ContactsEvent extends Equatable {
  const ContactsEvent();

  @override
  List<Object?> get props => [];
}

class LoadContacts extends ContactsEvent {
  const LoadContacts();
}

class RequestContactsPermission extends ContactsEvent {
  const RequestContactsPermission();
}

class UploadContacts extends ContactsEvent {
  const UploadContacts();
}

class RetryUpload extends ContactsEvent {
  const RetryUpload();
}
