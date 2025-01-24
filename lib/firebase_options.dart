// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBTttRhf8FsPtGuSgLhf4eJbZ7A3mQJnnY',
    appId: '1:600162565967:android:17d3a244b076a5b471cf3a',
    messagingSenderId: '600162565967',
    projectId: 'aplikasiari-ad345',
    storageBucket: 'aplikasiari-ad345.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA8dyRQkn1csWxAwTKqipeNnTDOH4dOOL0',
    appId: '1:600162565967:ios:a3a2ea1370b87b1371cf3a',
    messagingSenderId: '600162565967',
    projectId: 'aplikasiari-ad345',
    storageBucket: 'aplikasiari-ad345.firebasestorage.app',
    iosBundleId: 'com.example.projectari1',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC_dGWWvcUOdPc-tAPquiW9barMcVkbNJA',
    appId: '1:600162565967:web:c6ca991d96c0112771cf3a',
    messagingSenderId: '600162565967',
    projectId: 'aplikasiari-ad345',
    authDomain: 'aplikasiari-ad345.firebaseapp.com',
    storageBucket: 'aplikasiari-ad345.firebasestorage.app',
    measurementId: 'G-4274KLYBLV',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC_dGWWvcUOdPc-tAPquiW9barMcVkbNJA',
    appId: '1:600162565967:web:2db58bc810439d4a71cf3a',
    messagingSenderId: '600162565967',
    projectId: 'aplikasiari-ad345',
    authDomain: 'aplikasiari-ad345.firebaseapp.com',
    storageBucket: 'aplikasiari-ad345.firebasestorage.app',
    measurementId: 'G-YJBZE987QB',
  );

}