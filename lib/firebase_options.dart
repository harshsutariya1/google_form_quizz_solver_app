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
        return macos;
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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAw531VRa8-wL8tJD0rSZUIt5qeaAO0PD8',
    appId: '1:845343583382:web:ab6df0e1ebbe932549a6b7',
    messagingSenderId: '845343583382',
    projectId: 'quiz-solver-app-2f15e',
    authDomain: 'quiz-solver-app-2f15e.firebaseapp.com',
    storageBucket: 'quiz-solver-app-2f15e.firebasestorage.app',
    measurementId: 'G-6VKBV4Z77H',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD0m-UgD-_V94irMZNcK8xrnmsWrM9wyig',
    appId: '1:845343583382:android:bbc710b666f3840b49a6b7',
    messagingSenderId: '845343583382',
    projectId: 'quiz-solver-app-2f15e',
    storageBucket: 'quiz-solver-app-2f15e.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyALe-f81n0HEN31jXo6vRvoDbM1cQupc5s',
    appId: '1:845343583382:ios:a9fdc88428fb7bb749a6b7',
    messagingSenderId: '845343583382',
    projectId: 'quiz-solver-app-2f15e',
    storageBucket: 'quiz-solver-app-2f15e.firebasestorage.app',
    iosBundleId: 'com.example.quizzApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyALe-f81n0HEN31jXo6vRvoDbM1cQupc5s',
    appId: '1:845343583382:ios:a9fdc88428fb7bb749a6b7',
    messagingSenderId: '845343583382',
    projectId: 'quiz-solver-app-2f15e',
    storageBucket: 'quiz-solver-app-2f15e.firebasestorage.app',
    iosBundleId: 'com.example.quizzApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAw531VRa8-wL8tJD0rSZUIt5qeaAO0PD8',
    appId: '1:845343583382:web:1ca1ee0d18bbce6d49a6b7',
    messagingSenderId: '845343583382',
    projectId: 'quiz-solver-app-2f15e',
    authDomain: 'quiz-solver-app-2f15e.firebaseapp.com',
    storageBucket: 'quiz-solver-app-2f15e.firebasestorage.app',
    measurementId: 'G-DHYMFEFYF9',
  );
}