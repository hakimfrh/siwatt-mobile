import 'package:flutter/material.dart';

class LupaPassword extends StatefulWidget {
  const LupaPassword({super.key});

  @override
  State<LupaPassword> createState() => _LupaPasswordState();
}

class _LupaPasswordState extends State<LupaPassword> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textStyle = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {},
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
                'Lupa Password',
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text("Masukkan Email Untuk Melanjutkan", style: textStyle.bodyLarge?.copyWith(color: Colors.white)),
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
              ElevatedButton(
                onPressed: () {},
                child: Text('Lanjutkan', style: textStyle.headlineLarge?.copyWith(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
