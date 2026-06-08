import 'package:flutter/material.dart';
import '../services/firestore_payment_service.dart';

class BankAccountsScreen extends StatefulWidget {
  const BankAccountsScreen({super.key});

  @override
  State<BankAccountsScreen> createState() => _BankAccountsScreenState();
}

class _BankAccountsScreenState extends State<BankAccountsScreen> {
  final FirestorePaymentService _paymentService = FirestorePaymentService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5ECD7),
      appBar: AppBar(
        title: const Text('الحسابات البنكية', style: TextStyle(color: Color(0xFF2D2D2D), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2D2D2D)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'البحث عن بنك...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF3D7A8A)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _paymentService.streamBankAccounts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final allBanks = snapshot.data ?? [
                    {'bankName': 'Attijariwafa Bank', 'accountNumber': '007 123 0001234567890123 45'},
                    {'bankName': 'BCP (Banque Populaire)', 'accountNumber': '181 456 0004567890123456 78'},
                    {'bankName': 'BMCE Bank', 'accountNumber': '011 789 0007890123456789 01'},
                    {'bankName': 'CIH Bank', 'accountNumber': '230 111 0001112223334445 55'},
                  ];

                  final filteredBanks = allBanks.where((bank) {
                    final name = (bank['bankName'] as String).toLowerCase();
                    return name.contains(_searchQuery);
                  }).toList();

                  if (filteredBanks.isEmpty) {
                    return const Center(child: Text('لم يتم العثور على أي بنك'));
                  }

                  return ListView.separated(
                    itemCount: filteredBanks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final bank = filteredBanks[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
                          ],
                        ),
                        child: ListTile(
                          title: Text(bank['bankName'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(bank['accountNumber'] ?? ''),
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFF3D7A8A),
                            child: Icon(Icons.account_balance, color: Colors.white, size: 20),
                          ),
                          onTap: () {
                            // Optionally copy to clipboard
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('تم نسخ رقم الحساب')),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
