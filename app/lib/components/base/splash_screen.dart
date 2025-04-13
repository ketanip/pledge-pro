import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sponsor_karo/screens/auth_screen.dart';
import 'package:sponsor_karo/screens/screens_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      if (_firebaseAuth.currentUser != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ScreensPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface, // Adaptive Background
      body: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_fire_department_rounded,
              color: theme.colorScheme.primary, // Themed Icon Color
              size: 36,
            ),
            const SizedBox(width: 10),
            Text(
              "ProPledge",
              style: GoogleFonts.roboto(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface, // Themed Text Color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
