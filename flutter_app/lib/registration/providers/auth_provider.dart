import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  String? _username;

  String? get username => _username;
  bool get isLoggedIn => _username != null && _username!.isNotEmpty;

  void login(String username) {
    _username = username;
    notifyListeners();
  }

  void logout() {
    _username = null;
    notifyListeners();
  }
}
