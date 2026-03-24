import 'package:flutter/foundation.dart';

class UserProvider with ChangeNotifier {
  int? _userId;
  String? _username;
  String? _email;
  String _role = 'user'; // 'user' | 'admin'

  // Getters
  int? get userId => _userId;
  String? get username => _username;
  String? get email => _email;
  String get role => _role;
  bool get isAdmin => _role.toLowerCase() == 'admin';

  // ตั้งค่าทีละส่วน
  void setUserId(int? id) {
    _userId = id;
    notifyListeners();
  }

  void setProfile({String? username, String? email}) {
    _username = username ?? _username;
    _email = email ?? _email;
    notifyListeners();
  }

  void setRole(String? role) {
    if (role != null && role.isNotEmpty) {
      _role = role.toLowerCase() == 'admin' ? 'admin' : 'user';
      notifyListeners();
    }
  }

  /// ตั้งค่าจาก map ที่ได้จาก backend
  /// รองรับ key: user_id, username, email, role
  void setFromMap(Map<String, dynamic> user) {
    _userId = user['user_id'] is int
        ? user['user_id'] as int
        : int.tryParse('${user['user_id']}');

    _username = user['username']?.toString();
    _email = user['email']?.toString();

    final r = user['role']?.toString().toLowerCase();
    _role = (r == 'admin' || r == 'user') ? r! : 'user';

    notifyListeners();
  }

  /// ตั้งชุดเดียวตอนล็อกอินสำเร็จ
  void setUser({
    required int id,
    required String username,
    required String email,
    String role = 'user',
  }) {
    _userId = id;
    _username = username;
    _email = email;
    _role = role.toLowerCase() == 'admin' ? 'admin' : 'user';
    notifyListeners();
  }

  /// เคลียร์ทั้งหมดตอนล็อกเอาท์
  void clearUser() {
    _userId = null;
    _username = null;
    _email = null;
    _role = 'user';
    notifyListeners();
  }
}
