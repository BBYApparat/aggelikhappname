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
    apiKey: 'your-web-api-key',
    appId: '1:123456789:web:abc123',
    messagingSenderId: '123456789',
    projectId: 'realnow-project',
    authDomain: 'realnow-project.firebaseapp.com',
    storageBucket: 'realnow-project.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'your-android-api-key',
    appId: '1:123456789:android:abc123',
    messagingSenderId: '123456789',
    projectId: 'realnow-project',
    storageBucket: 'realnow-project.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'your-ios-api-key',
    appId: '1:123456789:ios:abc123',
    messagingSenderId: '123456789',
    projectId: 'realnow-project',
    storageBucket: 'realnow-project.appspot.com',
    iosBundleId: 'com.realnow.realnow',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'your-ios-api-key',
    appId: '1:123456789:ios:abc123',
    messagingSenderId: '123456789',
    projectId: 'realnow-project',
    storageBucket: 'realnow-project.appspot.com',
    iosBundleId: 'com.realnow.realnow',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'your-web-api-key',
    appId: '1:123456789:web:abc123',
    messagingSenderId: '123456789',
    projectId: 'realnow-project',
    authDomain: 'realnow-project.firebaseapp.com',
    storageBucket: 'realnow-project.appspot.com',
  );
}