import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:siwatt_mobile/core/themes/siwatt_colors.dart';
import 'package:siwatt_mobile/features/auth/controllers/lupa_password_controller.dart';

class LupaPassword extends StatefulWidget {
  const LupaPassword({super.key});

  @override
  State<LupaPassword> createState() => _LupaPasswordState();
}

class _LupaPasswordState extends State<LupaPassword> {
  late final LupaPasswordController _controller;

  int currentStep = 0;
  List<String> headerTitle = ['Lupa Password', 'Cek Email Kamu', 'Buat Password Baru'];
  List<String> headerSubtitle = ['Masukkan Email Untuk Melanjutkan', 'Kode OTP Telah Dikirim Melalui Email', ''];
  List<String> icons = ['assets/icons/lupa_password/key.png', 'assets/icons/lupa_password/email-sent.png', 'assets/icons/lupa_password/password.png'];

  // Step 0 — Email
  final TextEditingController _emailController = TextEditingController();

  // Step 1 — OTP (6 kolom)
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  // Step 2 — Password baru
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(LupaPasswordController());
    // Kontrol backspace OTP:
    // - Field berisi → hapus isinya (1 kali tekan), stay di field ini
    // - Field kosong → pindah + hapus isi field sebelumnya (1 kali tekan)
    for (int i = 0; i < 6; i++) {
      _otpFocusNodes[i].onKeyEvent = (node, event) {
        if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
          if (_otpControllers[i].text.isNotEmpty) {
            _otpControllers[i].clear();
            return KeyEventResult.handled;
          } else if (i > 0) {
            _otpControllers[i - 1].clear(); // hapus digit sebelumnya sekaligus
            _otpFocusNodes[i - 1].requestFocus();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      };
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String get _otpCode => _otpControllers.map((c) => c.text).join();

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password tidak boleh kosong';
    if (value.length < 8) return 'Password minimal 8 karakter';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Konfirmasi password tidak boleh kosong';
    if (value != _passwordController.text) return 'Password tidak cocok';
    return null;
  }

  Future<void> _handleLanjutkan() async {
    if (!_formKey.currentState!.validate()) return;

    if (currentStep == 0) {
      final success = await _controller.sendOtp(_emailController.text.trim());
      if (success) setState(() => currentStep = 1);
    } else if (currentStep == 1) {
      final success = await _controller.verifyOtp(_otpCode);
      if (success) setState(() => currentStep = 2);
    } else if (currentStep == 2) {
      final success = await _controller.resetPassword(_passwordController.text);
      if (success) Get.offAllNamed('/login');
    }
  }

  Future<void> _handleResendOtp() async {
    final email = _controller.savedEmail ?? _emailController.text.trim();
    if (email.isEmpty) return;
    // Reset OTP fields
    for (final c in _otpControllers) {
      c.clear();
    }
    await _controller.sendOtp(email);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            if (currentStep > 0) {
              setState(() => currentStep--);
            } else {
              Navigator.pop(context);
            }
          },
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
      ),
      body: Center(
        heightFactor: 0.75,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon animasi
                SizedBox(
                  height: 80,
                  width: 80,
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      border: Border.all(color: SiwattColors.primarySoft, width: 2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 1500),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        final isEntering = child.key == ValueKey(currentStep);
                        final offsetTween = isEntering
                            ? Tween<Offset>(begin: const Offset(2.5, 0.0), end: Offset.zero)
                            : Tween<Offset>(begin: const Offset(-2.5, 0.0), end: Offset.zero);
                        return SlideTransition(
                          position: offsetTween.animate(CurvedAnimation(parent: animation, curve: Curves.easeInOutBack)),
                          child: child,
                        );
                      },
                      child: Image.asset(icons[currentStep], key: ValueKey(currentStep), fit: BoxFit.contain),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  headerTitle[currentStep],
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                ),
                if (headerSubtitle[currentStep].isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(headerSubtitle[currentStep], style: textStyle.bodyLarge?.copyWith(color: Colors.white)),
                ],

                // ── Step 0: Input Email ──
                if (currentStep == 0) ...[
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Text("Email", style: textStyle.bodyLarge?.copyWith(color: Colors.white)),
                      const Spacer(),
                    ],
                  ),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleLanjutkan(),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Email tidak boleh kosong' : null,
                    decoration: const InputDecoration(hintText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Text("Kami akan mengirimkan kode verifikasi ke emailmu", style: const TextStyle(fontSize: 10, color: Colors.white)),
                      const Spacer(),
                    ],
                  ),
                ],

                // ── Step 1: Input OTP ──
                if (currentStep == 1) ...[
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 50,
                        child: TextFormField(
                          controller: _otpControllers[index],
                          focusNode: _otpFocusNodes[index],
                          autofocus: index == 0,
                          // Smart focus: tap selalu redirect ke kotak pertama yang kosong
                          onTap: () {
                            final nextEmpty = _otpControllers.indexWhere((c) => c.text.isEmpty);
                            final target = nextEmpty == -1 ? 5 : nextEmpty;
                            if (target != index) _otpFocusNodes[target].requestFocus();
                          },
                          onChanged: (value) {
                            // Maju ke field berikutnya saat digit diisi
                            if (value.length == 1 && index < 5) {
                              _otpFocusNodes[index + 1].requestFocus();
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
                            // Semua state border disamakan agar tidak ada perubahan visual saat focus
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                        ),
                      );
                    }),
                  ),
                  // Error label OTP — satu FormField untuk seluruh row
                  FormField<String>(
                    validator: (_) => _otpCode.length < 6 ? 'Masukkan 6 digit kode OTP' : null,
                    builder: (field) => field.hasError
                        ? Padding(
                            padding: const EdgeInsets.only(top: 8, left: 4),
                            child: Text(
                              field.errorText!,
                              style: TextStyle(color: colorScheme.error, fontSize: 12),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 24),
                ],
                // ── Step 2: Buat Password Baru ──
                if (currentStep == 2) ...[
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Text('Password Baru', style: textStyle.titleMedium?.copyWith(color: Colors.white)),
                      const Spacer(),
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
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('Ulangi Password', style: textStyle.titleMedium?.copyWith(color: Colors.white)),
                      const Spacer(),
                    ],
                  ),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    textInputAction: TextInputAction.done,
                    validator: _validateConfirmPassword,
                    onFieldSubmitted: (_) => _handleLanjutkan(),
                    decoration: InputDecoration(
                      hintText: 'Ulangi Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                const SizedBox(height: 12),
                Obx(() {
                  final isLoading = _controller.isLoading.value;
                  return ElevatedButton(
                    onPressed: isLoading ? null : _handleLanjutkan,
                    child: isLoading
                        ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : Text(currentStep == 2 ? 'Simpan Password' : 'Lanjutkan', style: textStyle.headlineLarge?.copyWith(color: Colors.white)),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
