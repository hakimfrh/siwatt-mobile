import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LupaPassword extends StatefulWidget {
  const LupaPassword({super.key});

  @override
  State<LupaPassword> createState() => _LupaPasswordState();
}

class _LupaPasswordState extends State<LupaPassword> {
  int currentStep = 0;
  List<String> headerTitle = ['Lupa Password', 'Cek Email Kamu', 'Buat Password Baru'];
  List<String> headerSubtitle = ['Masukkan Email Untuk Melanjutkan', 'Kode OTP Telah Dikirim Melalui Email', ''];

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (value != _passwordController.text) {
      return 'Password tidak cocok';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
      ),
      body: Center(
        heightFactor: 0.75,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 80, width: 80, child: Placeholder()),
              SizedBox(height: 8),
              Text(
                headerTitle[currentStep],
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              if (headerSubtitle[currentStep].isNotEmpty) ...[
                SizedBox(height: 4),
                Text(headerSubtitle[currentStep], style: textStyle.bodyLarge?.copyWith(color: Colors.white)),
              ],
              if (currentStep == 0) ...[
                SizedBox(height: 32),
                Row(
                  children: [
                    Text("Email", style: textStyle.bodyLarge?.copyWith(color: Colors.white)),
                    Spacer(),
                  ],
                ),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(hintText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    Text("Kami akan mengirimkan kode verifikasi ke emailmu", style: TextStyle(fontSize: 10, color: Colors.white)),
                    Spacer(),
                  ],
                ),
              ],

              if (currentStep == 1) ...[
                SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 50,
                      child: TextFormField(
                        autofocus: index == 0,
                        onChanged: (value) {
                          if (value.length == 1 && index < 5) {
                            FocusScope.of(context).nextFocus();
                          }
                          if (value.isEmpty && index > 0) {
                            FocusScope.of(context).previousFocus();
                          }
                        },
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        inputFormatters: [LengthLimitingTextInputFormatter(1), FilteringTextInputFormatter.digitsOnly],
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          isDense: true,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Kirim Ulang Kode ?", style: textStyle.bodyMedium?.copyWith(color: Colors.white)),
                ),
                SizedBox(height: 16),
              ],

              if (currentStep == 2) ...[
                SizedBox(height: 24),

                Row(
                  children: [
                    Text('Password', style: textStyle.titleMedium?.copyWith(color: Colors.white)),
                    Spacer(),
                  ],
                ),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  validator: _validatePassword,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
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
                const SizedBox(height: 8),

                Row(
                  children: [
                    Text('Password', style: textStyle.titleMedium?.copyWith(color: Colors.white)),
                    Spacer(),
                  ],
                ),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  validator: _validateConfirmPassword,
                  decoration: InputDecoration(
                    hintText: 'Ulangi Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(height: 24),
              ],

              ElevatedButton(
                onPressed: () {
                  if (currentStep == 0) {
                    setState(() {
                      currentStep = 1;
                    });
                  } else if (currentStep == 1) {
                    setState(() {
                      currentStep = 2;
                    });
                  }
                },
                child: Text('Lanjutkan', style: textStyle.headlineLarge?.copyWith(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
