import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../theme/app_colors.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
class LiveChatWidget extends StatefulWidget {
  const LiveChatWidget({Key? key}) : super(key: key);

  @override
  State<LiveChatWidget> createState() => _LiveChatWidgetState();
}

class _LiveChatWidgetState extends State<LiveChatWidget> {
  bool _isOpen = false;
  bool _isUploadingImage = false;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? _chatSessionId;
  String _userName = 'Guest';

  // Replace with your actual Gemini API Key from Google AI Studio
  static const String _geminiApiKey =
      'YOUR_GEMINI_API_KEY_HERE';
  late final GenerativeModel _model;
  ChatSession? _aiChatSession;

  @override
  void initState() {
    super.initState();
    _initChatSession();

    // Initialize Gemini AI Model
    if (_geminiApiKey != 'YOUR_GEMINI_API_KEY_HERE') {
      _model = GenerativeModel(
        model: 'gemini-1.5-pro',
        apiKey: _geminiApiKey,
        systemInstruction: Content.system(
          "You are a helpful customer support AI for a bakery called 'Nyse Bites'. Keep answers short, sweet, and friendly. If they ask for custom cakes or complex orders, tell them the admin will reply shortly. Don't invent fake prices, just direct them to the menu.",
        ),
      );
    }
  }

  Future<void> _initChatSession() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _chatSessionId = user.uid;
      _userName = user.email?.split('@').first ?? 'Customer';
    } else {
      // For guest users, generate a random temporary session ID
      _chatSessionId = 'guest_${DateTime.now().millisecondsSinceEpoch}';
    }

    // Create or update the chat session document
    await FirebaseFirestore.instance
        .collection('support_chats')
        .doc(_chatSessionId)
        .set({
          'userId': _chatSessionId,
          'userName': _userName,
          'lastMessage': 'Chat started',
          'lastMessageAt': FieldValue.serverTimestamp(),
          'isResolved': false,
        }, SetOptions(merge: true));

    final messagesRef = FirebaseFirestore.instance
        .collection('support_chats')
        .doc(_chatSessionId)
        .collection('messages');

    final msgs = await messagesRef.orderBy('timestamp').get();
    
    List<Content> history = [];

    if (msgs.docs.isEmpty) {
      await messagesRef.add({
        'text': 'Hi there! 👋 Welcome to Nyse Bites. How can we sweeten your day?',
        'sender': 'ai',
        'timestamp': FieldValue.serverTimestamp(),
      });
      history.add(Content.model([TextPart('Hi there! 👋 Welcome to Nyse Bites. How can we sweeten your day?')]));

      await FirebaseFirestore.instance
          .collection('support_chats')
          .doc(_chatSessionId)
          .update({
            'lastMessage': 'Hello! How can we help you today?',
            'lastMessageAt': FieldValue.serverTimestamp(),
          });
    } else {
      for (var doc in msgs.docs) {
        final data = doc.data();
        final text = data['text'] ?? '';
        final sender = data['sender'];
        if (text.isNotEmpty) {
          if (sender == 'ai') {
            history.add(Content.model([TextPart(text)]));
          } else {
            history.add(Content.text(text));
          }
        }
      }
    }

    if (_geminiApiKey != 'YOUR_GEMINI_API_KEY_HERE') {
      _aiChatSession = _model.startChat(history: history);
    }
  }

  void _toggleChat() {
    setState(() {
      _isOpen = !_isOpen;
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _chatSessionId == null) return;

    _messageController.clear();

    final messagesRef = FirebaseFirestore.instance
        .collection('support_chats')
        .doc(_chatSessionId)
        .collection('messages');

    // Check if this is the first message from the user
    final userMsgs = await messagesRef.where('sender', isEqualTo: 'user').limit(1).get();
    final isFirstUserMessage = userMsgs.docs.isEmpty;
    // Save user message to Firestore
    await messagesRef.add({
      'text': text,
      'sender': 'user',
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update last message in parent doc
    await FirebaseFirestore.instance
        .collection('support_chats')
        .doc(_chatSessionId)
        .update({
          'lastMessage': text,
          'lastMessageAt': FieldValue.serverTimestamp(),
          'adminUnread': true,
        });

    _scrollToBottom();

    // Trigger Gemini AI Reply if configured
    if (_geminiApiKey != 'YOUR_GEMINI_API_KEY_HERE' && _aiChatSession != null) {
      try {
        final response = await _aiChatSession!.sendMessage(Content.text(text));
        final aiText =
            response.text ?? 'Sorry, I am having trouble understanding.';

        await messagesRef.add({
          'text': aiText,
          'sender': 'ai',
          'timestamp': FieldValue.serverTimestamp(),
        });

        await FirebaseFirestore.instance
            .collection('support_chats')
            .doc(_chatSessionId)
            .update({
              'lastMessage': 'AI Replied...',
              'lastMessageAt': FieldValue.serverTimestamp(),
            });
        _scrollToBottom();
      } catch (e) {
        debugPrint('Gemini Error: $e');
      }
    }

    if (isFirstUserMessage) {
      // Trigger Admin Email Notification via EmailJS
      try {
        final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
        await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'service_id': 'service_lknatb4',
            'template_id': 'template_slz600e',
            'user_id': 'v7VSBAFbXx0Qqp1l8',
            'template_params': {
              'order_id': 'NEW SUPPORT CHAT',
              'customer_name': _userName,
              'total': 'Needs Reply',
              'items': '$_userName just started a live support chat! They said: "$text".\\n\\nPlease check the Admin Dashboard to reply.',
            },
          }),
        );
      } catch (e) {
        debugPrint('Failed to send chat email alert: $e');
      }
    }
  }

  Future<void> _pickAndSendImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery, 
      imageQuality: 50,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (pickedFile == null || _chatSessionId == null) return;
    
    setState(() => _isUploadingImage = true);
    try {
      final bytes = await pickedFile.readAsBytes();
      final base64String = base64Encode(bytes);
      
      final messagesRef = FirebaseFirestore.instance
          .collection('support_chats')
          .doc(_chatSessionId)
          .collection('messages');

      await messagesRef.add({
        'text': '',
        'imageUrl': 'data:image/jpeg;base64,$base64String',
        'sender': 'user',
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      await FirebaseFirestore.instance.collection('support_chats').doc(_chatSessionId).update({
        'lastMessage': 'Sent an image',
        'lastMessageAt': FieldValue.serverTimestamp(),
      });
      _scrollToBottom();
    } catch (e) {
      debugPrint('Error uploading image: $e');
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }

  String _formatChatTimestamp(Timestamp timestamp) {
    final DateTime dt = timestamp.toDate();
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 500;

    final double bottomPosition = isMobile ? 16 : 24;
    final double rightPosition = isMobile ? 16 : 24;
    final double chatWidth = isMobile ? (screenWidth - 32) : 350;
    final double chatHeight = isMobile ? (screenHeight * 0.75).clamp(300.0, 500.0) : 500;

    if (!_isOpen) {
      return Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: bottomPosition,
            right: rightPosition,
          ),
          child: GestureDetector(
            onTap: _toggleChat,
            child: Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.brandRed,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 24),
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: bottomPosition,
          right: rightPosition,
        ),
        child: Material(
        elevation: 12,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: chatWidth,
          height: chatHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.bgPastelPink, width: 2),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.darkGarnet,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.support_agent_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Nyse Bites Support',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: _toggleChat,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              // Warning if no API key
              if (_geminiApiKey == 'YOUR_GEMINI_API_KEY_HERE')
                Container(
                  color: Colors.amber.shade100,
                  padding: const EdgeInsets.all(8),
                  child: const Text(
                    '⚠️ Gemini AI is disabled. Replace YOUR_GEMINI_API_KEY_HERE in the code to enable auto-replies.',
                    style: TextStyle(fontSize: 11, color: Colors.brown),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Chat Messages
              Expanded(
                child: _chatSessionId == null
                    ? const Center(child: CircularProgressIndicator())
                    : StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('support_chats')
                            .doc(_chatSessionId)
                            .collection('messages')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          }
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final docs = snapshot.data!.docs.toList();
                          try {
                            docs.sort((a, b) {
                              final aData = a.data() as Map<String, dynamic>;
                              final bData = b.data() as Map<String, dynamic>;
                              final aTime = aData['timestamp'];
                              final bTime = bData['timestamp'];
                              if (aTime is Timestamp && bTime is Timestamp) {
                                return aTime.compareTo(bTime);
                              }
                              return 0;
                            });
                          } catch (_) {}
                          final messages = docs;

                          WidgetsBinding.instance.addPostFrameCallback(
                            (_) => _scrollToBottom(),
                          );

                          if (messages.isEmpty) {
                            return const Center(
                              child: Text(
                                'Send a message to start chatting!',
                                style: TextStyle(color: Colors.grey),
                              ),
                            );
                          }

                          return ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final msg =
                                  messages[index].data()
                                      as Map<String, dynamic>;
                              final isUser = msg['sender'] == 'user';
                              final isAI = msg['sender'] == 'ai';

                              return Align(
                                alignment: isUser
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isUser
                                        ? AppColors.brandRed
                                        : (isAI
                                              ? Colors.blueGrey.shade50
                                              : Colors.grey.shade200),
                                    borderRadius: BorderRadius.circular(12)
                                        .copyWith(
                                          bottomRight: isUser
                                              ? const Radius.circular(0)
                                              : const Radius.circular(12),
                                          bottomLeft: !isUser
                                              ? const Radius.circular(0)
                                              : const Radius.circular(12),
                                        ),
                                  ),
                                  constraints: const BoxConstraints(
                                    maxWidth: 250,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (!isUser)
                                        Text(
                                          isAI
                                              ? 'Nyse Bites AI'
                                              : 'Nyse Bites Admin',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: isAI
                                                ? AppColors.brandRed
                                                : AppColors.darkGarnet,
                                          ),
                                        ),
                                      const SizedBox(height: 2),
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
                                              color: isUser
                                                  ? Colors.white
                                                  : Colors.black87,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      if (msg['timestamp'] != null)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4.0),
                                          child: Text(
                                            _formatChatTimestamp(msg['timestamp'] as Timestamp),
                                            style: TextStyle(
                                              fontSize: 9,
                                              color: isUser ? Colors.white70 : Colors.black54,
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

              // Input Field
              Container(
                padding: const EdgeInsets.all(8),
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
                      onPressed: _isUploadingImage ? null : _pickAndSendImage,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: const BoxDecoration(
                        color: AppColors.brandRed,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
