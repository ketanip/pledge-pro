import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sponsor_karo/components/forms/post_form.dart';
import 'package:sponsor_karo/screens/analytics_screen.dart';
import 'package:sponsor_karo/screens/chats_screen.dart';
import 'package:sponsor_karo/screens/home_screen.dart';
import 'package:sponsor_karo/screens/search_screen.dart';
import 'package:sponsor_karo/screens/settings_screen.dart';
import 'package:sponsor_karo/screens/transactions_screen.dart';
import 'package:sponsor_karo/services/public_profile_service.dart';
import 'package:sponsor_karo/state/user_provider.dart';
import 'package:sponsor_karo/theme_provider.dart';

class ScreensPage extends StatefulWidget {
  const ScreensPage({super.key});

  @override
  _ScreensPageState createState() => _ScreensPageState();
}

class _ScreensPageState extends State<ScreensPage> {
  int _selectedIndex = 0;
  late List<Widget> _screens;
  final _firebaseAuth = FirebaseAuth.instance;
  final _publicProfileService = PublicProfileService();

  @override
  void initState() {
    super.initState();

    _screens = [
      HomeScreen(),
      AnalyticsPage(),
      SearchPage(),
      DonationsScreen(),
      SettingsPage(),
    ];

    initRun();
  }

  void initRun() async {
    await PublicProfileService().createPublicProfile();
    final uid = _firebaseAuth.currentUser?.uid ?? "";
    final currentUserPublicProfile = await _publicProfileService.getPublicProfileBySub(uid);
    Provider.of<UserProvider>(context, listen: false).setUser(currentUserPublicProfile);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: _buildAppBar(context, theme),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        height: 65,
        backgroundColor: colorScheme.surface, // Uses surface for a cleaner look
        selectedIndex: _selectedIndex,
        indicatorColor: colorScheme.primary.withAlpha(26), // Subtle indicator
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [
          _buildNavItem(
            Icons.home_outlined,
            Icons.home,
            "Home",
            0,
            colorScheme,
          ),
          _buildNavItem(
            Icons.analytics_outlined,
            Icons.analytics,
            "Analytics",
            1,
            colorScheme,
          ),
          _buildNavItem(
            Icons.search_outlined,
            Icons.search,
            "Search",
            2,
            colorScheme,
          ),
          _buildNavItem(
            Icons.attach_money_outlined,
            Icons.attach_money,
            "Donations",
            3,
            colorScheme,
          ),
          _buildNavItem(
            Icons.settings_outlined,
            Icons.settings,
            "Settings",
            4,
            colorScheme,
          ),
        ],
      ),
    );
  }

  // 🔹 Builds the AppBar with theme toggle
  AppBar _buildAppBar(BuildContext context, ThemeData theme) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      leading: Padding(
        padding: EdgeInsets.only(left: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_fire_department_rounded,
              color: theme.colorScheme.primary,
            ),
            SizedBox(width: 2),
            Text(
              "ProPledge",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      leadingWidth: 150,
      actions: [
        IconButton(
          icon: Icon(
            themeProvider.themeMode == ThemeMode.dark
                ? Icons.light_mode
                : Icons.dark_mode,
            color: theme.iconTheme.color,
          ),
          onPressed: () {
            themeProvider.toggleTheme();
          },
        ),

        IconButton(
          icon: Icon(Icons.add_box_outlined, color: theme.iconTheme.color),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreatePostForm()),
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.chat_bubble_outline, color: theme.iconTheme.color),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatListScreen()),
            );
          },
        ),
        SizedBox(width: 10),
      ],
    );
  }

  // 🔹 Builds Navigation Bar Items
  NavigationDestination _buildNavItem(
    IconData icon,
    IconData selectedIcon,
    String label,
    int index,
    ColorScheme colorScheme,
  ) {
    return NavigationDestination(
      icon: Icon(
        icon,
        color:
            _selectedIndex == index
                ? colorScheme.primary
                : colorScheme.onSurface,
      ),
      selectedIcon: Icon(selectedIcon, color: colorScheme.primary),
      label: label,
    );
  }
}
