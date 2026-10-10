import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('FCM BG title=${message.notification?.title}');
  debugPrint('FCM BG data=${message.data}');
}

class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  final _local = FlutterLocalNotificationsPlugin();
  static const _channel = AndroidNotificationChannel(
    'fooding_orders',
    'Order updates',
    description: 'Confirmed order notifications',
    importance: Importance.high,
  );

  String? token;

  Future<void> init() async {
    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      await _local.initialize(
        const InitializationSettings(android: androidInit),
      );
      await _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);

      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('FCM permission=${settings.authorizationStatus}');

      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      token = await messaging.getToken();
      debugPrint('FCM TOKEN=$token');

      messaging.onTokenRefresh.listen((value) {
        token = value;
        debugPrint('FCM TOKEN REFRESH=$value');
      });

      FirebaseMessaging.onMessage.listen((message) {
        debugPrint('FCM FOREGROUND title=${message.notification?.title}');
        debugPrint('FCM FOREGROUND body=${message.notification?.body}');
        showOrderNotification(
          title: message.notification?.title ?? 'Fooding',
          body: message.notification?.body ?? message.data.toString(),
        );
      });
    } catch (e) {
      debugPrint('FCM INIT ERROR $e');
    }
  }

  Future<void> showOrderNotification({
    required String title,
    required String body,
  }) async {
    await _local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }
}
