import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class GeoLocationService {
  const GeoLocationService();

  Future<(double lat, double lng, String city)>
      getCurrentPositionAndCity() async {
    try {
      // CHECK IF GPS IS ENABLED
      final serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        throw Exception(
          'Le service de localisation est désactivé',
        );
      }

      // CHECK / REQUEST PERMISSION
      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        throw Exception(
          'Permission de localisation refusée',
        );
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Permission refusée définitivement',
        );
      }

      // GET CURRENT POSITION
      final Position position =
          await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      String city = 'Ville inconnue';

      // REVERSE GEOCODING
      try {
        final placemarks =
            await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final Placemark place = placemarks.first;

          city =
              place.locality ??
              place.subAdministrativeArea ??
              place.administrativeArea ??
              'Ville inconnue';
        }
      } catch (e) {
        debugPrint('GEOCODING ERROR: $e');

        // WEB fallback
        if (kIsWeb) {
          city = 'Position détectée';
        }
      }

      return (
        position.latitude,
        position.longitude,
        city,
      );
    } catch (e) {
      debugPrint('GEOLOCATION ERROR: $e');
      rethrow;
    }
  }
}