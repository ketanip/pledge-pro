import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sponsor_karo/theme_provider.dart';
import 'package:sponsor_karo/state/user_provider.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sponsor_karo/components/base/splash_screen.dart';
import 'package:sponsor_karo/theme.dart';
import 'package:sponsor_karo/util.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const PledgeProApp());
}

class PledgeProApp extends StatelessWidget {
  const PledgeProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ), // ✅ Add user provider
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          TextTheme textTheme = createTextTheme(
            context,
            "Roboto Flex",
            "Roboto",
          );
          MaterialTheme theme = MaterialTheme(textTheme);

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'ProPledge',
            theme: theme.light(),
            darkTheme: theme.dark(),
            themeMode: themeProvider.themeMode,
            home: SplashScreen(),
          );
        },
      ),
    );
  }
}
