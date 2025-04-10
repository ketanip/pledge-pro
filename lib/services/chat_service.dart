import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sponsor_karo/models/chat.dart';
import 'package:sponsor_karo/models/public_profile.dart';
import 'package:sponsor_karo/services/public_profile_service.dart';
import 'package:uuid/uuid.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final PublicProfileService _publicProfileService = PublicProfileService();

  final _uuid = const Uuid();

  CollectionReference get _chats => _firestore.collection('chats');

  Future<void> createChat(Chat chat) async {
    await _chats.doc(chat.chatId).set(chat.toJson());
  }

  /// Create or return chat with given UID
  Future<void> createChatWithUid(String uid) async {

    if (_auth.currentUser?.uid == null || _auth.currentUser?.uid == uid) return;

    final PublicProfile currentUser = await _publicProfileService
        .getPublicProfileBySub(_auth.currentUser?.uid ?? "");


    final PublicProfile otherUser = await _publicProfileService
        .getPublicProfileBySub(uid);

        

    final List<String> sortedUids = [currentUser.uid, otherUser.uid]..sort();

    // Find chats with current user
    final existingChatsSnapshot =
        await _chats.where('memberUids', arrayContains: currentUser.uid).get();

    // Check for exact match
    for (var doc in existingChatsSnapshot.docs) {
      final memberUids = List<String>.from(doc['memberUids'] ?? []);
      memberUids.sort();
      if (memberUids.length == 2 &&
          memberUids[0] == sortedUids[0] &&
          memberUids[1] == sortedUids[1]) {
        return; // Chat already exists
      }
    }

    // Create new chat
    final newChatId = _uuid.v4();
    final timestamp = Timestamp.now();

    final newChat = {
      'chatId': newChatId,
      'name': null,
      'members': [
        {
          'username': currentUser.username,
          'sub': currentUser.uid,
          'joinedOn': timestamp,
        },
        {
          'username': otherUser.username,
          'sub': otherUser.uid,
          'joinedOn': timestamp,
        },
      ],
      'memberUids': sortedUids,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _chats.doc(newChatId).set(newChat);
  }

  Future<void> sendMessage({
    required String chatId,
    required String message,
    required String sentBy,
  }) async {
    final messageId = _uuid.v4();
    final msg = ChatMessage(
      id: messageId,
      chatId: chatId,
      message: message,
      sentBy: sentBy,
      sentAt: Timestamp.now(),
    );

    await _chats
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .set(msg.toJson());
  }

  Stream<List<ChatMessage>> getMessages(String chatId) {
    return _chats
        .doc(chatId)
        .collection('messages')
        .orderBy('sentAt', descending: false)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => ChatMessage.fromJson(doc.data()))
                  .toList(),
        );
  }

  Future<Chat?> getChatById(String chatId) async {
    final doc = await _chats.doc(chatId).get();
    if (doc.exists) {
      return Chat.fromJson(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<List<Chat>> getAllChatsForUser(String username) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception("User not logged in");

    final query =
        await _chats.where('memberUids', arrayContains: currentUser.uid).get();

    return query.docs
        .map((doc) => Chat.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<Chat>> getCurrentUserChats() async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception("User not logged in");
    }

    final querySnapshot =
        await _chats.where('memberUids', arrayContains: currentUser.uid).get();

    return querySnapshot.docs
        .map((doc) => Chat.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// 🔁 Migration function to add memberUids field to old chats
  Future<void> migrateChats_AddMemberUids() async {
    final querySnapshot = await _chats.get();

    for (var doc in querySnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;

      // Skip if memberUids already exists
      if (data.containsKey('memberUids')) continue;

      final members = data['members'] as List<dynamic>?;

      if (members == null || members.length < 2) continue;

      try {
        final uids = members.map((m) => m['sub'].toString()).toList()..sort();
        await doc.reference.update({'memberUids': uids});
      } catch (e) {
        print("Migration failed for chat ${doc.id}: $e");
      }
    }

    print("✅ Migration complete: memberUids added to existing chats.");
  }
}
