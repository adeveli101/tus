import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  final Widget? child;
  
  const AppBackground({
    super.key,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/background_tus.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }
} 