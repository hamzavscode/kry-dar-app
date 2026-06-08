import 'package:flutter/material.dart';
import '../services/firestore_payment_service.dart';
import '../services/current_user_service.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> house;

  const PaymentScreen({super.key, required this.house});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final FirestorePaymentService _paymentService = FirestorePaymentService();
  final CurrentUserService _userService = CurrentUserService();
  
  final TextEditingController _ribController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  
  String? _selectedBankName;
  bool _isSubmitting = false;

  // List of Moroccan Banks
  final List<Map<String, String>> _moroccanBanks = [
    {'name': 'CIH Bank', 'code': '230'},
    {'name': 'Attijariwafa Bank', 'code': '007'},
    {'name': 'Banque Populaire (BCP)', 'code': '181'},
    {'name': 'BMCE Bank (Bank of Africa)', 'code': '011'},
    {'name': 'Crédit Agricole du Maroc', 'code': '022'},
    {'name': 'Société Générale Maroc', 'code': '021'},
    {'name': 'BMCI', 'code': '013'},
    {'name': 'Crédit du Maroc', 'code': '050'},
    {'name': 'Al Barid Bank', 'code': '350'},
  ];

  @override
  void dispose() {
    _ribController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  Future<void> _submitPayment() async {
    final rib = _ribController.text.trim();
    final amount = widget.house['prix_mensuel'] ?? widget.house['housePrice'] ?? 0;

    if (_selectedBankName == null || rib.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى اختيار البنك وإدخال رقم الحساب (RIB)')),
      );
      return;
    }

    if (rib.length != 24) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رقم الحساب (RIB) يجب أن يتكون من 24 رقماً')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final currentUserId = _userService.currentUserId;
      if (currentUserId == null) throw Exception('Utilisateur non connecté');

      await _paymentService.savePayment(
        userId: currentUserId,
        houseId: widget.house['id'] ?? widget.house['houseId'] ?? '',
        bankAccountName: _selectedBankName!,
        bankAccountNumber: rib,
        amount: amount.toDouble(),
        reference: _referenceController.text.trim(),
      );

      if (!mounted) return;
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
          content: const Text(
            'تم تسجيل عملية الدفع بنجاح. سيتم التحقق من البيانات قريباً.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context, true);
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3D7A8A)),
                child: const Text('حسناً', style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final price = widget.house['prix_mensuel'] ?? widget.house['housePrice'] ?? 0;
    final quartier = widget.house['rue_quartier'] ?? widget.house['houseName'] ?? 'المنزل';

    return Scaffold(
      backgroundColor: const Color(0xFFF5ECD7),
      appBar: AppBar(
        title: const Text('واجهة الدفع', style: TextStyle(color: Color(0xFF2D2D2D), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF2D2D2D)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // House Info Summary (Price is fixed)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF3D7A8A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text('ثمن الكراء الشهري', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 5),
                  Text('$price MAD', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text('المنزل بـ: $quartier', style: const TextStyle(color: Colors.white, fontSize: 16)),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            const Text('معلومات الدفع', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF4A2010))),
            const SizedBox(height: 15),

            // Bank Selection Dropdown
            _buildInputLabel('اختر البنك الذي قمت بالتحويل إليه'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedBankName,
                  hint: const Text('اختر البنك'),
                  isExpanded: true,
                  items: _moroccanBanks.map((bank) {
                    return DropdownMenuItem<String>(
                      value: bank['name'],
                      child: Text(bank['name']!),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedBankName = val),
                ),
              ),
            ),

            const SizedBox(height: 15),

            _buildInputLabel('رقم الحساب الذي حولت إليه (RIB)'),
            _buildTextField(_ribController, '000 000 0000000000000000 00', Icons.numbers, keyboardType: TextInputType.number),

            const SizedBox(height: 15),

            _buildInputLabel('مرجع العملية (مثلاً: الاسم الكامل)'),
            _buildTextField(_referenceController, 'مرجع التحويل لسهولة التحقق', Icons.description_outlined),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4845A),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('تأكيد وإرسال البيانات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            
            const SizedBox(height: 20),
            const Text(
              '* سيتم مراجعة بياناتك من طرف صاحب الدار للموافقة النهائية.',
              style: TextStyle(fontSize: 12, color: Color(0xFF9A8070), fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF5A4A38))),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF3D7A8A)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
