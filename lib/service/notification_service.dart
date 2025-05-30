// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:push_notification/firebase_options.dart';

// class NotificationService {
//   static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   static final FirebaseMessaging _firebaseMessaging =
//       FirebaseMessaging.instance;

//   ///handel the message when the app is in the background or terminated
//   @pragma('vm:entry-point')
//   static Future<void> firebaseMessagingBackgroundHandler(
//     RemoteMessage message,
//   ) async {
//     //firebase must be initialized in background isolate
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );

//     //initialize local notification plugin and show notification
//     await _initializeLocalNotification();
//     await _showFlutterNotification(message);
//   }

//   // Initializes Firebase Messaging and Local Notifications
//   static Future<void> initializeNotification() async {
//     // Request permissions (required on iOS, optional on Android)
//     await _firebaseMessaging.requestPermission();

//     // Called when message is received while app is in foreground
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//       await _showFlutterNotification(message);
//     });

//     // Called when app is brought to foreground from background by tapping a notification
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       // Handle navigation or other actions when notification is tapped
//       print("App opened from background notification: ${message.data}");
//       // In production, use proper logging instead of print
//     });

//     // Get and print FCM token (for sending targeted messages)
//     await _getFcmToken();

//     // Initialize the local notification plugin
//     await _initializeLocalNotification();

//     // Check if app was launched by tapping on a notification
//     await _getInitializeNotification();
//   }

//   // Fetches and prints FCM token
//   static Future<void> _getFcmToken() async {
//     String? token = await _firebaseMessaging.getToken();
//     print("FCM Token: $token");
//     // Note: In production, use proper logging instead of print
//     // Use this token to send messages to this device
//   }

//   ///show a local notification when the message recieved
//   static Future<void> _showFlutterNotification(RemoteMessage message) async {
//     RemoteNotification? notification = message.notification;
//     Map<String, dynamic>? data = message.data;

//     String title = notification?.title ?? data['title'] ?? 'no title';
//     String body = notification?.body ?? data['body'] ?? 'No body';

//     //andriod notification config
//     AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//       "CHANNEL_ID",
//       "CHANNEL_NAME",
//       channelDescription: 'notification channel for basic tests',
//       priority: Priority.high,
//       importance: Importance.high,
//     );

//     //ios notification config
//     DarwinNotificationDetails iosDetails = const DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//     );

//     //combine platform-specific settings
//     NotificationDetails notificationDetails = NotificationDetails(
//       android: androidDetails,
//       iOS: iosDetails,
//     );

//     await flutterLocalNotificationsPlugin.show(
//       0, //notification ids
//       title,
//       body,
//       notificationDetails,
//     );
//   }

//   /// initialize local notification system (both andriod and ios)
//   static Future<void> _initializeLocalNotification() async {
//     const AndroidInitializationSettings andriodInitialize =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     const DarwinInitializationSettings iosInitialize =
//         DarwinInitializationSettings();

//     final InitializationSettings initSettings = InitializationSettings(
//       android: andriodInitialize,
//       iOS: iosInitialize,
//     );

//     await flutterLocalNotificationsPlugin.initialize(
//       initSettings,
//       onDidReceiveBackgroundNotificationResponse: (
//         NotificationResponse response,
//       ) {
//         // Handle notification tap when app is in background
//         // You can navigate to specific screen based on the payload
//         print('Notification tapped in background: ${response.payload}');
//       },
//     );
//   }

//   ///handle notification tap when app is terminated
//   static Future<void> _getInitializeNotification() async {
//     RemoteMessage? message =
//         await FirebaseMessaging.instance.getInitialMessage();

//     if (message != null) {
//       print(
//         'App launched from terminated state via notification : ${message.data}',
//       );
//     }
//   }
// }
