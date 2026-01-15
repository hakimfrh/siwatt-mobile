import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:siwatt_mobile/core/themes/siwatt_themes.dart';
import 'package:siwatt_mobile/features/Auth/pages/lupa_password.dart';
import 'package:siwatt_mobile/features/Auth/pages/login.dart';
import 'package:siwatt_mobile/features/Auth/pages/register.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: siwattTheme(),
      initialRoute: '/lupa_password',
      getPages: [
        GetPage(name: '/login', page: () => const LoginPage()),
        GetPage(name: '/register', page: () => const RegisterPage()),
        GetPage(name: '/lupa_password', page: () => const LupaPassword()),
        ],
    );
  }
}
