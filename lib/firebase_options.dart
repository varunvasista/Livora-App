// File generated for Livora project.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyB2ey94Y5vj1SOhp7VqCP9cfObGAfMB0Lk',
    appId: '1:531362834016:web:610064c5dfcb033321c505',
    messagingSenderId: '531362834016',
    projectId: 'edirectory-ecfcf',
    authDomain: 'edirectory-ecfcf.firebaseapp.com',
    storageBucket: 'edirectory-ecfcf.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB2z3rtfsV5-DvgyLxAgdF_IQbTCwE_XOs',
    appId: '1:531362834016:android:c54fd4441ac2006921c505',
    messagingSenderId: '531362834016',
    projectId: 'edirectory-ecfcf',
    storageBucket: 'edirectory-ecfcf.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB2ey94Y5vj1SOhp7VqCP9cfObGAfMB0Lk',
    appId: '1:531362834016:ios:0a207217983692ea21c505',
    messagingSenderId: '531362834016',
    projectId: 'edirectory-ecfcf',
    storageBucket: 'edirectory-ecfcf.firebasestorage.app',
    iosBundleId: 'com.edirectory.livora',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB2ey94Y5vj1SOhp7VqCP9cfObGAfMB0Lk',
    appId: '1:531362834016:ios:0a207217983692ea21c505',
    messagingSenderId: '531362834016',
    projectId: 'edirectory-ecfcf',
    storageBucket: 'edirectory-ecfcf.firebasestorage.app',
    iosBundleId: 'com.edirectory.livora',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyB2ey94Y5vj1SOhp7VqCP9cfObGAfMB0Lk',
    appId: '1:531362834016:web:610064c5dfcb033321c505',
    messagingSenderId: '531362834016',
    projectId: 'edirectory-ecfcf',
    authDomain: 'edirectory-ecfcf.firebaseapp.com',
    storageBucket: 'edirectory-ecfcf.firebasestorage.app',
  );
}
