import 'package:firebase_messaging/firebase_messaging.dart';

/// Handles push notification permission + token registration via FCM.
/// Admin sends notifications from the Firebase console or a backend function
/// using the tokens stored under students/{uid}.fcmToken.
class PushNotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<String?> initAndGetToken() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return _messaging.getToken();
  }

  void listenForegroundMessages(void Function(RemoteMessage message) onMessage) {
    FirebaseMessaging.onMessage.listen(onMessage);
  }

  void listenNotificationTaps(void Function(RemoteMessage message) onTap) {
    FirebaseMessaging.onMessageOpenedApp.listen(onTap);
  }
}
