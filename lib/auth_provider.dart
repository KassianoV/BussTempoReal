import 'package:flutter/material.dart';

enum UserType { student, driver, none }

class AuthProvider extends ChangeNotifier {
  UserType _userType = UserType.none;

  UserType get userType => _userType;

  void setUserType(UserType type) {
    _userType = type;
    notifyListeners();
  }

  void logout() {
    _userType = UserType.none;
    notifyListeners();
  }
}
