class HouseModel {
  final String id;
  final String ownerId;
  final String ownerName;
  final List<String> images;
  final String ville;
  final String rueQuartier;
  final double lat;
  final double lng;
  final int prixMensuel;
  final int nombreMax;
  final int nombreChambres;
  final String description;
  final bool wifi;
  final bool cuisine;
  final bool garage;
  final bool machineLaver;
  final bool groupesAutorises;
  final String status;
  final DateTime createdAt;

  const HouseModel({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.images,
    required this.ville,
    required this.rueQuartier,
    required this.lat,
    required this.lng,
    required this.prixMensuel,
    required this.nombreMax,
    required this.nombreChambres,
    required this.description,
    required this.wifi,
    required this.cuisine,
    required this.garage,
    required this.machineLaver,
    required this.groupesAutorises,
    required this.status,
    required this.createdAt,
  });
}

