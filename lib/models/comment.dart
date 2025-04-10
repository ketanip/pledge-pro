class Comment {
  final String id;
  final String postedBy; // username
  final String comment;

  Comment({required this.id, required this.postedBy, required this.comment});

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      postedBy: json['postedBy'],
      comment: json['comment'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'postedBy': postedBy,
    'comment': comment,
  };

  // 👇 Add this
  Comment copyWith({String? id, String? postedBy, String? comment}) {
    return Comment(
      id: id ?? this.id,
      postedBy: postedBy ?? this.postedBy,
      comment: comment ?? this.comment,
    );
  }
}
