import 'package:flutter/material.dart';
import '../models/filter_params.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  double _maxDistance = 5;
  String _selectedVille = 'Casablanca';
  String _selectedQuartier = 'Casablanca';

  RangeValues _priceRange = const RangeValues(500, 3500);
  int _selectedChambres = 3;
  int _selectedColoc = 3;
  bool _groupeOnly = false;

  static const List<String> _villes = [
    'Casablanca',
    'Rabat',
    'Marrakech',
    'Fès',
    'Tanger',
    'Agadir',
    'Meknès',
    'Oujda',
    'Kénitra',
    'Tétouan',
    'Safi',
    'Mohammedia',
    'El Jadida',
    'Béni Mellal',
    'Nador',
  ];

  static const Map<String, List<String>> _quartiersMap = {
    'Casablanca': [
      'Casablanca',
      'Hay Mohammadi',
      'Maarif',
      'Ain Diab',
      'Sidi Moumen',
      'Bernoussi',
      'Bourgogne',
    ],
    'Rabat': ['Agdal', 'Hassan', 'Youssoufia', 'Hay Riad', 'Souissi'],
    'Marrakech': ['Gueliz', 'Medina', 'Hivernage', 'Massira', 'Targa'],
    'Fès': ['Médina', 'Ville Nouvelle', 'Saiss'],
    'Tanger': ['Médina', 'Malabata', 'Marchane'],
    'Agadir': ['Talborjt', 'Hay Mohammadi', 'Nouveau Talborjt'],
  };

  List<String> get _currentQuartiers =>
      _quartiersMap[_selectedVille] ?? [_selectedVille];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5ECD7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5ECD7),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Filter screen',
          style: TextStyle(
            color: Color(0xFF2D2D2D),
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18, color: Color(0xFF2D2D2D)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Localisation',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text('Max distance',
                            style: TextStyle(fontSize: 13, color: Color(0xFF9A8070))),
                        const SizedBox(height: 8),

                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: const Color(0xFF3D7A8A),
                            inactiveTrackColor: const Color(0xFFCCBBA0),
                            thumbColor: const Color(0xFF3D7A8A),
                            overlayColor: const Color(0xFF3D7A8A).withOpacity(0.15),
                            trackHeight: 4,
                          ),
                          child: Slider(
                            value: _maxDistance,
                            min: 1,
                            max: 100,
                            onChanged: (v) => setState(() => _maxDistance = v),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('1 km', style: TextStyle(fontSize: 12, color: Color(0xFF9A8070))),
                            Text(
                              '${_maxDistance.round()} km',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF3D7A8A)),
                            ),
                            const Text('100 km', style: TextStyle(fontSize: 12, color: Color(0xFF9A8070))),
                          ],
                        ),

                        const SizedBox(height: 14),

                        _StyledDropdown(
                          value: _selectedVille,
                          items: _villes,
                          onChanged: (v) => setState(() {
                            _selectedVille = v!;
                            _selectedQuartier = _currentQuartiers.first;
                          }),
                        ),

                        const SizedBox(height: 10),
                        const Text('Rue , Quartier', style: TextStyle(fontSize: 13, color: Color(0xFF9A8070))),
                        const SizedBox(height: 6),

                        _StyledDropdown(
                          value: _currentQuartiers.contains(_selectedQuartier)
                              ? _selectedQuartier
                              : _currentQuartiers.first,
                          items: _currentQuartiers,
                          onChanged: (v) => setState(() => _selectedQuartier = v!),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Prix',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const SizedBox(width: 20),
                            Text('${_priceRange.start.round()} MAD',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF5A4A38))),
                            const SizedBox(width: 20),
                            Text('${_priceRange.end.round()} MAD',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF5A4A38))),
                            const SizedBox(width: 20),
                          ],
                        ),

                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: const Color(0xFF3D7A8A),
                            inactiveTrackColor: const Color(0xFFCCBBA0),
                            thumbColor: const Color(0xFF3D7A8A),
                            overlayColor: const Color(0xFF3D7A8A).withOpacity(0.15),
                            trackHeight: 4,
                            rangeThumbShape: const RoundRangeSliderThumbShape(
                              enabledThumbRadius: 10,
                            ),
                          ),
                          child: RangeSlider(
                            values: _priceRange,
                            min: 0,
                            max: 4000,
                            onChanged: (v) => setState(() => _priceRange = v),
                          ),
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('0 MAD', style: TextStyle(fontSize: 11, color: Color(0xFF9A8070))),
                            Text('4000 MAD', style: TextStyle(fontSize: 11, color: Color(0xFF9A8070))),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Nombre de chambres',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        _NumberSelector(
                          values: const [1, 2, 3, 4],
                          selected: _selectedChambres,
                          onSelect: (v) => setState(() => _selectedChambres = v),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Nombre max de collocataire',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        _NumberSelector(
                          values: const [1, 2, 3, 4],
                          selected: _selectedColoc,
                          onSelect: (v) => setState(() => _selectedColoc = v),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Montrer que les maison avec groupe',
                                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                              ),
                            ),
                            Switch(
                              value: _groupeOnly,
                              onChanged: (v) => setState(() => _groupeOnly = v),
                              activeColor: const Color(0xFF3D7A8A),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  final params = FilterParams(
                    maxDistanceKm: _maxDistance,
                    ville: _selectedVille,
                    quartier: _selectedQuartier,
                    minPrice: _priceRange.start.round(),
                    maxPrice: _priceRange.end.round(),
                    minChambres: _selectedChambres,
                    maxColoc: _selectedColoc,
                    groupeOnly: _groupeOnly,
                  );
                  Navigator.pop(context, params);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3D7A8A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                ),
                child: const Text(
                  'Filtrer',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E6D0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }
}

class _StyledDropdown extends StatelessWidget {
  const _StyledDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade200, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF2D2D2D)),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
          style: const TextStyle(fontSize: 15, color: Color(0xFF2D2D2D)),
        ),
      ),
    );
  }
}

class _NumberSelector extends StatelessWidget {
  const _NumberSelector({
    required this.values,
    required this.selected,
    required this.onSelect,
  });
  final List<int> values;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: values.map((v) {
        final active = v == selected;
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: GestureDetector(
            onTap: () => onSelect(v),
            child: Container(
              width: 54,
              height: 44,
              decoration: BoxDecoration(
                color: active ? const Color(0xFF3D7A8A) : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: active ? const Color(0xFF3D7A8A) : const Color(0xFF3D7A8A),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  '$v',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: active ? Colors.white : const Color(0xFF3D7A8A),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

