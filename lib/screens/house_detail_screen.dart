import 'package:flutter/material.dart';

import 'house_rented_screen.dart';
import 'house_groups_screen.dart';

/// Full detail view of a house listing for renters.
class HouseDetailScreen extends StatelessWidget {
  const HouseDetailScreen({super.key, required this.house});

  final Map<String, dynamic> house;

  @override
  Widget build(BuildContext context) {
    final images = (house['images'] as List?)?.cast<String>() ?? [];
    final price = house['prix_mensuel'] ?? 0;
    final quartier = (house['rue_quartier'] as String?) ?? 'Quartier';
    final ville = (house['ville'] as String?) ?? '';
    final description = (house['description'] as String?) ?? '';
    final ownerName = (house['ownerName'] as String?) ?? 'Propriétaire';
    final nombreChambres = house['nombre_chambres'] ?? 0;
    final nombreMax = house['nombre_max'] ?? 0;
    final status = (house['status'] as String?) ?? 'disponible';

    final bool wifi = house['wifi'] == true;
    final bool cuisine = house['cuisine'] == true;
    final bool garage = house['garage'] == true;
    final bool machineLaver = house['machine_laver'] == true;

    // If house is rented, show the rented screen
    if (status != 'disponible') {
      return const HouseRentedScreen();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5ECD7),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                // ── Image Gallery ──────────────────────────────────────
                SliverAppBar(
                  expandedHeight: 280,
                  pinned: true,
                  backgroundColor: const Color(0xFFF5ECD7),
                  leading: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.85),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          size: 18, color: Color(0xFF2D2D2D)),
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: images.isNotEmpty
                        ? PageView.builder(
                            itemCount: images.length,
                            itemBuilder: (context, index) {
                              return Image.network(
                                images[index],
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: const Color(0xFFCCBBA0),
                                  child: const Icon(Icons.home,
                                      size: 60, color: Colors.white54),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: const Color(0xFFCCBBA0),
                            child: const Icon(Icons.home,
                                size: 60, color: Colors.white54),
                          ),
                  ),
                ),

                // ── Details ────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Location & Price row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on,
                                          size: 18, color: Color(0xFF3D7A8A)),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          '$quartier, $ville',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF2D2D2D),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD4845A),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$price MAD',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),
                        Text(
                          '/mois',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.brown.shade400,
                          ),
                        ),

                        const SizedBox(height: 20),
                        const Divider(color: Color(0xFFCCBBA0)),
                        const SizedBox(height: 16),

                        // Owner info
                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: const Color(0xFF3D7A8A).withOpacity(0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.person,
                                  size: 22, color: Color(0xFF3D7A8A)),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ownerName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2D2D2D),
                                  ),
                                ),
                                const Text(
                                  'Propriétaire',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF9A8070),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        const Divider(color: Color(0xFFCCBBA0)),
                        const SizedBox(height: 16),

                        // Room info chips
                        Row(
                          children: [
                            _InfoChip(
                              icon: Icons.bed_outlined,
                              label: '$nombreChambres chambres',
                            ),
                            const SizedBox(width: 10),
                            _InfoChip(
                              icon: Icons.group_outlined,
                              label: 'Max $nombreMax',
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Equipment
                        if (wifi || cuisine || garage || machineLaver) ...[
                          const Text(
                            'Équipements',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D2D2D),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              if (wifi) const _EquipChip(icon: Icons.wifi, label: 'Wifi'),
                              if (cuisine)
                                const _EquipChip(
                                    icon: Icons.restaurant, label: 'Cuisine'),
                              if (garage)
                                const _EquipChip(
                                    icon: Icons.garage_outlined, label: 'Garage'),
                              if (machineLaver)
                                const _EquipChip(
                                    icon: Icons.local_laundry_service_outlined,
                                    label: 'Machine à laver'),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Description
                        if (description.isNotEmpty) ...[
                          const Divider(color: Color(0xFFCCBBA0)),
                          const SizedBox(height: 16),
                          const Text(
                            'Description',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D2D2D),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF5A4A38),
                              height: 1.5,
                            ),
                          ),
                        ],

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom Group Actions ───────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            decoration: const BoxDecoration(
              color: Color(0xFFF5ECD7),
              border: Border(top: BorderSide(color: Color(0xFFDDD0B8), width: 0.8)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 54,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HouseGroupsScreen(house: house),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF3D7A8A), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Créer un groupe',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3D7A8A),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HouseGroupsScreen(house: house),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4845A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Rejoindre un groupe',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
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

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E6D0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF5A4A38)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF5A4A38)),
          ),
        ],
      ),
    );
  }
}

class _EquipChip extends StatelessWidget {
  const _EquipChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF3D7A8A).withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF3D7A8A).withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF3D7A8A)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF3D7A8A),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
