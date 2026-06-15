class CommentModel {
  final String? id;
  final String content;
  final String authorName;
  final DateTime createdAt;
  final String? authorImageUrl;

  CommentModel({
    this.id,
    required this.content,
    required this.authorName,
    required this.createdAt,
    required this.authorImageUrl
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final authorJson = json['author'] as Map<String, dynamic>?;

    return CommentModel(
      id: json['id']?.toString(),
      content: json['content'] ?? '',
      authorName: authorJson?['username'] ?? json['authorName'] ?? 'Usuario',
      authorImageUrl: authorJson?['profilePictureUrl'] ?? json['authorProfilePicture'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }
}