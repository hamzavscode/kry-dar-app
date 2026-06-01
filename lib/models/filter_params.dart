class FilterParams {
  final double maxDistanceKm;
  final String ville;
  final String quartier;
  final int minPrice;
  final int maxPrice;
  final int minChambres;
  final int maxColoc;
  final bool groupeOnly;

  const FilterParams({
    required this.maxDistanceKm,
    required this.ville,
    required this.quartier,
    required this.minPrice,
    required this.maxPrice,
    required this.minChambres,
    required this.maxColoc,
    required this.groupeOnly,
  });
}

