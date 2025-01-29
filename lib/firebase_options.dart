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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Android configuration based on provided values
  static FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCzIHn4Ym8xRd8aQtib2aw-PWx4moLLpGQ',
    appId: '1:62854215094:android:6ed5d795f55f4351f7bd17',
    messagingSenderId: '62854215094',
    projectId: 'equalink-app',
    storageBucket: 'equalink-app.appspot.com',
  );

  // Web configuration based on provided values
  static FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCzIHn4Ym8xRd8aQtib2aw-PWx4moLLpGQ',
    appId: '1:62854215094:web:6ed5d795f55f4351f7bd17',
    messagingSenderId: '62854215094',
    projectId: 'equalink-app',
    storageBucket: 'equalink-app.appspot.com',
  );
}

