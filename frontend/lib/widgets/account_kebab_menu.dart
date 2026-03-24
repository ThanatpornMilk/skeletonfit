import 'package:flutter/material.dart';

class AccountKebabMenu extends StatelessWidget {
  const AccountKebabMenu({
    super.key,
    required this.username,
    required this.email,
    required this.isAdmin,
    required this.onLogout,
    this.onManageExercises,
  });

  final String username;
  final String email;
  final bool isAdmin;

  final VoidCallback onLogout;
  final VoidCallback? onManageExercises;

  static const int _actAccount = 1;
  static const int _actAdminManageExercises = 3;
  static const int _actLogout = 9;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      color: const Color(0xFF222222),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      icon: const Icon(Icons.more_vert, color: Colors.white),
      onSelected: (value) async {
        switch (value) {
          case _actAccount:
            _showAccountSheet(context);
            break;

          case _actAdminManageExercises:
            // ✅ เปิดหน้า admin_manage_exercises_screen.dart
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context, rootNavigator: true)
                  .pushNamed('/admin_exercises');
            });
            break;

          case _actLogout:
            onLogout();
            break;
        }
      },
      itemBuilder: (ctx) {
        final items = <PopupMenuEntry<int>>[];

        // Header (disabled)
        items.add(
          const PopupMenuItem<int>(
            enabled: false,
            child: Text(
              'Account Menu',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );

        // Account Info
        items.add(
          const PopupMenuItem<int>(
            value: _actAccount,
            child: Row(
              children: [
                Icon(Icons.person_outline, color: Colors.white70),
                SizedBox(width: 12),
                Text('Account Info', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        );

        // ✅ เฉพาะ admin เท่านั้นที่เห็นเมนูนี้
        if (isAdmin) {
          items.add(
            const PopupMenuItem<int>(
              value: _actAdminManageExercises,
              child: Row(
                children: [
                  Icon(Icons.fitness_center, color: Colors.white70),
                  SizedBox(width: 12),
                  Text('Manage Exercises',
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          );
        }

        // Logout
        items.add(
          const PopupMenuItem<int>(
            value: _actLogout,
            child: Row(
              children: [
                Icon(Icons.logout, color: Colors.white70),
                SizedBox(width: 12),
                Text('Logout', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        );

        return items;
      },
    );
  }

  // bottom sheet แสดงข้อมูลบัญชี
  void _showAccountSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Account Info',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _infoRow(Icons.person, username),
            const SizedBox(height: 8),
            _infoRow(Icons.email_outlined, email),
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close', style: TextStyle(color: Colors.white70)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white70),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
