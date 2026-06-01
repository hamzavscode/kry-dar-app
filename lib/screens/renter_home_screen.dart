import 'package:flutter/material.dart';
import '../models/filter_params.dart';
import '../services/firestore_houses_service.dart';
import '../services/geolocation_service.dart';
import '../services/current_user_service.dart';
import 'house_detail_screen.dart';

class RenterHomeScreen extends StatefulWidget {
  const RenterHomeScreen({super.key});

  @override
  State<RenterHomeScreen> createState() => _RenterHomeScreenState();
}

class _RenterHomeScreenState extends State<RenterHomeScreen> {
  final GeoLocationService _geo = const GeoLocationService();
  final FirestoreHousesService _houses = FirestoreHousesService();
  final CurrentUserService _currentUser = CurrentUserService();

  String _currentCity = 'Chargement...';

  final TextEditingController _searchController = TextEditingController();

  FilterParams? _filterParams;

  // When filter is applied, we use a Future-based list instead of the stream
  bool _useFilter = false;
  bool _filterLoading = false;
  List<Map<String, dynamic>> _filteredHouses = [];

  double? _userLat;
  double? _userLng;

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    try {
      final pos = await _geo.getCurrentPositionAndCity();
      if (mounted) {
        setState(() {
          _userLat = pos.$1;
          _userLng = pos.$2;
          _currentCity = pos.$3;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _currentCity = 'Localisation indisponible');
      }
      debugPrint('GEOLOCATION ERROR: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openFilter() async {
    final result = await Navigator.pushNamed(context, '/filter');
    if (result is FilterParams) {
      setState(() {
        _filterParams = result;
        _useFilter = true;
        _filterLoading = true;
      });

      final lat = _userLat ?? 0.0;
      final lng = _userLng ?? 0.0;

      final results = await _houses.searchNearbyHouses(
        centerLat: lat,
        centerLng: lng,
        maxDistanceKm: result.maxDistanceKm,
        ville: result.ville,
        quartier: result.quartier,
        minPrice: result.minPrice,
        maxPrice: result.maxPrice,
        minChambres: result.minChambres,
        maxColoc: result.maxColoc,
        groupeOnly: result.groupeOnly,
      );

      if (mounted) {
        setState(() {
          _filteredHouses = results;
          _filterLoading = false;
        });
      }
    }
  }

  void _clearFilter() {
    setState(() {
      _filterParams = null;
      _useFilter = false;
      _filteredHouses = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.home_outlined, size: 26, color: Color(0xFF2D2D2D)),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Trouver une maison',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 26),
                ],
              ),
            ),

            // ── Location ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.location_on, size: 18, color: Color(0xFF3D7A8A)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _currentCity,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2D2D2D),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ── Search bar + filter ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: 'chercher avec ville , avenue ,quartier',
                          hintStyle: TextStyle(fontSize: 12, color: Color(0xFF9A9A9A)),
                          prefixIcon: Icon(Icons.search, size: 18, color: Color(0xFF9A9A9A)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _openFilter,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: _useFilter ? const Color(0xFF3D7A8A) : const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.tune,
                        size: 20,
                        color: _useFilter ? Colors.white : const Color(0xFF2D2D2D),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Active filter indicator ──
            if (_useFilter)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3D7A8A).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.filter_alt, size: 14, color: Color(0xFF3D7A8A)),
                          const SizedBox(width: 4),
                          Text(
                            'Filtre actif: ${_filterParams?.ville ?? ''}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF3D7A8A)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: _clearFilter,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.close, size: 14, color: Colors.red),
                            SizedBox(width: 2),
                            Text('Effacer', style: TextStyle(fontSize: 11, color: Colors.red)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 10),

            // ── Section title ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _useFilter ? 'Résultats filtrés' : 'Maisons disponibles',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ── Houses list ──
            Expanded(
              child: _useFilter
                  ? _buildFilteredList()
                  : _buildStreamList(),
            ),
          ],
        ),
      ),
    );
  }

  /// Real-time stream of ALL available houses (no filter applied)
  Widget _buildStreamList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _houses.streamAvailableHouses(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snap.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 50, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(
                    'Erreur de chargement:\n${snap.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => setState(() {}),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Réessayer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3D7A8A),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final houses = snap.data ?? [];

        if (houses.isEmpty) {
          return const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.home_outlined, size: 60, color: Color(0xFFCCBBA0)),
                SizedBox(height: 12),
                Text(
                  'Aucune maison disponible pour le moment',
                  style: TextStyle(color: Color(0xFF9A8070), fontSize: 14),
                ),
                SizedBox(height: 6),
                Text(
                  'Les nouvelles maisons apparaîtront ici automatiquement',
                  style: TextStyle(color: Color(0xFFBBA88A), fontSize: 12),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            // Stream auto-refreshes, but allow pull-to-refresh for UX
            setState(() {});
          },
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: houses.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _RenterHouseCard(house: houses[index]);
            },
          ),
        );
      },
    );
  }

  /// Filtered list (after user applies a filter)
  Widget _buildFilteredList() {
    if (_filterLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredHouses.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 60, color: Color(0xFFCCBBA0)),
            const SizedBox(height: 12),
            const Text(
              'Aucune maison trouvée avec ces critères',
              style: TextStyle(color: Color(0xFF9A8070), fontSize: 14),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _clearFilter,
              icon: const Icon(Icons.close, size: 16),
              label: const Text('Effacer le filtre'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3D7A8A),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredHouses.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _RenterHouseCard(house: _filteredHouses[index]);
      },
    );
  }
}

class _RenterHouseCard extends StatelessWidget {
  const _RenterHouseCard({required this.house});
  final Map<String, dynamic> house;

  @override
  Widget build(BuildContext context) {
    final images = (house['images'] as List?)?.cast<String>() ?? [];
    final price = house['prix_mensuel'] ?? 0;
    final ville = (house['ville'] as String?) ?? '';
    final quartier = (house['rue_quartier'] as String?) ?? 'Quartier';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HouseDetailScreen(house: house),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image section ──
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: images.isNotEmpty
                  ? SizedBox(
                      width: double.infinity,
                      height: 180,
                      child: Image.network(
                        images[0],
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: const Color(0xFFF0E6D0),
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF3D7A8A),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFCCBBA0),
                          child: const Icon(
                            Icons.home,
                            size: 50,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      width: double.infinity,
                      height: 180,
                      color: const Color(0xFFCCBBA0),
                      child: const Icon(Icons.home, size: 50, color: Colors.white54),
                    ),
            ),

            // ── Info section ──
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Color(0xFF3D7A8A)),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          '$quartier, $ville',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D2D2D),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '$price MAD',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD4845A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // Chambres badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3D7A8A).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bed, size: 12, color: Color(0xFF3D7A8A)),
                            const SizedBox(width: 3),
                            Text(
                              '${house['nombre_chambres'] ?? '-'} ch.',
                              style: const TextStyle(fontSize: 10, color: Color(0xFF3D7A8A)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Max coloc badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4845A).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.people, size: 12, color: Color(0xFFD4845A)),
                            const SizedBox(width: 3),
                            Text(
                              'Max ${house['nombre_max'] ?? '-'}',
                              style: const TextStyle(fontSize: 10, color: Color(0xFFD4845A)),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Owner name
                      Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: const Color(0xFF3D7A8A).withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person, size: 14, color: Color(0xFF3D7A8A)),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            (house['ownerName'] as String?) ?? 'Propriétaire',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF5A4A38)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
