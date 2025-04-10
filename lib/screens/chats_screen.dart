import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sponsor_karo/models/chat.dart';
import 'package:sponsor_karo/models/public_profile.dart';
import 'package:sponsor_karo/screens/individual_chat_screen.dart';
import 'package:sponsor_karo/services/chat_service.dart';
import 'package:sponsor_karo/services/public_profile_service.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatService _chatService = ChatService();
  final PublicProfileService _publicProfileService = PublicProfileService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late String currentUser;
  List<Chat> chatData = [];
  List<Chat> filteredChats = [];
  TextEditingController searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchChatData();
    searchController.addListener(() => _filterChats(searchController.text));
  }

  Future<void> _fetchChatData() async {
    final chats = await _chatService.getCurrentUserChats();
    setState(() {
      currentUser = _auth.currentUser?.uid ?? "active_user";
      chatData = chats;
      filteredChats = chats;
      isLoading = false;
    });
  }

  void _filterChats(String query) {
    setState(() {
      filteredChats = query.isEmpty
          ? List.from(chatData)
          : chatData
              .where((chat) => chat.members
                  .any((member) => member.username.toLowerCase().contains(query.toLowerCase())))
              .toList();
    });
  }

  Future<PublicProfile> _getPublicProfile(String username) async {
    return await _publicProfileService.getPublicProfile(username);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Text(
          "Direct",
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: colorScheme.onSurface),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
                hintText: "Search",
                prefixIcon: Icon(
                  Icons.search,
                  color: colorScheme.onSurfaceVariant,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),

          // Chat List
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredChats.isEmpty
                    ? Center(
                        child: Text(
                          "No chats found",
                          style: textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: filteredChats.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: colorScheme.surfaceContainerHighest,
                        ),
                        itemBuilder: (context, index) {
                          final chat = filteredChats[index];
                          final otherMember = chat.members
                              .firstWhere((m) => m.sub != currentUser);
                          return FutureBuilder<PublicProfile>(
                            future: _getPublicProfile(otherMember.username),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return ListTile(
                                  leading: CircleAvatar(child: Icon(Icons.person)),
                                  title: Text("Loading..."),
                                );
                              }
                              final chatUser = snapshot.data!;
                              return _buildChatTile(chatUser, textTheme, colorScheme);
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTile(
    PublicProfile chatUser,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => IndividualChatScreen(user: chatUser),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(chatUser.profilePic),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        chatUser.fullName,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (chatUser.followerCount > 20)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.verified,
                            color: colorScheme.primary,
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.more_horiz,
              color: colorScheme.onSurfaceVariant,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
