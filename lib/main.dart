import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:siwatt_mobile/core/themes/siwatt_themes.dart';
import 'package:siwatt_mobile/features/add_device/pages/add_device.dart';
import 'package:siwatt_mobile/features/auth/pages/lupa_password.dart';
import 'package:siwatt_mobile/features/auth/pages/login.dart';
import 'package:siwatt_mobile/features/auth/pages/register.dart';
import 'package:siwatt_mobile/features/main/pages/main_wrapper.dart';
import 'package:siwatt_mobile/core/network/dio_controller.dart';
import 'package:siwatt_mobile/core/models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());
  await Hive.openBox('userBox');

  // Check login status
  // Use encryptedSharedPreferences: true for better stability on Android and resetOnError to handle keystore issues
  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      resetOnError: true,
    ),
  );
  
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
  runApp(MainApp(initialRoute: initialRoute));
}

class MainApp extends StatelessWidget {
  final String initialRoute;
  const MainApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: siwattTheme(),
      initialRoute: initialRoute,
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
