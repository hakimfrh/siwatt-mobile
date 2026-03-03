import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:siwatt_mobile/core/themes/siwatt_themes.dart';
import 'package:siwatt_mobile/core/network/dio_controller.dart';
import 'package:siwatt_mobile/core/models/user_model.dart';
import 'package:siwatt_mobile/core/services/firebase_service.dart';
import 'package:siwatt_mobile/core/services/notification_handler.dart';
import 'package:siwatt_mobile/features/add_device/pages/add_device.dart';
import 'package:siwatt_mobile/features/auth/pages/lupa_password.dart';
import 'package:siwatt_mobile/features/auth/pages/login.dart';
import 'package:siwatt_mobile/features/auth/pages/register.dart';
import 'package:siwatt_mobile/features/main/pages/main_wrapper.dart';

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await FirebaseService.backgroundMessageHandler(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Setup background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  
  // Initialize Firebase Service & get initial message
  final firebaseService = FirebaseService();
  RemoteMessage? initialMessage = await firebaseService.initialize();

  // Initialize secure storage
  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true,
    ),
  );

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());
  await Hive.openBox('userBox');

  // Check login status
  String? token;
  try {
    token = await storage.read(key: 'token');
  } catch (e) {
    debugPrint("Storage error: $e");
    await storage.deleteAll();
  }

  // Determine initial route
  String initialRoute = token != null ? '/main' : '/login';

  // Initialize DioClient
  await Get.putAsync(() => DioClient().init());

  // Run app
  runApp(MainApp(
    initialRoute: initialRoute,
    initialMessage: initialMessage,
  ));
}

class MainApp extends StatelessWidget {
  final String initialRoute;
  final RemoteMessage? initialMessage;

  const MainApp({
    super.key,
    required this.initialRoute,
    this.initialMessage,
  });

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: siwattTheme(),
      initialRoute: initialRoute,
      onReady: () {
        // Handle notification yang membuka app dari terminated state
        if (initialMessage != null) {
          NotificationHandler.handleNavigation(initialMessage!.data);
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
