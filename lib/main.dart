import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:siwatt_mobile/core/themes/siwatt_colors.dart';
import 'package:siwatt_mobile/core/themes/siwatt_themes.dart';
import 'package:siwatt_mobile/features/add_device/pages/add_device.dart';
import 'package:siwatt_mobile/features/auth/pages/lupa_password.dart';
import 'package:siwatt_mobile/features/auth/pages/login.dart';
import 'package:siwatt_mobile/features/auth/pages/register.dart';
import 'package:siwatt_mobile/features/main/pages/main_wrapper.dart';
import 'package:siwatt_mobile/core/network/dio_controller.dart';
import 'package:siwatt_mobile/core/models/user_model.dart';
import 'package:siwatt_mobile/features/main/controllers/main_controller.dart';

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('========================================');
  debugPrint('🔔 Background Message Received!');
  debugPrint('Message ID: ${message.messageId}');
  debugPrint('Notification Title: ${message.notification?.title}');
  debugPrint('Notification Body: ${message.notification?.body}');
  debugPrint('Data: ${message.data}');
  debugPrint('========================================');
}

void handleNotificationNavigation(Map<String, dynamic> data) async {
  debugPrint('🚀 Handling Notification Navigation: $data');
  
  if (data['type'] == 'low-credit' && data['device_id'] != null) {
    try {
      // Tunggu sebentar agar UI thread siap (terutama dari background resume)
      await Future.delayed(const Duration(milliseconds: 500)); 

      int? deviceId = int.tryParse(data['device_id'].toString());
      if (deviceId != null) {
        bool handled = false;
        try {
          if (Get.isRegistered<MainController>()) {
             debugPrint('✅ MainController found, switching device...');
             Get.find<MainController>().switchToDevice(deviceId);
             handled = true;
          }
        } catch (e) {
             debugPrint('⚠️ MainController check error: $e');
        }

        if (!handled) {
          debugPrint('🔄 MainController NOT found, navigating to /main with arguments...');
          // Gunakan offAllNamed untuk reset stack dan paksa init controller baru
          Get.offAllNamed('/main', arguments: {'device_id': deviceId});
        }
      } else {
          debugPrint('❌ Invalid Device ID format');
      }
    } catch (e) {
      debugPrint('❌ Error handling notification navigation: $e');
    }
  } else {
      debugPrint('⚠️ Notification data skipped (type mismatch or no device_id)');
  }
}

Future<RemoteMessage?> initializeFCM() async {
  try {
    debugPrint('========================================');
    debugPrint('Initializing Firebase Messaging...');

    const storage = FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true, resetOnError: true));

    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Request permission for iOS
    NotificationSettings settings = await messaging.requestPermission(alert: true, badge: true, sound: true);

    debugPrint('User granted permission: ${settings.authorizationStatus}');

    // Get FCM token
    String? token = await messaging.getToken();
    debugPrint('========================================');
    debugPrint('FCM Token: $token');
    debugPrint('========================================');

    // Save token to FlutterSecureStorage
    await storage.write(key: 'fcm_token', value: token);

    // Listen for token refresh
    messaging.onTokenRefresh.listen((newToken) async {
      debugPrint('========================================');
      debugPrint('FCM Token Refreshed: $newToken');
      debugPrint('========================================');

      await storage.write(key: 'fcm_token', value: newToken);

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
        } else {
          debugPrint('User not logged in, skipping topic subscription.');
        }
      }
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('========================================');
      debugPrint('🔔 Foreground Message Received!');
      debugPrint('Message ID: ${message.messageId}');
      debugPrint('Notification Title: ${message.notification?.title}');
      debugPrint('Notification Body: ${message.notification?.body}');
      debugPrint('Data: ${message.data}');
      debugPrint('========================================');

      Get.snackbar(
        message.notification?.title ?? 'Notification',
        message.notification?.body ?? '',
        duration: const Duration(seconds: 10),
        backgroundColor: SiwattColors.accentInfo,
        colorText: Colors.white,
      );
    });

    // Handle notification tap when app is in background or terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('========================================');
      debugPrint('🔔 Notification Opened (Background)!');
      debugPrint('Message ID: ${message.messageId}');
      debugPrint('Notification Title: ${message.notification?.title}');
      debugPrint('Notification Body: ${message.notification?.body}');
      debugPrint('Data: ${message.data}');
      debugPrint('========================================');
      
      // CALL FUNCTION DIRECTLY HERE
      handleNotificationNavigation(message.data);
    });

    // Check if app was opened from a terminated state
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('========================================');
      debugPrint('🔔 App Opened from Terminated State!');
      debugPrint('Message ID: ${initialMessage.messageId}');
      debugPrint('Notification Title: ${initialMessage.notification?.title}');
      debugPrint('Notification Body: ${initialMessage.notification?.body}');
      debugPrint('Data: ${initialMessage.data}');
      debugPrint('========================================');
      return initialMessage;
    }
  } catch (e) {
    debugPrint('========================================');
    debugPrint('Error initializing FCM: $e');
    debugPrint('========================================');
  }
  return null;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Check login status
  // Use encryptedSharedPreferences: true for better stability on Android and resetOnError to handle keystore issues

  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  RemoteMessage? initialMessage = await initializeFCM();

  const storage = FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true, resetOnError: true));

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());
  await Hive.openBox('userBox');

  String? token;
  try {
    token = await storage.read(key: 'token');
  } catch (e) {
    debugPrint("Storage error: $e");
    // If we can't read the token, we assume logged out.
    // resetOnError: true in options should handle wiping, but we can be safe.
    await storage.deleteAll();
  }

  String initialRoute = token != null ? '/main' : '/login';

  await Get.putAsync(() => DioClient().init());
  runApp(MainApp(initialRoute: initialRoute, initialMessage: initialMessage));
}

class MainApp extends StatelessWidget {
  final String initialRoute;
  final RemoteMessage? initialMessage;
  const MainApp({super.key, required this.initialRoute, this.initialMessage});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: siwattTheme(),
      initialRoute: initialRoute,
      onReady: () {
        if (initialMessage != null) {
          handleNotificationNavigation(initialMessage!.data);
        }
      },
      getPages: [
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/register', page: () => const RegisterPage()),
        GetPage(name: '/lupa-password', page: () => const LupaPassword()),
        GetPage(name: '/main', page: () => const MainWrapper()),
        GetPage(name: '/add-device', page: () => const AddDevicePage()),
      ],
    );
  }
}
