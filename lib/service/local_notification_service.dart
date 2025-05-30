import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// This MUST be a top-level function (not inside a class)
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  print('Notification tapped in background: ${notificationResponse.payload}');
  // Handle the notification tap here
  // You can add navigation logic or other handling
}

class LocalNotificationService {
  //private constructor for singleton pattern
  LocalNotificationService._internal();

  // singleton instance
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();

  //factory constructor to return singleton instance
  factory LocalNotificationService.instance() => _instance;

  //main plugin instance to handle notifications
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  //android-specific initialization settings with permission requests
  final _androidInitializationSettings = AndroidInitializationSettings(
    '@mipmap/ic_launcher',
  );

  // ios-specific initialization settings with permission requests
  final _iosInitializationSettings = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  // android notification channel configuration
  final _androidChannel = AndroidNotificationChannel(
    'channel_id',
    'Push Notifications',
    description: 'Important notifications from the app',
    importance: Importance.max,

    showBadge: true,
    playSound: true,
    enableVibration: true,
  );

  //flag to track initialization status
  bool _isFlutterLocalNotificationInitialized = false;
  //counter for generation unique notification ids
  int _notificationIdCounter = 0;

  ///initialize the local notification plugin for android & ios
  Future<void> init() async {
    // check if already initialized to prevent redundant setup
    if (_isFlutterLocalNotificationInitialized) {
      return;
    }

    //create plugin instance
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    //combine platform-specific settings
    final initializationSettings = InitializationSettings(
      android: _androidInitializationSettings,
      iOS: _iosInitializationSettings,
    );

    //initialize plugin with settings and callbacks for notification taps
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      // Use the top-level function for foreground notification taps
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('Notification tapped in foreground: ${response.payload}');
        // Handle foreground notification taps here
      },
      // Use the top-level function for background notification taps
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    //create android notification channel
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChannel);

    //mark initialization as complete
    _isFlutterLocalNotificationInitialized = true;
  }

  ///show a local notification with the given title, body and payload
  Future<void> showNotification(
    String? title,
    String? body,
    String? payload,
  ) async {
    //android-specific notification details
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _androidChannel.id,
      _androidChannel.name,
      channelDescription: _androidChannel.description,
      priority: Priority.max,
      importance: Importance.max,
      showWhen: true,
      when: DateTime.now().millisecondsSinceEpoch,
      usesChronometer: false,
      chronometerCountDown: false,
      showProgress: false,
      maxProgress: 0,
      progress: 0,
      indeterminate: false,
      channelShowBadge: true,
      onlyAlertOnce: false,
      ongoing: false,
      silent: false,
      autoCancel: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.message,
      visibility: NotificationVisibility.public,
      timeoutAfter: null,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(''),
    );

    //ios-specific notification details
    DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      badgeNumber: 1,
    );

    //combine platform-specific details
    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    //display the notification
    await _flutterLocalNotificationsPlugin.show(
      _notificationIdCounter++,
      title ?? 'Notification',
      body ?? 'You have a new message',
      notificationDetails,
      payload: payload,
    );
  }
}
