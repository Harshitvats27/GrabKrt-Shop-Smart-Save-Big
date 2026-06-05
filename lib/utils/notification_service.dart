import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // 1. Permission mango
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    // 🔥 Local Notifications ko initialize karna zaroori hai
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidSettings);

    // 🔥 FIX 1: Tera version named parameter maang raha hai, isliye 'initializationSettings:' (ya 'settings:') lagaya hai
    await _localNotifications.initialize(
       settings: initSettings, // Note: Agar tera package directly 'settings' maangta hai toh yahan 'settings: initSettings' likh dena
    );

    // 2. Device Token fetch karke Firestore me save karo
    String? token = await _fcm.getToken();
    if (token != null && FirebaseAuth.instance.currentUser != null) {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      try {
        await FirebaseFirestore.instance.collection('Users').doc(uid).update({
          'userDeviceToken': token,
        });
        print("🔥 Token Saved: $token");
      } catch (e) {
        print("Token update error: $e");
      }
    }

    // 3. Foreground listener (Jab app open ho)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        _showLocalNotification(message);
      }
    });
  }

  static void _showLocalNotification(RemoteMessage message) {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel', // channelId
      'High Importance',         // channelName
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    // 🔥 FIX 2: Poora Named Parameters format! Jisme explicitly id:, title:, wagera define kiya hai.
    _localNotifications.show(
      id: message.hashCode,                                      // 1st: id
      title: message.notification?.title,                        // 2nd: title
      body: message.notification?.body,                          // 3rd: body
      notificationDetails: const NotificationDetails(android: androidDetails), // 4th: notificationDetails
    );
  }
}