import 'package:flutter/material.dart';

import '../services/current_user_service.dart';
import '../services/firestore_groups_service.dart';
import 'group_chat_screen.dart';
import 'payment_screen.dart';

class HouseGroupsScreen extends StatefulWidget {
  const HouseGroupsScreen({super.key, required this.house});

  final Map<String, dynamic> house;

  @override
  State<HouseGroupsScreen> createState() => _HouseGroupsScreenState();
}

class _HouseGroupsScreenState extends State<HouseGroupsScreen> {
  final FirestoreGroupsService _groupsService = FirestoreGroupsService();
  final CurrentUserService _userService = CurrentUserService();
  
  bool _isLoadingAction = false;

  Future<void> _joinGroup(Map<String, dynamic> group, List memberIds, int maxMembers) async {
    final groupId = group['id'];
    if (memberIds.length >= maxMembers) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le groupe est déjà complet')),
      );
      return;
    }

    final currentUser = await _userService.getCurrentUserDoc();
    final currentUserId = _userService.currentUserId;
    
    if (currentUser == null || currentUserId == null) return;
    
      if (memberIds.contains(currentUserId)) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => GroupChatScreen(group: group)),
        );
        return;
      }

    // Step: Payment before joining
    final bool? paid = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(house: widget.house),
      ),
    );

    if (paid != true) return;

    setState(() => _isLoadingAction = true);
    try {
      final name = currentUser['fullName'] ?? 'Utilisateur';
      await _groupsService.joinGroup(
        groupId: groupId,
        userId: currentUserId,
        userName: name,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous avez rejoint le groupe !')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => GroupChatScreen(group: group)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isLoadingAction = false);
    }
  }

  Future<void> _createGroup() async {
    final currentUser = await _userService.getCurrentUserDoc();
    final currentUserId = _userService.currentUserId;
    if (currentUser == null || currentUserId == null) return;

    // Step: Payment before creating
    final bool? paid = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(house: widget.house),
      ),
    );

    if (paid != true) return;

    setState(() => _isLoadingAction = true);
    try {
      final name = currentUser['fullName'] ?? 'Utilisateur';
      final houseImages = widget.house['images'] as List?;
      final houseImage = (houseImages != null && houseImages.isNotEmpty) 
          ? houseImages[0] : '';
      
      await _groupsService.createGroup(
        houseId: widget.house['id'] ?? '',
        houseName: widget.house['rue_quartier'] ?? 'Maison',
        houseImage: houseImage,
        housePrice: widget.house['prix_mensuel'] ?? 0,
        ownerId: widget.house['ownerId'] ?? '',
        maxMembers: widget.house['nombre_max'] ?? 1,
        creatorId: currentUserId,
        creatorName: name,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Groupe créé avec succès !')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isLoadingAction = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final houseId = widget.house['id'] ?? '';
    final houseName = widget.house['rue_quartier'] ?? 'Maison';
    final currentUserId = _userService.currentUserId;

    return Scaffold(
      backgroundColor: const Color(0xFFF5ECD7),
      body: SafeArea(
        child: Column(
          children: [
            // Header with Moroccan arch style
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFFD4E8C8).withOpacity(0.5),
                        const Color(0xFFF5ECD7),
                      ],
                    ),
                  ),
                ),
                // Custom Arch or Pattern can be added here
                Positioned(
                  top: 10,
                  left: 10,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2D2D2D)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Positioned(
                  top: 50,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      const Text(
                        'Group Section',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        houseName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF5A4A38),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tu peux créer ou rejoindre un groupe',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF9A8070),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Groups List
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _groupsService.streamHouseGroups(houseId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF3D7A8A)));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  }
                  final groups = snapshot.data ?? [];
                  
                  if (groups.isEmpty) {
                    return const Center(
                      child: Text(
                        'Aucun groupe pour le moment.\nSoyez le premier à en créer un !',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF9A8070)),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: groups.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      final memberIds = group['memberIds'] as List? ?? [];
                      final maxMembers = group['maxMembers'] ?? 1;
                      final isFull = memberIds.length >= maxMembers;

                      final isMember = currentUserId != null && memberIds.contains(currentUserId);

                      return _GroupCard(
                        groupName: group['name'] ?? 'Groupe',
                        memberCount: memberIds.length,
                        maxMembers: maxMembers,
                        onJoin: () => _joinGroup(group, memberIds, maxMembers),
                        onOpen: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => GroupChatScreen(group: group)),
                          );
                        },
                        isFull: isFull,
                        isMember: isMember,
                        isLoading: _isLoadingAction,
                      );
                    },
                  );
                },
              ),
            ),

            // Create Group Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _isLoadingAction ? null : _createGroup,
                  icon: const Icon(Icons.add, size: 22),
                  label: const Text(
                    'Créer un Groupe',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3D7A8A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({
    required this.groupName,
    required this.memberCount,
    required this.maxMembers,
    required this.onJoin,
    required this.onOpen,
    required this.isFull,
    required this.isMember,
    required this.isLoading,
  });

  final String groupName;
  final int memberCount;
  final int maxMembers;
  final VoidCallback onJoin;
  final VoidCallback onOpen;
  final bool isFull;
  final bool isMember;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E6D0),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    groupName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$memberCount/$maxMembers entrés',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF9A8070),
                    ),
                  ),
                ],
              ),
              
              // Mock avatars row
              Row(
                children: List.generate(memberCount, (index) {
                  return Align(
                    widthFactor: 0.6,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3D7A8A),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFF0E6D0), width: 2),
                      ),
                      child: const Icon(Icons.person, size: 18, color: Colors.white),
                    ),
                  );
                }),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: isMember 
                  ? onOpen 
                  : (isFull || isLoading) ? null : onJoin,
              style: ElevatedButton.styleFrom(
                backgroundColor: isMember 
                    ? const Color(0xFF3D7A8A) 
                    : isFull ? const Color(0xFF9A8070) : const Color(0xFFD4845A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                isMember ? 'Ouvrir le chat' : (isFull ? 'Complet' : 'Rejoindre'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
