import 'package:flutter/material.dart';

import '../services/current_user_service.dart';
import '../services/firestore_groups_service.dart';

class GroupChatScreen extends StatefulWidget {
  const GroupChatScreen({super.key, required this.group});

  final Map<String, dynamic> group;

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final FirestoreGroupsService _groupsService = FirestoreGroupsService();
  final CurrentUserService _userService = CurrentUserService();
  final TextEditingController _msgController = TextEditingController();

  String? _currentUserId;
  String? _currentUserName;
  bool _isLoadingAction = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final doc = await _userService.getCurrentUserDoc();
    if (doc != null && mounted) {
      setState(() {
        _currentUserId = _userService.currentUserId;
        _currentUserName = doc['fullName'] ?? 'Moi';
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty || _currentUserId == null) return;

    _msgController.clear();

    await _groupsService.sendMessage(
      groupId: widget.group['id'],
      senderId: _currentUserId!,
      senderName: _currentUserName ?? 'Moi',
      text: text,
    );
  }

  Future<void> _leaveGroup() async {
    if (_currentUserId == null) return;

    setState(() => _isLoadingAction = true);
    try {
      await _groupsService.leaveGroup(
        groupId: widget.group['id'],
        userId: _currentUserId!,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vous avez quitté le groupe.')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isLoadingAction = false);
    }
  }

  void _secureHouse() {
    // This is where the leader can contact the owner
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأمين الدار'),
        content: const Text(
          'En tant que leader, vous allez être mis en relation directe avec le propriétaire pour finaliser la location.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Demande envoyée au propriétaire !'),
                  backgroundColor: Color(0xFFD4845A),
                ),
              );
            },
            child: const Text('Confirmer', style: TextStyle(color: Color(0xFFD4845A))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupId = widget.group['id'];
    final groupName = widget.group['name'] ?? 'Groupe';
    final memberIds = widget.group['memberIds'] as List? ?? [];
    final maxMembers = widget.group['maxMembers'] ?? 1;
    final leaderId = widget.group['leaderId'];
    final houseImage = widget.group['houseImage'] ?? '';
    
    final isLeader = _currentUserId == leaderId;

    return Scaffold(
      backgroundColor: const Color(0xFFF5ECD7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5ECD7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2D2D2D)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            if (houseImage.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  houseImage,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.home, color: Colors.grey),
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    groupName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  Text(
                    '${memberIds.length} / $maxMembers أعضاء',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9A8070),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF2D2D2D)),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Divider(height: 1, color: Color(0xFFDDD0B8)),
            
            // Messages list
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _groupsService.streamMessages(groupId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF3D7A8A)));
                  }
                  final messages = snapshot.data ?? [];
                  
                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg['senderId'] == _currentUserId;
                      return _MessageBubble(
                        text: msg['text'] ?? '',
                        senderName: msg['senderName'] ?? '?',
                        isMe: isMe,
                        time: '10:30', // Dummy time formatting
                      );
                    },
                  );
                },
              ),
            ),

            // Bottom actions & input
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFF0E6D0),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoadingAction ? null : _leaveGroup,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFD32F2F), width: 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'مغادرة المجموعة',
                            style: TextStyle(
                              color: Color(0xFFD32F2F),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      if (isLeader) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _secureHouse,
                            icon: const Icon(Icons.lock_outline, size: 18),
                            label: const Text(
                              'تأمين الدار',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD4845A),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  if (memberIds.length < maxMembers) ...[
                    const SizedBox(height: 8),
                    Text(
                      'عندما يكتمل العدد (${maxMembers} أعضاء) يمكنك تأمين الدار',
                      style: const TextStyle(fontSize: 10, color: Color(0xFF9A8070)),
                    ),
                  ],
                  
                  const SizedBox(height: 12),
                  
                  // Text input
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: TextField(
                            controller: _msgController,
                            textAlign: TextAlign.right,
                            decoration: const InputDecoration(
                              hintText: '...اكتب رسالة',
                              hintStyle: TextStyle(color: Color(0xFF9A9A9A), fontSize: 14),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              prefixIcon: Icon(Icons.search, size: 18, color: Colors.transparent), // Just for spacing match
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _sendMessage,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Color(0xFF3D7A8A),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.send, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.text,
    required this.senderName,
    required this.isMe,
    required this.time,
  });

  final String text;
  final String senderName;
  final bool isMe;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: Color(0xFF3D7A8A),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, size: 18, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4, left: 4),
                    child: Text(
                      senderName,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF3D7A8A), fontWeight: FontWeight.bold),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isMe ? const Color(0xFFE8D8C0) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                      bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    text,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF2D2D2D)),
                    textAlign: TextAlign.right,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, right: 4),
                  child: Text(
                    time,
                    style: const TextStyle(fontSize: 10, color: Color(0xFF9A8070)),
                  ),
                ),
              ],
            ),
          ),

          if (isMe) ...[
            const SizedBox(width: 8),
            Container(
              width: 30,
              height: 30,
              decoration: const BoxDecoration(
                color: Color(0xFFD4845A),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person, size: 18, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }
}
