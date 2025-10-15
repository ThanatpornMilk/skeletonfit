import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  int? _userId;
  int? get userId => _userId;

  void setUser(int id) {
    _userId = id;
    notifyListeners();
  }

  void clearUser() {
    _userId = null;
    notifyListeners();
  }
}
