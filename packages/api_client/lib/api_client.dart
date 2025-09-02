/// A Very Good Project created by Very Good CLI.
library;

export 'package:cloud_firestore/cloud_firestore.dart';
export 'package:cloud_functions/cloud_functions.dart';
export 'package:dio/dio.dart';
export 'package:firebase_analytics/firebase_analytics.dart';
export 'package:firebase_auth/firebase_auth.dart' hide User;
export 'package:firebase_core/firebase_core.dart';
export 'package:firebase_crashlytics/firebase_crashlytics.dart';
export 'package:firebase_storage/firebase_storage.dart';
export 'package:google_sign_in/google_sign_in.dart';
export 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';

// Platform-specific Google Sign-In packages
export 'package:google_sign_in_ios/google_sign_in_ios.dart'
    if (dart.library.io) 'package:google_sign_in_ios/google_sign_in_ios.dart';
export 'package:google_sign_in_android/google_sign_in_android.dart'
    if (dart.library.io) 'package:google_sign_in_android/google_sign_in_android.dart';

export 'src/api_client.dart';
export 'src/notification_service.dart';
