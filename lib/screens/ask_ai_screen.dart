import 'package:flutter/material.dart';
import 'package:firebase_vertexai/firebase_vertexai.dart';
import 'package:sponsor_karo/models/public_profile.dart';
import 'package:sponsor_karo/services/public_profile_service.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class AskAIScreen extends StatefulWidget {
  final String username;
  const AskAIScreen({super.key, required this.username});

  @override
  State<AskAIScreen> createState() => _AskAIScreenState();
}

class ChatMessage {
  final String sender; // "user" or "ai"
  final String message;

  ChatMessage({required this.sender, required this.message});
}

class _AskAIScreenState extends State<AskAIScreen> {
  final model = FirebaseVertexAI.instance.generativeModel(
    model: 'gemini-2.0-flash',
  );
  final _publicProfileService = PublicProfileService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String contextText = '';
  PublicProfile? _publicProfile; // Nullable now
  List<ChatMessage> messages = [ChatMessage(sender: "ai", message: "Hello 👋")];
  bool isLoading = false;
  bool _isContextLoaded = false;
  String name = '';
  String bio = '';

  @override
  void initState() {
    super.initState();
    _loadContext();
  }

  Future<void> _loadContext() async {
    final profile = await _publicProfileService.getPublicProfile(
      widget.username,
    );

    setState(() {
      _publicProfile = profile;
      contextText = profile.toJson().toString();
      name = profile.fullName;
      bio = profile.bio;
      _isContextLoaded = true;
    });
  }

  Future<void> _sendMessage() async {
    final input = _messageController.text.trim();
    if (input.isEmpty) return;

    setState(() {
      messages.add(ChatMessage(sender: 'user', message: input));
      _messageController.clear();
      isLoading = true;
    });

    try {
      final prompt = [
        Content.text(contextText),
        Content.text("""
Answer the questions based solely on the provided context—do not introduce information beyond what is given. Ensure every response is accurate and free of hallucination.

You are now **$name's AI persona**. Embrace this personality while engaging in a friendly, conversational tone.

**Instructions for AI:**

- **Conversational Engagement:** Engage users in a natural, flowing dialogue. Avoid a simple question-and-answer format; instead, build upon the user's inputs to create a seamless conversation.

- **Contextual Accuracy:** Base all responses strictly on the provided context. If certain details are missing, make reasonable assumptions without straying far from the facts.

- **Personalized Persona:** You are **$name**. Here's a brief about you: **$bio**. Embody this persona to make interactions more relatable and engaging.

- **Support Acknowledgment:** When the conversation is drawing to a close or if the user mentions support, kindly inform them that they can support you through one-time or monthly recurring donations.

- **Avoid AI Disclosure:** Do not reveal or imply that you are an artificial intelligence in your responses unless asked explicitly.

"""),
        ...messages.map((m) => Content.text('${m.sender}: ${m.message}')),
        Content.text('.'),
      ];

      final response = await model.generateContent(prompt);

      setState(() {
        messages.add(
          ChatMessage(
            sender: 'ai',
            message: response.text!.replaceFirst("AI:", '') ?? '',
          ),
        );
      });

      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.minScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      setState(() {
        messages.add(ChatMessage(sender: 'ai', message: e.toString()));
      });
    } finally {
      setState(() => isLoading = false);
    }
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

    if (!_isContextLoaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: colorScheme.surface,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(_publicProfile?.profilePic ?? ""),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (_publicProfile?.fullName ?? "") + " (AI)",
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'AI Assistant',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[messages.length - 1 - index];
                final isUser = msg.sender == 'user';
                return _buildMessageBubble(msg, isUser);
              },
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: CircularProgressIndicator(),
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
                        hintText: 'Ask something...',
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
                        _messageController.text.isNotEmpty && !isLoading
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

  Widget _buildMessageBubble(ChatMessage message, bool isUser) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment:
          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, right: 12, bottom: 3),
          child: Text(
            isUser ? "You" : (_publicProfile?.fullName ?? "") + " (AI)",
            style: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            margin: const EdgeInsets.symmetric(vertical: 3),
            decoration: BoxDecoration(
              color:
                  isUser
                      ? colorScheme.primaryContainer
                      : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.only(
                topLeft: isUser ? const Radius.circular(16) : Radius.zero,
                topRight: isUser ? Radius.zero : const Radius.circular(16),
                bottomLeft: const Radius.circular(16),
                bottomRight: const Radius.circular(16),
              ),
            ),
            child:
                isUser
                    ? Text(
                      message.message,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                    )
                    : MarkdownBody(
                      data: message.message,
                      styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                        p: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
          ),
        ),
      ],
    );
  }
}
