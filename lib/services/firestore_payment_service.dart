import 'package:cloud_firestore/cloud_firestore.dart';

class FirestorePaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String paymentsCollection = 'payments';
  static const String bankAccountsCollection = 'bank_accounts';

  // Fetch bank accounts for search
  Stream<List<Map<String, dynamic>>> streamBankAccounts() {
    return _firestore.collection(bankAccountsCollection).snapshots().map(
          (snap) => snap.docs.map((d) => {...d.data(), 'id': d.id}).toList(),
        );
  }

  // Save payment record
  Future<void> savePayment({
    required String userId,
    required String houseId,
    required String bankAccountName,
    required String bankAccountNumber,
    required double amount,
    required String reference,
  }) async {
    await _firestore.collection(paymentsCollection).add({
      'userId': userId,
      'houseId': houseId,
      'bankAccountName': bankAccountName,
      'bankAccountNumber': bankAccountNumber,
      'amount': amount,
      'reference': reference,
      'status': 'pending',
      'created_at': FieldValue.serverTimestamp(),
    });
  }
}
