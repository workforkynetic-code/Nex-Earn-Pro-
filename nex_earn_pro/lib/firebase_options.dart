// File: lib/firebase_options.dart
// Kaam: Firebase ko initialize karne ke liye config provide karta hai
// Yahan tumhara Firebase project ka saara config store hota hai

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
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
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Web config (for testing in browser)
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAo8iVfFMaxY7vnA2NjD5mop5DqAuGY8yU',
    authDomain: 'nex-earn-pro-d89be.firebaseapp.com',
    databaseURL: 'https://nex-earn-pro-d89be-default-rtdb.firebaseio.com',
    projectId: 'nex-earn-pro-d89be',
    storageBucket: 'nex-earn-pro-d89be.firebasestorage.app',
    messagingSenderId: '830525311885',
    appId: '1:830525311885:web:60290bdbce45ef5bd50bc4',
  );

  // Android config
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAo8iVfFMaxY7vnA2NjD5mop5DqAuGY8yU',
    appId: '1:830525311885:android:YOUR_ANDROID_APP_ID', // Replace after adding Android app in Firebase Console
    messagingSenderId: '830525311885',
    projectId: 'nex-earn-pro-d89be',
    databaseURL: 'https://nex-earn-pro-d89be-default-rtdb.firebaseio.com',
    storageBucket: 'nex-earn-pro-d89be.firebasestorage.app',
  );
}
