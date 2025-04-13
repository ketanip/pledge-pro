import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMember {
  final String username;
  final String sub;
  final Timestamp joinedOn;

  ChatMember({
    required this.username,
    required this.sub,
    required this.joinedOn,
  });

  factory ChatMember.fromJson(Map<String, dynamic> json) {
    return ChatMember(
      username: json['username'],
      sub: json['sub'],
      joinedOn: json['joinedOn'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'username': username, 'sub': sub, 'joinedOn': joinedOn};
  }
}

class Chat {
  final String chatId;
  final String name;
  final List<ChatMember> members;
  final List<String> memberUids;

  Chat({
    required this.chatId,
    required this.name,
    required this.members,
    required this.memberUids,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    final members =
        (json['members'] as List).map((e) => ChatMember.fromJson(e)).toList();

    return Chat(
      chatId: json['chatId'],
      name:
          json['name'] ??
          (members.length > 1 ? members[1].username : members.first.username),
      members: members,
      memberUids: List<String>.from(
        json['memberUids'] ??
            members.map((member) => member.sub), // fallback support
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'name': name,
      'members': members.map((e) => e.toJson()).toList(),
      'memberUids': memberUids,
    };
  }
}

class ChatMessage {
  final String id;
  final String chatId;
  final String message;
  final String sentBy;
  final Timestamp sentAt;

  ChatMessage({
    required this.id,
    required this.chatId,
    required this.message,
    required this.sentBy,
    required this.sentAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      chatId: json['chatId'],
      message: json['message'],
      sentBy: json['sentBy'],
      sentAt: json['sentAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'message': message,
      'sentBy': sentBy,
      'sentAt': sentAt,
    };
  }
}
