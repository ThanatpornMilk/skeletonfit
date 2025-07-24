import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFF181717),
      body: Container(
        decoration: _buildBackgroundGradient(),
        child: Stack(
          children: [
            _buildBackgroundEffects(),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    _buildAppBar(context),
                    const SizedBox(height: 24),
                    _buildProfileHeader(),
                    const SizedBox(height: 24),
                    _buildInfoSection(),
                    const SizedBox(height: 32),
                    _buildActionButtons(context),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // AppBar
  Widget _buildAppBar(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 8),
        const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Profile Image + Name
  Widget _buildProfileHeader() {
    return Column(
      children: const [
        CircleAvatar(
          radius: 50,
          backgroundColor: Color.fromRGBO(255, 255, 255, 0.24),
          child: Icon(
            Icons.person,
            color: Color.fromRGBO(255, 255, 255, 0.7),
            size: 50,
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Your Name',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'example@email.com',
          style: TextStyle(
            color: Color.fromRGBO(255, 255, 255, 0.6),
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  // ข้อมูลส่วนตัว
  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _InfoTile(title: 'วันเกิด', value: '1 มกราคม 1995'),
        _InfoTile(title: 'น้ำหนัก', value: '70 kg'),
        _InfoTile(title: 'ส่วนสูง', value: '175 cm'),
        _InfoTile(title: 'เป้าหมาย', value: 'ลดน้ำหนัก'),
      ],
    );
  }

  // ปุ่มฟังก์ชันต่าง ๆ
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        _ProfileButton(
          icon: Icons.edit,
          label: 'แก้ไขโปรไฟล์',
          onTap: () {
            // TODO: นำไปหน้าแก้ไขโปรไฟล์
          },
        ),
        _ProfileButton(
          icon: Icons.settings,
          label: 'ตั้งค่า',
          onTap: () {
            // TODO: นำไปหน้าตั้งค่า
          },
        ),
        _ProfileButton(
          icon: Icons.logout,
          label: 'ออกจากระบบ',
          onTap: () {
            // TODO: ทำการ logout
          },
          color: Colors.redAccent,
        ),
      ],
    );
  }

  // พื้นหลังไล่สี
  BoxDecoration _buildBackgroundGradient() => const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF181717),
            Color(0xFF181717),
            Color(0xFF181717),
          ],
        ),
      );

  // วงแสง background
  Widget _buildBackgroundEffects() {
    return Stack(
      children: [
        Positioned(
          top: 100,
          right: -100,
          child: Container(
            width: 280,
            height: 280,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Color.fromRGBO(255, 255, 255, 0.08),
                  Color.fromRGBO(39, 174, 96, 0.01),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: -80,
          child: Container(
            width: 200,
            height: 200,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Color.fromRGBO(255, 255, 255, 0.06),
                  Color.fromRGBO(39, 174, 96, 0.02),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ----------------------------
// Widgets ย่อย
// ----------------------------

class _InfoTile extends StatelessWidget {
  final String title;
  final String value;

  const _InfoTile({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            '$title: ',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color.fromRGBO(255, 255, 255, 0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ProfileButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: color ?? const Color.fromRGBO(255, 255, 255, 0.1),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Row(
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
