import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError('Unsupported platform');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
  apiKey: "AIzaSyDRn4Sj2PejoGkM9JNLnD-apR2WlSy7Ueo",
  appId: "1:110078252087:web:8dea76d784c170ba919bb2",
  messagingSenderId: "110078252087",
  projectId: "cosvoria-36f86",
  );

  static const FirebaseOptions android = FirebaseOptions(
  apiKey: "AIzaSyDRn4Sj2PejoGkM9JNLnD-apR2WlSy7Ueo",
  appId: "1:110078252087:web:8dea76d784c170ba919bb2",
  messagingSenderId: "110078252087",
  projectId: "cosvoria-36f86",
  );
}