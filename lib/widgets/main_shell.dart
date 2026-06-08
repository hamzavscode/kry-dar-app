import 'package:flutter/material.dart';

import '../screens/owner_home_screen.dart';
import '../screens/renter_home_screen.dart';
import '../screens/groups_screen.dart';
import '../screens/messages_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/add_house_screen.dart';
import 'bottom_nav_bar.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.role});

  final String role;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  void _onTabChanged(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      _HomeOverview(
        role: widget.role,
        onNavigate: _onTabChanged,
      ),
      widget.role == 'owner'
          ? const OwnerHomeScreen()
          : const RenterHomeScreen(),
      const GroupsScreen(),
      const MessagesScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavBar(
        activeIndex: _currentIndex,
        onTap: _onTabChanged,
      ),
    );
  }
}

class _HomeOverview extends StatelessWidget {
  const _HomeOverview({required this.role, required this.onNavigate});
  final String role;
  final Function(int) onNavigate;

  @override
  Widget build(BuildContext context) {
    final isOwner = role == 'owner';

    return Scaffold(
      backgroundColor: const Color(0xFFF5ECD7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3D7A8A).withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.home,
                        size: 24, color: Color(0xFF3D7A8A)),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Kri Dar.Koum',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6B2D0E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                isOwner
                    ? 'Mrhba bik, mol dar! 🏠'
                    : 'Mrhba bik! 9lleb 3la dar li bghiti 🔍',
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF5A4A38),
                ),
              ),

              const SizedBox(height: 30),

              if (isOwner) ...[
                _QuickCard(
                  icon: Icons.add_home_outlined,
                  title: 'Zid dar jdida',
                  subtitle: 'Ajouter une maison pour la louer',
                  color: const Color(0xFFD4845A),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddHouseScreen()),
                    );
                  },
                ),
                const SizedBox(height: 14),
                _QuickCard(
                  icon: Icons.home_work_outlined,
                  title: 'Dyour dyali',
                  subtitle: 'Gérer vos annonces immobilières',
                  color: const Color(0xFF3D7A8A),
                  onTap: () => onNavigate(1),
                ),
              ] else ...[
                _QuickCard(
                  icon: Icons.search,
                  title: '9lleb 3la dar',
                  subtitle: 'Chercher dans les maisons proches',
                  color: const Color(0xFF3D7A8A),
                  onTap: () => onNavigate(1),
                ),
                const SizedBox(height: 14),
                _QuickCard(
                  icon: Icons.group_outlined,
                  title: 'Les groupes dyali',
                  subtitle: 'Chouf les groupes li dkhlti lihom',
                  color: const Color(0xFFD4845A),
                  onTap: () => onNavigate(2),
                ),
              ],

              const SizedBox(height: 30),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0E6D0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lightbulb_outline,
                            size: 20, color: Color(0xFFD4845A)),
                        SizedBox(width: 8),
                        Text(
                          'Conseil',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D2D2D),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isOwner
                          ? 'Zid tssawer zwnin dyal dar dyalek bach tjlb les locataires bzzaf!'
                          : 'Dir l\'filtre bach t9lleb ghir 3la dyour li f la fourchette dyal l\'budget dyalek.',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF5A4A38),
                        height: 1.5,
                      ),
                    ),
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

class _QuickCard extends StatelessWidget {
  const _QuickCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 16, color: Colors.white.withOpacity(0.6)),
          ],
        ),
      ),
    );
  }
}
