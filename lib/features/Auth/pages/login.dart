import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:siwatt_mobile/features/Auth/controllers/login_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _controller = Get.put(LoginController());
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      _controller.login(_emailController.text, _passwordController.text);
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email tidak valid';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: colorScheme.primary,
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'SiWatt',
                        style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: 48),
                  Text("Email", style: textStyle.titleMedium?.copyWith(color: Colors.white)),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                    decoration: InputDecoration(hintText: 'Email'),
                  ),
                  SizedBox(height: 16),
                  Text("Password", style: textStyle.titleMedium?.copyWith(color: Colors.white)),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    validator: _validatePassword,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                        activeColor: Colors.white,
                        checkColor: colorScheme.primary,
                        side: BorderSide(color: Colors.white, width: 2),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                      Text('Ingat Saya', style: TextStyle(color: Colors.white)),
                      Spacer(),
                      InkWell(
                        onTap: () {
                          Get.toNamed('/lupa-password');
                        },
                        child: Text('Lupa Password?', style: TextStyle(color: Colors.white))),
                      
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text("Belum Punya Akun?", style: TextStyle(color: Colors.white)),
                      SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          Get.toNamed('/register');
                        },
                        child: Text(
                            'Daftar Sekarang',
                            style: TextStyle(color: Colors.white),
                          ),
                      ),
                      
                    ],
                  ),
                  SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      _handleLogin();
                    },
                    child: Obx(() => _controller.isLoading.value
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: colorScheme.primary,
                              strokeWidth: 2,
                            ))
                        : Text('Masuk', style: TextStyle(fontSize: 16))),
                  ),
                ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
