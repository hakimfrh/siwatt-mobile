import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:siwatt_mobile/core/models/user_model.dart';
import 'package:siwatt_mobile/core/services/notification_handler.dart';

/// Konstanta untuk notification channel
class NotificationConstants {
  static const String channelId = 'high_importance_channel';
  static const String channelName = 'High Importance Notifications';
  static const String channelDescription = 'This channel is used for important notifications.';
  static const String notificationIcon = 'ic_notification';
}

/// Service untuk menangani Firebase Cloud Messaging dan Local Notifications
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = 
      FlutterLocalNotificationsPlugin();

  FlutterLocalNotificationsPlugin get notificationsPlugin => _notificationsPlugin;

  /// Background message handler (harus top-level function)
  /// Dipanggil dari main.dart
  static Future<void> backgroundMessageHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    
    debugPrint('========================================');
    debugPrint('🔔 Background Message Received!');
    debugPrint('Message ID: ${message.messageId}');
    debugPrint('Notification Title: ${message.notification?.title}');
    debugPrint('Notification Body: ${message.notification?.body}');
    debugPrint('Data: ${message.data}');
    debugPrint('========================================');
    
    // Inisialisasi plugin untuk background isolate
    final FlutterLocalNotificationsPlugin backgroundPlugin = 
        FlutterLocalNotificationsPlugin();
    
    await _initializeBackgroundPlugin(backgroundPlugin);
    
    // Tampilkan local notification
    await _showNotification(
      backgroundPlugin,
      title: message.data['title'] ?? message.notification?.title ?? 'Notifikasi',
      body: message.data['body'] ?? message.notification?.body ?? '',
      payload: message.data.toString(),
    );
  }

  /// Initialize plugin untuk background isolate
  static Future<void> _initializeBackgroundPlugin(
    FlutterLocalNotificationsPlugin plugin,
  ) async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings(NotificationConstants.notificationIcon);
    
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );
    
    await plugin.initialize(initSettings);
    
    // Create notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      NotificationConstants.channelId,
      NotificationConstants.channelName,
      description: NotificationConstants.channelDescription,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );
    
    await plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Tampilkan local notification
  static Future<void> _showNotification(
    FlutterLocalNotificationsPlugin plugin, {
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      NotificationConstants.channelId,
      NotificationConstants.channelName,
      channelDescription: NotificationConstants.channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      enableLights: true,
      icon: NotificationConstants.notificationIcon,
      color: Color(0xFF2DA89A),
      ongoing: false,
      autoCancel: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await plugin.show(
      DateTime.now().millisecond,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Inisialisasi Firebase Cloud Messaging
  Future<RemoteMessage?> initialize() async {
    try {
      debugPrint('========================================');
      debugPrint('Initializing Firebase Messaging...');

      // Request permissions
      await _requestPermissions();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Setup Firebase Messaging
      final initialMessage = await _setupFirebaseMessaging();

      debugPrint('Firebase Messaging initialized successfully');
      debugPrint('========================================');

      return initialMessage;
    } catch (e) {
      debugPrint('========================================');
      debugPrint('Error initializing FCM: $e');
      debugPrint('========================================');
      return null;
    }
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    // Request notification permission untuk Android 13+
    await Permission.notification.request();
    
    // Request disable battery optimization
    // Ini kunci agar notifikasi tetap muncul saat app lama tidak dibuka
    if (!await Permission.ignoreBatteryOptimizations.isGranted) {
      debugPrint('⚠️ Requesting battery optimization exemption...');
      final status = await Permission.ignoreBatteryOptimizations.request();
      debugPrint('Battery optimization status: $status');
      
      // Tampilkan dialog edukatif ke user
      if (status.isDenied) {
        Get.snackbar(
          'Penting: Optimisasi Baterai',
          'Untuk menerima notifikasi saat aplikasi tidak dibuka, harap matikan optimisasi baterai untuk aplikasi ini di pengaturan.',
          duration: const Duration(seconds: 8),
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    }
  }

  /// Initialize local notifications plugin
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings(NotificationConstants.notificationIcon);

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('🔔 Notification Tapped: ${response.payload}');
        if (response.payload != null) {
          // Handle navigation dari local notification tap
          // Bisa di-extend untuk parse payload dan navigate
        }
      },
    );

    // Create Android Notification Channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      NotificationConstants.channelId,
      NotificationConstants.channelName,
      description: NotificationConstants.channelDescription,
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Setup Firebase Messaging listeners
  Future<RemoteMessage?> _setupFirebaseMessaging() async {
    const storage = FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
        resetOnError: true,
      ),
    );

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permission for iOS
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    debugPrint('User granted permission: ${settings.authorizationStatus}');

    // Get FCM token
    String? token = await messaging.getToken();
    debugPrint('========================================');
    debugPrint('FCM Token: $token');
    debugPrint('========================================');

    // Save token to secure storage
    await storage.write(key: 'fcm_token', value: token);

    // Listen for token refresh
    _setupTokenRefreshListener(messaging, storage);

    // Handle foreground messages
    _setupForegroundMessageListener(messaging);

    // Handle notification tap when app is in background
    _setupMessageOpenedAppListener(messaging);

    // Check if app was opened from terminated state
    return await _checkInitialMessage(messaging);
  }

  /// Setup token refresh listener
  void _setupTokenRefreshListener(
    FirebaseMessaging messaging,
    FlutterSecureStorage storage,
  ) {
    messaging.onTokenRefresh.listen((newToken) async {
      debugPrint('========================================');
      debugPrint('FCM Token Refreshed: $newToken');
      debugPrint('========================================');

      await storage.write(key: 'fcm_token', value: newToken);

      // Re-subscribe to user topic if logged in
      if (Hive.isBoxOpen('userBox')) {
        var userBox = Hive.box('userBox');
        if (userBox.isNotEmpty && userBox.get('user') != null) {
          try {
            User user = userBox.get('user');
            await FirebaseMessaging.instance.subscribeToTopic("user_${user.id}");
            debugPrint('Re-subscribed to topic: user_${user.id}');
          } catch (e) {
            debugPrint('Error subscribing to topic after refresh: $e');
          }
        }
      }
    });
  }

  /// Setup foreground message listener
  void _setupForegroundMessageListener(FirebaseMessaging messaging) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint('========================================');
      debugPrint('🔔 Foreground Message Received!');
      debugPrint('Message ID: ${message.messageId}');
      debugPrint('Notification Title: ${message.notification?.title}');
      debugPrint('Notification Body: ${message.notification?.body}');
      debugPrint('Data: ${message.data}');
      debugPrint('========================================');

      // Tampilkan local notification saat app di foreground
      await _showNotification(
        _notificationsPlugin,
        title: message.data['title'] ?? message.notification?.title ?? 'Notifikasi',
        body: message.data['body'] ?? message.notification?.body ?? '',
        payload: message.data.toString(),
      );
    });
  }

  /// Setup message opened app listener (background tap)
  void _setupMessageOpenedAppListener(FirebaseMessaging messaging) {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('========================================');
      debugPrint('🔔 Notification Opened (Background)!');
      debugPrint('Message ID: ${message.messageId}');
      debugPrint('Data: ${message.data}');
      debugPrint('========================================');
      
      NotificationHandler.handleNavigation(message.data);
    });
  }

  /// Check if app was opened from terminated state
  Future<RemoteMessage?> _checkInitialMessage(FirebaseMessaging messaging) async {
    RemoteMessage? initialMessage = await messaging.getInitialMessage();
    
    if (initialMessage != null) {
      debugPrint('========================================');
      debugPrint('🔔 App Opened from Terminated State!');
      debugPrint('Message ID: ${initialMessage.messageId}');
      debugPrint('Data: ${initialMessage.data}');
      debugPrint('========================================');
    }
    
    return initialMessage;
  }
}
