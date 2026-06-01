import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/current_user_service.dart';
import '../services/firestore_houses_service.dart';
import 'add_house_screen.dart';

class OwnerHomeScreen extends StatelessWidget {
  const OwnerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserService = CurrentUserService();
    final housesService = FirestoreHousesService();

    return Scaffold(
      backgroundColor: const Color(0xFFF5ECD7),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                children: [
                  const Icon(
                    Icons.home_outlined,
                    size: 28,
                    color: Color(0xFF2D2D2D),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Owner panel',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 28),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddHouseScreen(),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(double.infinity, 52),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Ajouter une nouvelle maison',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Mes Maisons',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: FutureBuilder<String?>(
                future: Future.value(FirebaseAuth.instance.currentUser?.uid),
                builder: (context, userSnap) {
                  if (userSnap.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final String? ownerId = userSnap.data;

                  // Number of active groups (try both camelCase and snake_case keys)
                  // to avoid null / type cast issues with Firestore map data.

                  if (ownerId == null) {
                    return const Center(child: Text('Vous devez vous connecter.'));
                  }

                  debugPrint('OwnerHomeScreen ownerId=$ownerId');
                  return FutureBuilder<List<Map<String, dynamic>>>(
                    future: housesService.getHousesByOwner(ownerId: ownerId),

                    builder: (context, snap) {
                      if (snap.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final houses = snap.data ?? [];
                      if (houses.isEmpty) {
                        return Center(
                          child: Text(
                            'Aucune maison ajoutée (ownerId: $ownerId)',
                            style: const TextStyle(color: Color(0xFF9A8070), fontSize: 15),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }


                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: houses.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final house = houses[index];
                          return _HouseCard(house: house);
                        },
                      );
                    },
                  );
                },
              ),
            ),

          ],
        ),
      ),
    );
  }
}

class _HouseCard extends StatelessWidget {
  const _HouseCard({required this.house});
  final Map<String, dynamic> house;

  @override
  Widget build(BuildContext context) {
    final bool isAvailable = (house['status'] as String?) == 'disponible';
    final images = (house['images'] as List?)?.cast<String>() ?? [];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0E6D0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: images.isNotEmpty
                ? SizedBox(
                    width: 120,
                    height: 110,
                    child: Stack(
                      children: [
                        // First image (base)
                        Positioned.fill(
                          child: Image.network(
                            images[0],
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFFCCBBA0),
                              child: const Icon(
                                Icons.home,
                                size: 40,
                                color: Colors.white54,
                              ),
                            ),
                          ),
                        ),
                        // Second image shifted to the right
                        if (images.length > 1)
                          Positioned(
                            top: 0,
                            bottom: 0,
                            left: 18,
                            right: -18,
                            child: Image.network(
                              images[1],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                            ),
                          ),
                        // Third image shifted further to the right
                        if (images.length > 2)
                          Positioned(
                            top: 0,
                            bottom: 0,
                            left: 36,
                            right: -36,
                            child: Image.network(
                              images[2],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                            ),
                          ),
                      ],
                    ),
                  )
                : Container(
                    width: 120,
                    height: 110,
                    color: const Color(0xFFCCBBA0),
                    child: const Icon(
                      Icons.home,
                      size: 40,
                      color: Colors.white54,
                    ),
                  ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (house['rue_quartier'] as String?) ?? 'Maison',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${house["prix_mensuel"] ?? 0} dh/mois',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF5A4A38),
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (isAvailable)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4F0D4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'disponnible',
                        style: TextStyle(
                          color: Color(0xFF2E8B2E),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  else
                    const Text(
                      'hors-service',
                      style: TextStyle(
                        color: Color(0xFFB03060),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  const SizedBox(height: 8),

                  // compute groupes active count and render appropriate widget
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

