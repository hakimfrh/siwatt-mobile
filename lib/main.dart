import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:siwatt_mobile/core/themes/siwatt_themes.dart';
import 'package:siwatt_mobile/features/Auth/pages/lupa_password.dart';
import 'package:siwatt_mobile/features/Auth/pages/login.dart';
import 'package:siwatt_mobile/features/Auth/pages/register.dart';
import 'package:siwatt_mobile/features/Main/pages/main_wrapper.dart';
import 'package:siwatt_mobile/core/network/dio_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Get.putAsync(() => DioClient().init());
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: siwattTheme(),
      initialRoute: '/main',
      getPages: [
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/register', page: () => const RegisterPage()),
        GetPage(name: '/lupa-password', page: () => const LupaPassword()),
        GetPage(name: '/main', page: () => const MainWrapper()),
      ],
    );
  }
}
