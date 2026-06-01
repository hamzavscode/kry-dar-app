import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/current_user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final CurrentUserService _userService = CurrentUserService();

  String _fullName = '';
  String _phone = '';
  String _role = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final doc = await _userService.getCurrentUserDoc();
    if (doc != null && mounted) {
      setState(() {
        _fullName = (doc['fullName'] as String?) ?? 'Utilisateur';
        _phone = (doc['phoneNumber'] as String?) ?? '';
        _role = (doc['role'] as String?) ?? 'renter';
        _loading = false;
      });
    } else if (mounted) {
      setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5ECD7),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF3D7A8A))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5ECD7),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Header with watercolor-style gradient ──────────────
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFD4E8C8),
                      Color(0xFFF5ECD7),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    // Top bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.settings_outlined,
                                size: 20, color: Color(0xFF2D2D2D)),
                          ),
                          const Expanded(
                            child: Center(
                              child: Text(
                                'الملف الشخصي',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D2D2D),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 36),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Avatar
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF3D7A8A).withOpacity(0.3),
                          width: 3,
                        ),
                        color: const Color(0xFF3D7A8A).withOpacity(0.1),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 48,
                        color: Color(0xFF3D7A8A),
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Name
                    Text(
                      _fullName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Phone
                    Text(
                      _phone,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF5A4A38),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Role toggle
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0E6D0),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _RoleChip(
                            label: 'مالك',
                            isActive: _role == 'owner',
                          ),
                          _RoleChip(
                            label: 'مستأجر',
                            isActive: _role == 'renter',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // ── Menu items ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _MenuItem(
                      icon: Icons.person_outline,
                      label: 'معلوماتي الشخصية',
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: Icons.bookmark_border,
                      label: 'إعلاناتي المحفوظة',
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: Icons.notifications_none,
                      label: 'الإشعارات',
                      onTap: () {},
                    ),
                    _MenuItem(
                      icon: Icons.help_outline,
                      label: 'الدعم والمساعدة',
                      onTap: () {},
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFFCCBBA0)),
                    const SizedBox(height: 8),
                    // Logout
                    GestureDetector(
                      onTap: _logout,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: const Row(
                          children: [
                            Icon(Icons.logout, size: 22, color: Color(0xFFD32F2F)),
                            SizedBox(width: 14),
                            Text(
                              'تسجيل الخروج',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFD32F2F),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  const _RoleChip({required this.label, required this.isActive});
  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF3D7A8A) : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.white : const Color(0xFF9A8070),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFE8D8C0), width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: const Color(0xFF5A4A38)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF2D2D2D),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: Color(0xFF9A8070)),
          ],
        ),
      ),
    );
  }
}
