import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sponsor_karo/models/chat.dart';
import 'package:sponsor_karo/models/public_profile.dart';
import 'package:sponsor_karo/services/chat_service.dart';

class IndividualChatScreen extends StatefulWidget {
  final PublicProfile user;

  const IndividualChatScreen({super.key, required this.user});

  @override
  _IndividualChatScreenState createState() => _IndividualChatScreenState();
}

class _IndividualChatScreenState extends State<IndividualChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final ChatService _chatService = ChatService();
  Chat? _chat;
  Stream<List<ChatMessage>>? _messageStream;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    await _chatService.createChatWithUid(widget.user.uid);

    final allChats = await _chatService.getCurrentUserChats();
    final chat = allChats.firstWhere(
      (chat) => chat.memberUids.contains(widget.user.uid),
      orElse: () => throw Exception("Chat not found"),
    );

    if (!mounted) return; // Prevent setState on disposed widget

    setState(() {
      _chat = chat;
      _messageStream = _chatService.getMessages(chat.chatId);
    });
  }

  void _sendMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty || _chat == null) return;

    _messageController.clear();

    await _chatService.sendMessage(
      chatId: _chat!.chatId,
      message: messageText,
      sentBy: _auth.currentUser?.uid ?? "",
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: colorScheme.surface,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(widget.user.profilePic),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.fullName,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Active now',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [IconButton(icon: const Icon(Icons.report), onPressed: () {})],
      ),
      body: Column(
        children: [
          Expanded(
            child:
                _messageStream == null
                    ? const Center(child: CircularProgressIndicator())
                    : StreamBuilder<List<ChatMessage>>(
                      stream: _messageStream,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final messages = snapshot.data!;
                        return ListView.builder(
                          controller: _scrollController,
                          reverse: true,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message =
                                messages[messages.length - 1 - index];
                            final isMe =
                                message.sentBy == _auth.currentUser?.uid;
                            return _buildMessageBubble(message, isMe);
                          },
                        );
                      },
                    ),
          ),
          _buildInputField(colorScheme, textTheme),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget _buildInputField(ColorScheme colorScheme, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: colorScheme.outline),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 3,
                      onChanged: (text) => setState(() {}),
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 6),
                      ),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder:
                        (child, animation) =>
                            ScaleTransition(scale: animation, child: child),
                    child:
                        _messageController.text.isNotEmpty
                            ? GestureDetector(
                              key: const ValueKey('send'),
                              onTap: _sendMessage,
                              child: Icon(
                                Icons.send,
                                color: colorScheme.primary,
                              ),
                            )
                            : const SizedBox(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, right: 12, bottom: 3),
          child: Text(
            isMe ? "Me" : widget.user.fullName,
            style: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            margin: const EdgeInsets.symmetric(vertical: 3),
            decoration: BoxDecoration(
              color:
                  isMe
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.only(
                topLeft: isMe ? const Radius.circular(16) : Radius.zero,
                topRight: isMe ? Radius.zero : const Radius.circular(16),
                bottomLeft: const Radius.circular(16),
                bottomRight: const Radius.circular(16),
              ),
            ),
            child: Text(
              message.message,
              style: textTheme.bodyMedium?.copyWith(
                color:
                    isMe
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
