import 'package:flutter/material.dart';

class PreferenceListPage extends StatelessWidget {
  const PreferenceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tercih Listem'),
      ),
      body: const Center(
        child: Text('Tercih Listem Sayfası'),
      ),
    );
  }
} 