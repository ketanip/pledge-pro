import 'package:sponsor_karo/models/detail.dart';

class PublicProfile {
  final String uid; // Firebase UID
  final String username; // unique
  final String fullName;
  final String profilePic;
  final String bio;
  final List<Detail> details;
  final int followerCount;
  final int followingCount;

  PublicProfile({
    required this.uid,
    required this.username,
    required this.fullName,
    required this.profilePic,
    required this.bio,
    required this.details,
    this.followerCount = 0,
    this.followingCount = 0,
  });

  factory PublicProfile.fromJson(Map<String, dynamic> json) {
    return PublicProfile(
      uid: json['uid'] ?? '',
      username: json['username'],
      fullName: json['fullName'] ?? '',
      profilePic: json['profilePic'],
      bio: json['bio'],
      details:
          (json['details'] as List<dynamic>)
              .map((e) => Detail.fromJson(e))
              .toList(),
      followerCount: json['followerCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'username': username,
    'fullName': fullName,
    'profilePic': profilePic,
    'bio': bio,
    'details': details.map((e) => e.toJson()).toList(),
    'followerCount': followerCount,
    'followingCount': followingCount,
  };
}
