import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tus/core/firebase/firebase_auth_service.dart';
import 'package:flutter/foundation.dart';

import '../../../../main.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Delay initialization to ensure widget is mounted and has access to context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    try {
      final authService = context.read<FirebaseAuthService>();
      // Anonim giriş yap
      final user = await authService.signInAnonymously();
      if (user != null) {
        if (kDebugMode) {
          print('Anonim giriş başarılı: ${user.uid}');
        }
        
        // 2 saniye bekle
        await Future.delayed(const Duration(seconds: 2));
        
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainPage()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Başlatma hatası: $e');
      }
      // Hata durumunda da ana sayfaya yönlendir
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainPage()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const PopScope(
      canPop: false, // Geri tuşunu devre dışı bırak
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
} 