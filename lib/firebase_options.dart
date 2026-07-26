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
    messagingSenderId: '1057074319828',
    projectId: 'porasona-plus-b78c9',
    authDomain: 'porasona-plus-b78c9.firebaseapp.com',
    storageBucket: 'porasona-plus-b78c9.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCDT4rtCBsvVj96zn45ZP0lBh9SYD7howc',
    appId: '1:1057074319828:android:b05fc9b7afd07691848641',
    messagingSenderId: '1057074319828',
    projectId: 'porasona-plus-b78c9',
    storageBucket: 'porasona-plus-b78c9.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_YOUR_IOS_API_KEY',
    appId: 'REPLACE_WITH_YOUR_IOS_APP_ID',
    messagingSenderId: '1057074319828',
    projectId: 'porasona-plus-b78c9',
    storageBucket: 'porasona-plus-b78c9.firebasestorage.app',
    iosBundleId: 'com.porasonaplus.app',
  );
}
