class Comment {
  final int id;
  final String comment;
  final String userName;
  final String createdAt;

  Comment({
    required this.id,
    required this.comment,
    required this.userName,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      comment: json['comment'] ?? '',
      userName: json['user']['name'] ?? 'User',
      createdAt: json['created_at'] ?? '',
    );
  }
}
