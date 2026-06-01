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

  String _currentCity = 'Ville automatique';

  final TextEditingController _searchController = TextEditingController();

  FilterParams? _filterParams;
  bool _loading = true;
  List<Map<String, dynamic>> _nearbyHouses = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final pos = await _geo.getCurrentPositionAndCity();
    final lat = pos.$1;
    final lng = pos.$2;
    final city = pos.$3;

    setState(() => _currentCity = city);

    final params = _filterParams ?? FilterParams(
      maxDistanceKm: 5,
      ville: city,
      quartier: '',
      minPrice: 500,
      maxPrice: 3500,
      minChambres: 1,
      maxColoc: 4,
      groupeOnly: false,
    );

    final results = await _houses.searchNearbyHouses(
      centerLat: lat,
      centerLng: lng,
      maxDistanceKm: params.maxDistanceKm,
      ville: params.ville,
      quartier: params.quartier,
      minPrice: params.minPrice,
      maxPrice: params.maxPrice,
      minChambres: params.minChambres,
      maxColoc: params.maxColoc,
      groupeOnly: params.groupeOnly,
    );

    setState(() {
      _nearbyHouses = results;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openFilter() async {
    final currentPos = await _geo.getCurrentPositionAndCity();
    final lat = currentPos.$1;
    final lng = currentPos.$2;

    final result = await Navigator.pushNamed(context, '/filter');
    if (result is FilterParams) {
      setState(() => _filterParams = result);
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

      setState(() => _nearbyHouses = results);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.home_outlined, size: 26, color: Color(0xFF2D2D2D)),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Home screen',
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

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.location_on, size: 18, color: Color(0xFF3D7A8A)),
                  const SizedBox(width: 4),
                  Text(
                    _currentCity,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

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
                        color: const Color(0xFFF0F0F0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.tune, size: 20, color: Color(0xFF2D2D2D)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Proches de vous',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _nearbyHouses.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.home_outlined, size: 60, color: Color(0xFFCCBBA0)),
                              SizedBox(height: 12),
                              Text(
                                'Aucune maison disponible près de vous',
                                style: TextStyle(color: Color(0xFF9A8070), fontSize: 14),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _nearbyHouses.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            return _RenterHouseCard(house: _nearbyHouses[index]);
                          },
                        ),
            ),
          ],
        ),
      ),
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
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: images.isNotEmpty
                ? SizedBox(
                    width: double.infinity,
                    height: 160,
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
                                size: 50,
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
                            left: 28,
                            right: -28,
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
                            left: 56,
                            right: -56,
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
                    width: double.infinity,
                    height: 160,
                    color: const Color(0xFFCCBBA0),
                    child: const Icon(Icons.home, size: 50, color: Colors.white54),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 14, color: Color(0xFF3D7A8A)),
                          const SizedBox(width: 3),
                          Text(
                            (house['rue_quartier'] as String?) ?? 'Quartier',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D2D2D),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '$price MAD',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D2D2D),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Text(
                            'distance inconnue',
                            style: TextStyle(fontSize: 11, color: Color(0xFF9A8070)),
                          ),
                          const Spacer(),
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
                                (house['ownerName'] as String?) ?? 'Nom propriétaire',
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
        ],
      ),
      ),
    );
  }
}
