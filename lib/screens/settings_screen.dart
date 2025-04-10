import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sponsor_karo/components/base/splash_screen.dart';
import 'package:sponsor_karo/screens/user_profile.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? _currentUsername;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    try {
      final userEmail = _firebaseAuth.currentUser?.email;
      if (userEmail == null) throw Exception("User not logged in");

      final username = userEmail.split('@').first.toLowerCase();

      setState(() {
        _currentUsername = username;
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: colorScheme.surface,
      ),
      body:
          _currentUsername == null
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.logout),
                      label: const Text("Logout"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.error,
                        foregroundColor: colorScheme.onError,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SplashScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.person),
                      label: const Text("View My Profile"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => UserProfileScreen(
                                  username: _currentUsername!,
                                ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
    );
  }
}
