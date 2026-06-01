import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreSignupService {
  FirestoreSignupService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const String collectionName = 'users';

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection(collectionName);

  Future<bool> emailExists({required String email}) async {
    final q = await _usersCollection
        .where('email', isEqualTo: email.trim())
        .limit(1)
        .get();
    return q.docs.isNotEmpty;
  }

  Future<void> createUser({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String password,
    required String role,
  }) async {
    final trimmedEmail = email.trim();
    final trimmedFullName = fullName.trim();
    final trimmedPhoneNumber = phoneNumber.trim();

    // 1) Create the Firebase Auth user (this is what your login requires).
    final credential = await _auth.createUserWithEmailAndPassword(
      email: trimmedEmail,
      password: password.trim(),
    );

    final user = credential.user;
    if (user == null) {
      throw Exception('Utilisateur introuvable.');
    }

    // 2) Store extra data in Firestore (do NOT overwrite password/email logic).
    // Keep existing fields so your app keeps working.
    await _usersCollection.doc(user.uid).set({
      'fullName': trimmedFullName,
      'phoneNumber': trimmedPhoneNumber,
      'email': trimmedEmail,
      // Keep the password field to avoid changing your data schema.
      // Your app must not rely on this for authentication; Firebase Auth is the source of truth.
      'password': password,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}


