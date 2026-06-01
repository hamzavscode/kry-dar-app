import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreHousesService {

  FirestoreHousesService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String housesCollection = 'houses';

  CollectionReference<Map<String, dynamic>> get _houses =>
      _firestore.collection(housesCollection);

  Future<void> insertHouse({
    required String ownerId,
    required String ownerName,
    required List<String> imageUrls,
    required String ville,
    required String rueQuartier,
    required double lat,
    required double lng,
    required int prixMensuel,
    required int nombreMax,
    required int nombreChambres,
    required String description,
    required bool wifi,
    required bool cuisine,
    required bool garage,
    required bool machineLaver,
    required bool groupesAutorises,
    String status = 'disponible',
  }) async {
    await _houses.add({
      'ownerId': ownerId,
      'ownerName': ownerName,
      'images': imageUrls,
      'ville': ville,
      'rue_quartier': rueQuartier,
      'lat': lat,
      'lng': lng,
      'prix_mensuel': prixMensuel,
      'nombre_max': nombreMax,
      'nombre_chambres': nombreChambres,
      'description': description,
      'wifi': wifi,
      'cuisine': cuisine,
      'garage': garage,
      'machine_laver': machineLaver,
      'groupes_autorises': groupesAutorises,
      'status': status,


      'created_at': FieldValue.serverTimestamp(),
    });
  }

Future<List<Map<String, dynamic>>> getHousesByOwner({
  required String ownerId,
}) async {
  final snap = await _houses
      .where('ownerId', isEqualTo: ownerId)
      .get();

  return snap.docs.map((d) => {...d.data(), 'id': d.id}).toList();
}

  // NOTE: Firestore doesn't support real geo-distance without extra libraries.
  // For now we filter by city/price/rooms and do distance filtering client-side.
  Future<List<Map<String, dynamic>>> searchNearbyHouses({
    required double centerLat,
    required double centerLng,
    required double maxDistanceKm,
    required String ville,
    required String quartier,
    required int minPrice,
    required int maxPrice,
    required int minChambres,
    required int maxColoc,
    required bool groupeOnly,
  }) async {

    // city/price/status filters (server-side)
    Query<Map<String, dynamic>> q = _houses
        .where('ville', isEqualTo: ville)
        .where('status', isEqualTo: 'disponible')
        .where('prix_mensuel', isGreaterThanOrEqualTo: minPrice)
        .where('prix_mensuel', isLessThanOrEqualTo: maxPrice)
        .where('nombre_chambres', isGreaterThanOrEqualTo: minChambres)
        .where('nombre_max', isGreaterThanOrEqualTo: maxColoc);

    if (groupeOnly) {
      q = q.where('groupes_autorises', isEqualTo: true);
    }


    final snap = await q.get();

    final results = <Map<String, dynamic>>[];
    for (final doc in snap.docs) {
      final data = {...doc.data(), 'id': doc.id};

      final lat = (data['lat'] as num?)?.toDouble() ?? 0.0;
      final lng = (data['lng'] as num?)?.toDouble() ?? 0.0;
      final distanceKm = _distanceKm(centerLat, centerLng, lat, lng);
      if (distanceKm <= maxDistanceKm) {
        // quartier filter (soft)
        final rq = (data['rue_quartier'] as String?) ?? '';
        if (quartier.isEmpty || rq == quartier) {
          results.add(data);
        }
      }
    }

    return results;
  }

  // Haversine distance
  double _distanceKm(double lat1, double lng1, double lat2, double lng2) {
    const earthRadiusKm = 6371.0;

    final dLat = _degToRad(lat2 - lat1);
    final dLng = _degToRad(lng2 - lng1);

    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) *
            math.cos(_degToRad(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _degToRad(double deg) => deg * (math.pi / 180.0);

}

