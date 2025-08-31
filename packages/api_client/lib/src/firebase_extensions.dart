import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

extension FirebaseFirestoreX on FirebaseFirestore {
  String generateId() => collection('_').doc().id;

  CollectionReference<Map<String, dynamic>> usersCollection() =>
      collection('users');
  DocumentReference<Map<String, dynamic>> userDoc(String uid) =>
      usersCollection().doc(uid);

  CollectionReference<Map<String, dynamic>> studiosCollection() =>
      collection('studios');
  DocumentReference<Map<String, dynamic>> studioDoc(String studioId) =>
      studiosCollection().doc(studioId);

  CollectionReference<Map<String, dynamic>> studioListingsCollection(
    String studioId,
  ) =>
      studioDoc(studioId).collection('listings');
  DocumentReference<Map<String, dynamic>> studioListingDoc({
    required String studioId,
    required String listingId,
  }) =>
      studioListingsCollection(studioId).doc(listingId);

  CollectionReference<Map<String, dynamic>> studioChargesCollection(
    String studioId,
  ) =>
      studioDoc(studioId).collection('charges');
  DocumentReference<Map<String, dynamic>> studioChargeDoc({
    required String studioId,
    required String chargeId,
  }) =>
      studioChargesCollection(studioId).doc(chargeId);

  CollectionReference<Map<String, dynamic>> studioInvoicesCollection(
    String studioId,
  ) =>
      studioDoc(studioId).collection('invoices');
  DocumentReference<Map<String, dynamic>> studioInvoiceDoc({
    required String studioId,
    required String invoiceId,
  }) =>
      studioInvoicesCollection(studioId).doc(invoiceId);

  CollectionReference<Map<String, dynamic>> studioPromotionsCollection(
    String studioId,
  ) =>
      studioDoc(studioId).collection('promotions');
  DocumentReference<Map<String, dynamic>> studioPromotionDoc({
    required String studioId,
    required String promotionId,
  }) =>
      studioPromotionsCollection(studioId).doc(promotionId);

  CollectionReference<Map<String, dynamic>> studioEmailTemplatesCollection(
    String studioId,
  ) =>
      studioDoc(studioId).collection('email-templates');
  DocumentReference<Map<String, dynamic>> studioEmailTemplateDoc({
    required String studioId,
    required String emailTemplateId,
  }) =>
      studioEmailTemplatesCollection(studioId).doc(emailTemplateId);

  Query<Map<String, dynamic>> listingsCollectionGroup() =>
      collectionGroup('listings');

  CollectionReference<Map<String, dynamic>> bookingsCollection({
    required String studioId,
    required String listingId,
  }) =>
      studioListingDoc(studioId: studioId, listingId: listingId)
          .collection('bookings');
  DocumentReference<Map<String, dynamic>> bookingDoc({
    required String studioId,
    required String listingId,
    required String bookingId,
  }) =>
      bookingsCollection(studioId: studioId, listingId: listingId)
          .doc(bookingId);

  CollectionReference<Map<String, dynamic>> contactsCollection({
    required String studioId,
  }) =>
      studioDoc(studioId).collection('contacts');
  DocumentReference<Map<String, dynamic>> contactDoc({
    required String studioId,
    required String contactId,
  }) =>
      contactsCollection(studioId: studioId).doc(contactId);

  CollectionReference<Map<String, dynamic>> promotionsCollection(
    String studioId,
  ) =>
      studioDoc(studioId).collection('promotions');
  DocumentReference<Map<String, dynamic>> promotionDoc({
    required String studioId,
    required String promotionId,
  }) =>
      promotionsCollection(studioId).doc(promotionId);

  CollectionReference<Map<String, dynamic>> notificationsCollection({
    required String studioId,
  }) =>
      studioDoc(studioId).collection('notifications');
  DocumentReference<Map<String, dynamic>> notificationDoc({
    required String studioId,
    required String notificationId,
  }) =>
      notificationsCollection(studioId: studioId).doc(notificationId);

  Query<Map<String, dynamic>> notificationsCollectionGroup() =>
      collectionGroup('notifications');

  Query<Map<String, dynamic>> bookingSessionsCollectionGroup() =>
      collectionGroup('sessions');
  CollectionReference<Map<String, dynamic>> bookingSessionsCollection({
    required String studioId,
    required String listingId,
    required String bookingId,
  }) =>
      bookingDoc(studioId: studioId, listingId: listingId, bookingId: bookingId)
          .collection('sessions');
  DocumentReference<Map<String, dynamic>> bookingSessionDoc({
    required String studioId,
    required String listingId,
    required String bookingId,
    required String bookingSessionId,
  }) =>
      bookingSessionsCollection(
        studioId: studioId,
        listingId: listingId,
        bookingId: bookingId,
      ).doc(bookingSessionId);
}

extension FirebaseStorageX on FirebaseStorage {
  Reference studiosRef() => ref('studios');
  Reference studioRef(String studioId) => studiosRef().child(studioId);

  Reference listingsRef(String studioId) =>
      studioRef(studioId).child('listings');
  Reference listingRef({
    required String studioId,
    required String listingId,
  }) =>
      listingsRef(studioId).child(listingId);
  Reference listingPhotosRef({
    required String studioId,
    required String listingId,
  }) =>
      listingRef(studioId: studioId, listingId: listingId).child('photos');
  Reference listingPhotoRef({
    required String studioId,
    required String listingId,
    required String photoName,
  }) =>
      listingPhotosRef(studioId: studioId, listingId: listingId)
          .child(photoName);

  Reference placeholdersRef() => ref('placeholders');
  Reference studioLogoPlaceholderRef() =>
      placeholdersRef().child('studio_logo_placeholder.jpg');
}
