import 'package:flutter/material.dart';

/// Shown when a renter tries to view a house that is no longer available.
class HouseRentedScreen extends StatelessWidget {
  const HouseRentedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5ECD7),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios,
                        size: 20, color: Color(0xFF2D2D2D)),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            const Spacer(),

            // ── Illustration area ────────────────────────────────────
            Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFD4E8C8).withOpacity(0.4),
                    const Color(0xFFF5ECD7),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // House icon with lock
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3D7A8A).withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.home,
                          size: 44,
                          color: Color(0xFF3D7A8A),
                        ),
                      ),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4845A),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFF5ECD7), width: 2),
                        ),
                        child: const Icon(Icons.lock, size: 14, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Plants decoration
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.eco, size: 20,
                          color: const Color(0xFF3D7A8A).withOpacity(0.4)),
                      const SizedBox(width: 30),
                      Icon(Icons.eco, size: 20,
                          color: const Color(0xFF3D7A8A).withOpacity(0.4)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Message ──────────────────────────────────────────────
            const Text(
              'تم كراء هذه الدار',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'هذه الدار لم تعد متاحة حالياً\nتصفح بيوت أخرى',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.brown.shade400,
                  height: 1.6,
                ),
              ),
            ),

            const Spacer(),

            // ── CTA Button ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3D7A8A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'العودة للبحث',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
