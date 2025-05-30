import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:push_notification/service/local_notification_service.dart';

class FirebaseMessagingService {
  //private constructor for singltone pattern
  FirebaseMessagingService.internal();

  //singleton instance
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService.internal();

  //factory constructor to provide singleton instance
  factory FirebaseMessagingService.instance() => _instance;

  //refernce to local notification service to display notification
  LocalNotificationService? _localNotificationService;

  //initialize firebase messaging and setup all message listener
  Future<void> init({
    required LocalNotificationService localNotificationService,
  }) async {
    //init local notification service
    _localNotificationService = localNotificationService;

    //handle fcm token
    _handlePushNotificationsToken();

    //request user permission for notification
    _requestPermission();

    //register handler for background message (app terminated)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    //listen for message when the app is in foreground
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    //listen for notification taps when the app is in background but not terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    //check for initial message that opened the app from terminated state
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _onMessageOpenedApp(initialMessage);
    }
  }

  ///Retrivers and manages the FCM token for push notifications
  Future<void> _handlePushNotificationsToken() async {
    //get FCM token for the device
    final token = await FirebaseMessaging.instance.getToken();
    print('push notification token: $token');
    //listen for token  refresh events
    FirebaseMessaging.instance.onTokenRefresh
        .listen((fcmToken) {
          print('FCM token refreshed : $fcmToken');
          //TODO: optinally sent token to your server for targeting this device
        })
        .onError((error) {
          //handle error during refresh token
          print('error refreshing FCM token: $error');
        });
  }

  /// Request notifiction permission from the user
  Future<void> _requestPermission() async {
    //request permission for alerts, badges and sounds
    final result = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    //log user's permission decision
    print('user granted permission: ${result.authorizationStatus}');
  }

  ///handles message received while the app is in the forground
  void _onForegroundMessage(RemoteMessage message) {
    print('Foreground messege received: ${message.data.toString()}');

    final notificationData = message.notification;
    if (notificationData != null) {
      //display a local notification using the service
      _localNotificationService?.showNotification(
        notificationData.title,
        notificationData.body,
        message.data.toString(),
      );
    }
  }

  ///Handles notification tabs when app is opened from the backgroud
  void _onMessageOpenedApp(RemoteMessage message) {
    print('notifciaton caused the app to open: ${message.data.toString()}');
    //TODO: add navigation or specific handling based on message data
  }
}

///Background message handler (must be top-level function or static)
///handles  message when the app is fully terminated
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message received:: ${message.data.toString()}');
}
