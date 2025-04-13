import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sponsor_karo/screens/screens_page.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw Exception("Google Sign-In cancelled");
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final creds = await _firebaseAuth.signInWithCredential(credential);
      final displayName = creds.user?.displayName;
      if (displayName != null) {
        Fluttertoast.showToast(msg: 'Welcome $displayName!!!');
      } else {
        Fluttertoast.showToast(msg: 'Welcome!!!');
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ScreensPage()),
      );
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 30,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_fire_department_rounded,
                  color: theme.colorScheme.primary,
                  size: 46,
                ),
                const SizedBox(width: 10),
                Text(
                  "ProPledge",
                  style: GoogleFonts.roboto(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface, // Themed Text Color
                  ),
                ),
              ],
            ),

            GestureDetector(
              onTap: signInWithGoogle,
              child: SvgPicture.asset(
                theme.brightness == Brightness.light
                    ? "images/auth/login-with-google-light.svg"
                    : "images/auth/login-with-google-dark.svg",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
