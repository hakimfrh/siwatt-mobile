import 'package:flutter/material.dart';

class TokenPage extends StatelessWidget {
  const TokenPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Riwayat Pembelian Token")),
      body: const Center(child: Text("Token History Here")),
    );
  }
}
