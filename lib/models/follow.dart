class Follow {
  final String username; // The person being followed or who follows

  Follow({required this.username});

  factory Follow.fromJson(Map<String, dynamic> json) {
    return Follow(
      username: json['username'],
    );
  }

  Map<String, dynamic> toJson() => {
        'username': username,
      };
}
