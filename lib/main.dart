import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/lesson_progress_provider.dart';
import 'pages/splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => LessonProgressProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

// **<-- UPDATED WIDGET: AuthWrapper -->**
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeAppAndCheckAuth();
  }

  Future<void> _initializeAppAndCheckAuth() async {
    // Keep your initial splash screen logic
    await Future.delayed(const Duration(seconds: 5));

    // Listen to authentication changes and update the UI
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted) {
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });
        // Now, trigger the progress load based on the new user state
        if (user != null) {
          Provider.of<LessonProgressProvider>(context, listen: false).loadCompletedLessons();
        } else {
          Provider.of<LessonProgressProvider>(context, listen: false).clearProgress();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SplashPage();
    }

    if (_currentUser != null) {
      return const HomePage();
    } else {
      return const LoginPage();
    }
  }
}