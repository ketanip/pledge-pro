class Post {
  final String id;
  final List<String> imageUrls;
  final String caption;
  final String username;
  final int likeCount;

  Post({
    required this.id,
    required this.imageUrls,
    required this.caption,
    required this.username,
    required this.likeCount,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      imageUrls: (json['imageUrls'] ?? []).cast<String>(),
      caption: json['caption'] ?? " ",
      username: json['username'],
      likeCount: json['likeCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'imageUrls': imageUrls,
    'caption': caption,
    'username': username,
    'likeCount': likeCount,
  };
}
