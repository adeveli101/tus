import 'package:flutter/material.dart';

class PreferenceSimulationPage extends StatelessWidget {
  const PreferenceSimulationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Tercih Simülasyonu'),
      ),
      body: const Center(
        child: Text('Tercih Simülasyonu Sayfası'),
      ),
    );
  }
} 