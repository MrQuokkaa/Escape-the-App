import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions have only been configured for Web.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyBDm9x0eUriD07bWf0gckOtWKN85u5pBvQ",
    authDomain: "escape-the-app-78043.firebaseapp.com",
    projectId: "escape-the-app-78043",
    storageBucket: "escape-the-app-78043.firebasestorage.app",
    messagingSenderId: "479207241883",
    appId: "1:479207241883:web:f7c1419c336b2052286e3e",
    measurementId: "G-8N8NMB2J20",
  );
}