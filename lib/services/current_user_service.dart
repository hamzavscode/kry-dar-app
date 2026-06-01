import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CurrentUserService {
  CurrentUserService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Future<Map<String, dynamic>?> getCurrentUserDoc() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final snap = await _firestore
        .collection('users')
        .where('email', isEqualTo: user.email)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;
    return snap.docs.first.data();
  }

  String? get currentUserId => _auth.currentUser?.uid;

  Future<String?> getCurrentUserFullName() async {
    final doc = await getCurrentUserDoc();
    final name = doc?['fullName'];
    return name is String ? name : null;
  }
}

