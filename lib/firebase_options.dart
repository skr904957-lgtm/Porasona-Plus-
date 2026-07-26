import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE_WITH_YOUR_WEB_API_KEY',
    appId: 'REPLACE_WITH_YOUR_WEB_APP_ID',
    messagingSenderId: '1059317217128',
    projectId: 'porasona-plus-44b42',
    authDomain: 'porasona-plus-44b42.firebaseapp.com',
    storageBucket: 'porasona-plus-44b42.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBVEeTZfdFiWLNtPtPZdkM_KVDiDrWDnEE',
    appId: '1:1059317217128:android:06c563200e21fce18548dd',
    messagingSenderId: '1059317217128',
    projectId: 'porasona-plus-44b42',
    storageBucket: 'porasona-plus-44b42.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_YOUR_IOS_API_KEY',
    appId: 'REPLACE_WITH_YOUR_IOS_APP_ID',
    messagingSenderId: 'REPLACE_WITH_YOUR_SENDER_ID',
    projectId: 'porasona-plus-44b42',
    storageBucket: 'porasona-plus-44b42.firebasestorage.app',
    iosBundleId: 'com.porasonaplus.app',
  );
}
