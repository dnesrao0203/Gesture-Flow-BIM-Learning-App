import 'package:flutter/material.dart';


class SplashPage extends StatelessWidget {
  const SplashPage({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3F4F6),
      body: Center(
        child: Image.asset(
          "assets/images/logo.png",
          width: 350,
        ),
      ),
    );
  }
}


