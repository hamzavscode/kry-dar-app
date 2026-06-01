import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/filter_screen.dart';
import 'widgets/main_shell.dart';


import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const KriDarKoumApp());
}

class KriDarKoumApp extends StatelessWidget {
  const KriDarKoumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kri Dar.Koum',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'serif'),
      home: const OnboardingScreen(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/filter': (_) => const FilterScreen(),
      },
    );
  }
}


class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF5ECD7),
      body: Stack(
        children: [
          // ── Background arch + lantern (Image 1) ─────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight * 0.40,
            child: Image.asset(
              'assets/images/arch_background.png',
              fit: BoxFit.cover,
            ),
          ),

          // ── Main scrollable content ───────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Title area (sits inside the arch region)
                SizedBox(height: screenHeight * 0.05),
                const Text(
                  'Kri Dar.Koum',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B2D0E),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Kri darek o henni ballek',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF5A4A38),
                    fontWeight: FontWeight.w400,
                  ),
                ),

                // ── Moroccan door illustration (Image 2) ─────────────
                SizedBox(height: screenHeight * 0.02),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Image.asset(
                        'assets/images/moroccan_door.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                // ── Role selector ────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: Text(
                    'Khedam wla baghi tskon?',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.brown.shade600,
                    ),
                  ),
                ),

                // Owner button
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 6,
                  ),
                  child: _RoleButton(
                    icon: Icons.home_outlined,
                    tag: 'OWNER',
                    title: 'Nta mol Dar?',
                    subtitle: 'Douz hna w kriha',
                    color: const Color(0xFFD4845A),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SignupScreen(role: 'owner'),
                        ),
                      );
                    },
                  ),
                ),

                // Renter button
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 6, 24, 32),
                  child: _RoleButton(
                    icon: Icons.apartment_outlined,
                    tag: 'RENTER',
                    title: 'Kat9eleb 3la dar?',
                    subtitle: 'Dkhul hna 9alleb 3liha',
                    color: const Color(0xFF3D7A8A),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SignupScreen(role: 'renter'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  const _RoleButton({
    required this.icon,
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String tag;
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Icon circle with tag
            Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white54, width: 1.5),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(height: 2),
                Text(
                  tag,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 9,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Text
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

