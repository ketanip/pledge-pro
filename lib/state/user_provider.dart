import 'package:flutter/material.dart';
import 'package:sponsor_karo/models/public_profile.dart';

class UserProvider extends ChangeNotifier {
  PublicProfile? _currentUser;

  PublicProfile? get currentUser => _currentUser;

  void setUser(PublicProfile user) {
    _currentUser = user;
    notifyListeners();
  }

  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }
}
