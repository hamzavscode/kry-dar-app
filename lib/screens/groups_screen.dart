import 'package:flutter/material.dart';

import '../services/current_user_service.dart';
import '../services/firestore_groups_service.dart';
import 'group_chat_screen.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final FirestoreGroupsService _groupsService = FirestoreGroupsService();
  final CurrentUserService _userService = CurrentUserService();
  
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final uid = _userService.currentUserId;
    if (uid != null && mounted) {
      setState(() => _currentUserId = uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5ECD7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5ECD7),
        elevation: 0,
        title: const Text(
          'المجموعات',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D2D2D),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _currentUserId == null
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF3D7A8A)))
            : StreamBuilder<List<Map<String, dynamic>>>(
                stream: _groupsService.streamUserGroups(_currentUserId!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF3D7A8A)));
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  }
                  final groups = snapshot.data ?? [];
                  
                  if (groups.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              color: const Color(0xFF3D7A8A).withOpacity(0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.group_outlined,
                              size: 44,
                              color: Color(0xFF3D7A8A),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'لا توجد مجموعات بعد',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D2D2D),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'انضم إلى مجموعة من خلال البحث عن منازل.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.brown.shade400,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: groups.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      final memberIds = group['memberIds'] as List? ?? [];
                      final maxMembers = group['maxMembers'] ?? 1;
                      final houseName = group['houseName'] ?? 'Maison';
                      final groupName = group['name'] ?? 'Groupe';
                      final houseImage = group['houseImage'] ?? '';
                      
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GroupChatScreen(group: group),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // House Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: houseImage.isNotEmpty 
                                  ? Image.network(
                                      houseImage,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => _buildPlaceholder(),
                                    )
                                  : _buildPlaceholder(),
                              ),
                              const SizedBox(width: 16),
                              
                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      houseName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2D2D2D),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      groupName,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF3D7A8A),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${memberIds.length}/$maxMembers أعضاء',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF9A8070),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Arrow
                              const Icon(Icons.chevron_right, color: Color(0xFFCCBBA0)),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
  
  Widget _buildPlaceholder() {
    return Container(
      width: 60,
      height: 60,
      color: const Color(0xFFCCBBA0),
      child: const Icon(Icons.home, color: Colors.white),
    );
  }
}
