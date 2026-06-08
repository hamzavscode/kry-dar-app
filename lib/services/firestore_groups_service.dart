import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreGroupsService {
  FirestoreGroupsService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static const String groupsCollection = 'groups';

  CollectionReference<Map<String, dynamic>> get _groups =>
      _firestore.collection(groupsCollection);

  /// Create a new group for a house. The creator becomes the leader.
  Future<String> createGroup({
    required String houseId,
    required String houseName,
    required String houseImage,
    required int housePrice,
    required String ownerId,
    required int maxMembers,
    required String creatorId,
    required String creatorName,
  }) async {
    // Generate a default name like "Groupe 1" based on existing groups count
    final countSnap = await _groups.where('houseId', isEqualTo: houseId).count().get();
    final groupNumber = (countSnap.count ?? 0) + 1;
    final groupName = 'Groupe $groupNumber';

    final docRef = await _groups.add({
      'houseId': houseId,
      'houseName': houseName,
      'houseImage': houseImage,
      'housePrice': housePrice,
      'ownerId': ownerId,
      'name': groupName,
      'leaderId': creatorId,
      'maxMembers': maxMembers,
      'memberIds': [creatorId],
      'members': [
        {
          'id': creatorId,
          'name': creatorName,
        }
      ],
      'createdAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  /// Join an existing group
  Future<void> joinGroup({
    required String groupId,
    required String userId,
    required String userName,
  }) async {
    final docRef = _groups.doc(groupId);
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      if (!doc.exists) throw Exception('Group does not exist');

      final data = doc.data()!;
      final List memberIds = data['memberIds'] ?? [];
      final List members = data['members'] ?? [];
      final int maxMembers = data['maxMembers'] ?? 1;

      if (memberIds.length >= maxMembers) {
        throw Exception('Le groupe est déjà complet.');
      }
      if (memberIds.contains(userId)) {
        throw Exception('Vous êtes déjà dans ce groupe.');
      }

      memberIds.add(userId);
      members.add({'id': userId, 'name': userName});

      transaction.update(docRef, {
        'memberIds': memberIds,
        'members': members,
      });
    });
  }

  /// Leave a group
  Future<void> leaveGroup({
    required String groupId,
    required String userId,
  }) async {
    final docRef = _groups.doc(groupId);
    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      if (!doc.exists) return;

      final data = doc.data()!;
      final List memberIds = List.from(data['memberIds'] ?? []);
      final List members = List.from(data['members'] ?? []);
      final String leaderId = data['leaderId'] ?? '';

      memberIds.remove(userId);
      members.removeWhere((m) => m['id'] == userId);

      if (memberIds.isEmpty) {
        // Delete group if empty
        transaction.delete(docRef);
      } else {
        String newLeader = leaderId;
        if (leaderId == userId) {
          // Reassign leader
          newLeader = memberIds.first as String;
        }
        transaction.update(docRef, {
          'memberIds': memberIds,
          'members': members,
          'leaderId': newLeader,
        });
      }
    });
  }

  /// Stream all groups for a specific house
  Stream<List<Map<String, dynamic>>> streamHouseGroups(String houseId) {
    return _groups
        .where('houseId', isEqualTo: houseId)
        .snapshots()
        .map((snap) {
          final list = snap.docs.map((d) => {...d.data(), 'id': d.id}).toList();
          list.sort((a, b) {
            final aTime = a['createdAt'] as Timestamp?;
            final bTime = b['createdAt'] as Timestamp?;
            if (aTime == null && bTime == null) return 0;
            if (aTime == null) return -1;
            if (bTime == null) return 1;
            return aTime.compareTo(bTime);
          });
          return list;
        });
  }

  /// Stream all groups the user is a member of
  Stream<List<Map<String, dynamic>>> streamUserGroups(String userId) {
    return _groups
        .where('memberIds', arrayContains: userId)
        // Note: composite index required if ordered by createdAt here, 
        // omitting order to avoid forcing user to create index manually during dev.
        .snapshots()
        .map((snap) => snap.docs.map((d) => {...d.data(), 'id': d.id}).toList());
  }

  // --- Messages ---

  CollectionReference<Map<String, dynamic>> _messages(String groupId) =>
      _groups.doc(groupId).collection('messages');

  Future<void> sendMessage({
    required String groupId,
    required String senderId,
    required String senderName,
    required String text,
  }) async {
    await _messages(groupId).add({
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Map<String, dynamic>>> streamMessages(String groupId) {
    return _messages(groupId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => {...d.data(), 'id': d.id}).toList());
  }
}
