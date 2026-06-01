import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/current_user_service.dart';
import '../services/firestore_houses_service.dart';
import '../services/cloudinary_service.dart';
import '../services/geolocation_service.dart';



class AddHouseScreen extends StatefulWidget {
  const AddHouseScreen({super.key});

  @override
  State<AddHouseScreen> createState() => _AddHouseScreenState();
}

class _AddHouseScreenState extends State<AddHouseScreen> {
  final List<XFile> _images = [];
  final ImagePicker _picker = ImagePicker();

  String _selectedVille = 'Casablanca';
  String _selectedQuartier = 'Hay Mohammadi';

  int _prixMensuel = 250;
  int _nombreMax = 1;
  int _nombreChambres = 1;
  final TextEditingController _descriptionController = TextEditingController();

  bool _wifi = false;
  bool _cuisine = false;
  bool _garage = false;
  bool _machineLaver = false;
  bool _groupesAutorises = false;

  // Morocco cities & quartiers
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
      'Hay Mohammadi',
      'Maarif',
      'Ain Diab',
      'Sidi Moumen',
      'Bernoussi',
      'Bourgogne',
      'Derb Sultan',
      'Moulay Rachid',
    ],
    'Rabat': ['Agdal', 'Hassan', 'Youssoufia', 'Hay Riad', 'Souissi', 'Akkari'],
    'Marrakech': ['Gueliz', 'Medina', 'Hivernage', 'Massira', 'Targa', 'M\'hamid'],
    'Fès': ['Médina', 'Ville Nouvelle', 'Saiss', 'Narjiss'],
    'Tanger': ['Médina', 'Malabata', 'Marchane', 'Moujahidine'],
    'Agadir': ['Talborjt', 'Hay Mohammadi', 'Nouveau Talborjt', 'Tilila'],
    'Meknès': ['Médina', 'Hamria', 'Ismaïlia', 'Riad'],
    'Oujda': ['Médina', 'Lazaret', 'Sidi Maâfa'],
    'Kénitra': ['Centre Ville', 'Saknia', 'Bir Rami'],
    'Tétouan': ['Médina', 'Ensanche', 'Martil'],
    'Safi': ['Médina', 'Sidi Bouzid', 'Lamkansa'],
    'Mohammedia': ['Centre', 'Ain Harrouda', 'Sidi Moussa'],
    'El Jadida': ['Mazagan', 'Hay Essalam', 'Haouzia'],
    'Béni Mellal': ['Centre', 'Hay Al Massira', 'Aït Benhaddou'],
    'Nador': ['Centre', 'Hay Al Wahda', 'Bni Ansar'],
  };

  List<String> get _currentQuartiers =>
      _quartiersMap[_selectedVille] ?? [_selectedVille];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile>? picked =
        await _picker.pickMultiImage(imageQuality: 80);
    if (picked != null && picked.isNotEmpty) {
      setState(() => _images.addAll(picked));
    }
  }


  void _adjustPrice(int delta) {
    setState(() {
      _prixMensuel = (_prixMensuel + delta).clamp(250, 50000);
    });
  }

  void _adjustNombreMax(int delta) {
    setState(() {
      _nombreMax = (_nombreMax + delta).clamp(1, 4);
    });
  }

  void _adjustChambres(int delta) {
    setState(() {
      _nombreChambres = (_nombreChambres + delta).clamp(1, 20);
    });
  }

  bool _isPublishing = false;

  Future<void> _publish() async {
  if (_isPublishing) return;

  if (_images.isEmpty) {
    _showError('Veuillez ajouter au moins une photo');
    return;
  }

  if (_descriptionController.text.trim().isEmpty) {
    _showError('Veuillez ajouter une description');
    return;
  }

  setState(() => _isPublishing = true);

  try {
    final userService = CurrentUserService();
    final housesService = FirestoreHousesService();

    final ownerId = userService.currentUserId;

    if (ownerId == null) {
      throw Exception(
        'Vous devez vous connecter en tant que owner',
      );
    }

    final ownerName =
        await userService.getCurrentUserFullName();

    if (ownerName == null || ownerName.isEmpty) {
      throw Exception(
        'Impossible de récupérer votre nom',
      );
    }

    final cloudinary = CloudinaryService(
      cloudName: 'dpo8yz8cf',
      uploadPreset: 'insta_upload',
    );

    debugPrint(
      'Cloudinary preset: ${cloudinary.uploadPreset}',
    );

    final imageUrls =
        await cloudinary.uploadImages(
      images: _images,
    );

    debugPrint('IMAGE URLS = $imageUrls');

    if (imageUrls.isEmpty) {
      throw Exception(
        'Aucune image uploadée',
      );
    }

    final geo = const GeoLocationService();

    final location =
        await geo.getCurrentPositionAndCity();

    debugPrint('LOCATION = $location');

    final (lat, lng, city) = location;

    debugPrint('LAT = $lat');
    debugPrint('LNG = $lng');
    debugPrint('CITY = $city');

    if (lat == null || lng == null) {
      throw Exception(
        'Position GPS introuvable',
      );
    }

    await housesService.insertHouse(
      ownerId: ownerId,
      ownerName: ownerName,
      imageUrls: imageUrls,
      ville: _selectedVille,
      rueQuartier: _selectedQuartier,
      lat: lat,
      lng: lng,
      prixMensuel: _prixMensuel,
      nombreMax: _nombreMax,
      nombreChambres: _nombreChambres,
      description:
          _descriptionController.text.trim(),
      wifi: _wifi,
      cuisine: _cuisine,
      garage: _garage,
      machineLaver: _machineLaver,
      groupesAutorises: _groupesAutorises,
      status: 'disponible',
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Maison publiée avec succès !',
        ),
        backgroundColor: Color(0xFF3D7A8A),
      ),
    );

    Navigator.pop(context);

  } catch (e, stackTrace) {

    debugPrint('ERROR = $e');

    debugPrint(
      'STACK TRACE = $stackTrace',
    );

    if (!mounted) return;

    _showError(
      'Erreur lors de la publication : $e',
    );

  } finally {

    if (mounted) {
      setState(() => _isPublishing = false);
    }

  }
}

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5ECD7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5ECD7),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Ajouter une nouvelle maison',
          style: TextStyle(
            color: Color(0xFF2D2D2D),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFCCBBA0)),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Label('Photos de la maison'),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 90,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        GestureDetector(
                          onTap: _pickImages,
                          child: Container(
                            width: 80,
                            height: 80,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8D8C0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.add, size: 32, color: Color(0xFF9A8070)),
                          ),
                        ),
                        ..._images.map(
                          (img) => Container(
                            width: 80,
                            height: 80,
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                // img.path may be a non-filesystem URI (Android).
                                // FileImage(File(...)) can crash in that case.
                                // We fall back to Image.network if needed.
                                image: (img.path.startsWith('http') || img.path.startsWith('https'))
                                    ? NetworkImage(img.path)
                                    : FileImage(File(img.path)),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  const _Label('Ville'),
                  const SizedBox(height: 6),
                  _StyledDropdown(
                    value: _selectedVille,
                    items: _villes,
                    onChanged: (v) => setState(() {
                      _selectedVille = v!;
                      _selectedQuartier = _currentQuartiers.first;
                    }),
                  ),

                  const SizedBox(height: 14),

                  const _Label('Quartier / Rue'),
                  const SizedBox(height: 6),
                  _StyledDropdown(
                    value: _currentQuartiers.contains(_selectedQuartier)
                        ? _selectedQuartier
                        : _currentQuartiers.first,
                    items: _currentQuartiers,
                    onChanged: (v) => setState(() => _selectedQuartier = v!),
                  ),

                  const SizedBox(height: 14),

                  const _Label('Emplacement sur carte'),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 140,
                          color: const Color(0xFFD4E8C8),
                          child: CustomPaint(painter: _StaticMapPainter()),
                        ),
                        const Icon(Icons.location_on, color: Colors.red, size: 36),
                      ],
                    ),
                  ),

                  const SizedBox(height: 4),
                  const Divider(color: Color(0xFFCCBBA0)),

                  _StepperRow(
                    label: 'Prix Mensuel',
                    value: '$_prixMensuel MAD',
                    onMinus: () => _adjustPrice(-50),
                    onPlus: () => _adjustPrice(50),
                  ),
                  const Divider(color: Color(0xFFCCBBA0)),

                  _StepperRow(
                    label: 'Nombre max',
                    value: '$_nombreMax',
                    onMinus: () => _adjustNombreMax(-1),
                    onPlus: () => _adjustNombreMax(1),
                  ),
                  const Divider(color: Color(0xFFCCBBA0)),

                  _StepperRow(
                    label: 'Nombre de chambres',
                    value: '$_nombreChambres',
                    onMinus: () => _adjustChambres(-1),
                    onPlus: () => _adjustChambres(1),
                  ),
                  const Divider(color: Color(0xFFCCBBA0)),

                  const SizedBox(height: 10),

                  const _Label('Description'),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _descriptionController,
                      maxLines: 4,
                      style: const TextStyle(fontSize: 14),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFCCBBA0)),

                  const _Label('Equipement disponnible'),
                  const SizedBox(height: 10),
                  _EquipementRow(
                    icon: Icons.wifi,
                    label: 'Wifi',
                    value: _wifi,
                    onChanged: (v) => setState(() => _wifi = v),
                  ),
                  _EquipementRow(
                    icon: Icons.restaurant,
                    label: 'Cuisine',
                    value: _cuisine,
                    onChanged: (v) => setState(() => _cuisine = v),
                  ),
                  _EquipementRow(
                    icon: Icons.garage_outlined,
                    label: 'Garage',
                    value: _garage,
                    onChanged: (v) => setState(() => _garage = v),
                  ),
                  _EquipementRow(
                    icon: Icons.local_laundry_service_outlined,
                    label: 'Machine à laver',
                    value: _machineLaver,
                    onChanged: (v) => setState(() => _machineLaver = v),
                  ),

                  const Divider(color: Color(0xFFCCBBA0)),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Switch(
                        value: _groupesAutorises,
                        onChanged: (v) => setState(() => _groupesAutorises = v),
                        activeColor: const Color(0xFF3D7A8A),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Autoriser les Groupes',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
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
              onPressed: _isPublishing ? null : _publish,
              style: ElevatedButton.styleFrom(

                  backgroundColor: const Color(0xFFD4845A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 3,
                ),
                child: _isPublishing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Publier',
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
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF2D2D2D),
      ),
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
        border: Border.all(color: Colors.red.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChanged,
          style: const TextStyle(fontSize: 15, color: Color(0xFF2D2D2D)),
        ),
      ),
    );
  }
}

class _StepperRow extends StatelessWidget {
  const _StepperRow({
    required this.label,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

  final String label;
  final String value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 14, color: Color(0xFF2D2D2D))),
          ),
          GestureDetector(
            onTap: onMinus,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFD4845A),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.remove, color: Colors.white, size: 18),
            ),
          ),
          Container(
            width: 64,
            height: 34,
            margin: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFD4845A),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: onPlus,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFD4845A),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _EquipementRow extends StatelessWidget {
  const _EquipementRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Column(
            children: [
              Icon(icon, size: 28, color: const Color(0xFF2D2D2D)),
              const SizedBox(height: 3),
              Text(label,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF5A4A38))),
            ],
          ),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF3D7A8A),
          ),
        ],
      ),
    );
  }
}

class _StaticMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFD4E8C8);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    for (double y = 20; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), roadPaint);
    }
    for (double x = 30; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), roadPaint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

