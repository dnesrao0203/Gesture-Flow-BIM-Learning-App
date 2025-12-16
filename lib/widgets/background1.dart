import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  final Widget child; // content inside the page

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.45, 1.0],
          colors: [
            Color(0xFF00A5CF), // light blue
            Colors.white,
          ],
        ),
      ),
      child: child,
    );
  }
}