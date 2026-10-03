import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import '../../../theme/app_colors.dart';

class SupportChatsTab extends StatefulWidget {
  final String searchQuery;
  const SupportChatsTab({Key? key, this.searchQuery = ''}) : super(key: key);

  @override
  State<SupportChatsTab> createState() => _SupportChatsTabState();
}

class _SupportChatsTabState extends State<SupportChatsTab> {
  String? _selectedChatId;
  bool _isUploadingImage = false;
  final TextEditingController _replyController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Future<void> _sendAdminReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty || _selectedChatId == null) return;
    
    _replyController.clear();
    
    // Add admin message
    await FirebaseFirestore.instance
        .collection('support_chats')
        .doc(_selectedChatId)
        .collection('messages')
        .add({
      'text': text,
      'sender': 'admin',
      'timestamp': FieldValue.serverTimestamp(),
    });
    
    // Update parent doc
    await FirebaseFirestore.instance.collection('support_chats').doc(_selectedChatId).update({
      'lastMessage': 'Admin: $text',
      'lastMessageAt': FieldValue.serverTimestamp(),
      'adminUnread': false,
    });
    
    _scrollToBottom();
  }

  Future<void> _pickAndSendAdminImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery, 
      imageQuality: 50,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (pickedFile == null || _selectedChatId == null) return;
    
    setState(() => _isUploadingImage = true);
    try {
      final bytes = await pickedFile.readAsBytes();
      final base64String = base64Encode(bytes);
      
      final messagesRef = FirebaseFirestore.instance
          .collection('support_chats')
          .doc(_selectedChatId)
          .collection('messages');

      await messagesRef.add({
        'text': '',
        'imageUrl': 'data:image/jpeg;base64,$base64String',
        'sender': 'admin',
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      await FirebaseFirestore.instance.collection('support_chats').doc(_selectedChatId).update({
        'lastMessage': 'Admin: Sent an image',
        'lastMessageAt': FieldValue.serverTimestamp(),
        'adminUnread': false,
      });
      _scrollToBottom();
    } catch (e) {
      debugPrint('Error uploading image: $e');
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Chat List
        Container(
          width: 320,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(right: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Live Support Chats',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDarkBerry,
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('support_chats')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                    if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                    
                    final docs = snapshot.data!.docs.toList();
                    try {
                      docs.sort((a, b) {
                        final aData = a.data() as Map<String, dynamic>;
                        final bData = b.data() as Map<String, dynamic>;
                        final aTime = aData['lastMessageAt'];
                        final bTime = bData['lastMessageAt'];
                        if (aTime is Timestamp && bTime is Timestamp) {
                          return bTime.compareTo(aTime); // descending
                        }
                        return 0;
                      });
                    } catch (_) {}
                    final chats = docs.where((doc) {
                      if (widget.searchQuery.trim().isEmpty) return true;
                      final data = doc.data() as Map<String, dynamic>;
                      final q = widget.searchQuery.toLowerCase();
                      return (data['userName'] ?? '').toString().toLowerCase().contains(q) ||
                             (data['lastMessage'] ?? '').toString().toLowerCase().contains(q) ||
                             (data['userEmail'] ?? '').toString().toLowerCase().contains(q);
                    }).toList();
                    
                    if (chats.isEmpty) {
                      return const Center(child: Text('No active chats.'));
                    }

                    return ListView.builder(
                      itemCount: chats.length,
                      itemBuilder: (context, index) {
                        final chat = chats[index].data() as Map<String, dynamic>;
                        final chatId = chats[index].id;
                        final isSelected = _selectedChatId == chatId;
                        final hasUnread = chat['adminUnread'] == true;
                        
                        DateTime? time;
                        if (chat['lastMessageAt'] != null) {
                          time = (chat['lastMessageAt'] as Timestamp).toDate();
                        }
                        
                        return ListTile(
                          selected: isSelected,
                          selectedTileColor: AppColors.bgPastelPink.withOpacity(0.3),
                          leading: CircleAvatar(
                            backgroundColor: hasUnread ? AppColors.brandRed : Colors.grey.shade300,
                            child: Icon(Icons.person, color: hasUnread ? Colors.white : Colors.grey.shade700),
                          ),
                          title: Text(
                            chat['userName'] ?? 'Guest',
                            style: TextStyle(fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal),
                          ),
                          subtitle: Text(
                            chat['lastMessage'] ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal),
                          ),
                          trailing: time != null
                              ? Text(DateFormat('hh:mm a').format(time), style: const TextStyle(fontSize: 12))
                              : null,
                          onTap: () {
                            setState(() => _selectedChatId = chatId);
                            FirebaseFirestore.instance.collection('support_chats').doc(chatId).update({
                              'adminUnread': false,
                            });
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        
        // Chat View
        Expanded(
          child: _selectedChatId == null
              ? const Center(child: Text('Select a chat to reply', style: TextStyle(color: Colors.grey)))
              : Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      color: AppColors.darkGarnet,
                      child: const Row(
                        children: [
                          Icon(Icons.headset_mic_rounded, color: Colors.white),
                          SizedBox(width: 12),
                          Text('Answering Chat', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    
                    // Messages
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('support_chats')
                            .doc(_selectedChatId)
                            .collection('messages')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                          
                          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                          
                          final docs = snapshot.data!.docs.toList();
                          try {
                            docs.sort((a, b) {
                              final aData = a.data() as Map<String, dynamic>;
                              final bData = b.data() as Map<String, dynamic>;
                              final aTime = aData['timestamp'];
                              final bTime = bData['timestamp'];
                              if (aTime is Timestamp && bTime is Timestamp) {
                                return aTime.compareTo(bTime); // ascending
                              }
                              return 0;
                            });
                          } catch (_) {}
                          final messages = docs;
                          
                          return ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final msg = messages[index].data() as Map<String, dynamic>;
                              final sender = msg['sender']; // 'user', 'ai', 'admin'
                              final isAdmin = sender == 'admin';
                              
                              return Align(
                                alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isAdmin 
                                        ? AppColors.darkGarnet 
                                        : (sender == 'ai' ? Colors.blueGrey.shade100 : Colors.grey.shade200),
                                    borderRadius: BorderRadius.circular(16).copyWith(
                                      bottomLeft: !isAdmin ? const Radius.circular(0) : const Radius.circular(16),
                                      bottomRight: isAdmin ? const Radius.circular(0) : const Radius.circular(16),
                                    ),
                                  ),
                                  constraints: const BoxConstraints(maxWidth: 400),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        sender == 'admin' ? 'You' : (sender == 'ai' ? 'Nyse Bites AI ✨' : 'Customer'),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: sender == 'admin' ? Colors.white70 : Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      if (msg['imageUrl'] != null && msg['imageUrl'].toString().startsWith('data:image'))
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 8.0),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.memory(
                                              base64Decode(msg['imageUrl'].split(',').last),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      if ((msg['text'] ?? '').isNotEmpty)
                                        MarkdownBody(
                                          data: msg['text'] ?? '',
                                          styleSheet: MarkdownStyleSheet(
                                            p: TextStyle(
                                              color: sender == 'admin' ? Colors.white : Colors.black87,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      if (msg['timestamp'] != null)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4.0),
                                          child: Text(
                                            DateFormat('hh:mm a').format((msg['timestamp'] as Timestamp).toDate()),
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: sender == 'admin' ? Colors.white70 : Colors.black54,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    
                    // Reply Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(top: BorderSide(color: Colors.grey.shade200)),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: _isUploadingImage 
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                                : const Icon(Icons.image, color: Colors.grey),
                            onPressed: _isUploadingImage ? null : _pickAndSendAdminImage,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _replyController,
                              decoration: InputDecoration(
                                hintText: 'Type your reply...',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              ),
                              onSubmitted: (_) => _sendAdminReply(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          FloatingActionButton(
                            onPressed: _sendAdminReply,
                            backgroundColor: AppColors.brandRed,
                            child: const Icon(Icons.send_rounded, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
