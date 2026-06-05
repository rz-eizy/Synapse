class PublicationModel {
  final String? id;
  final String authorName;
  final String authorRole;
  final String content;
  final String? imageUrl;
  final int likesCount;
  final String region;
  final DateTime createdAt;

  PublicationModel({
    this.id,
    required this.authorName,
    required this.authorRole,
    required this.content,
    this.imageUrl,
    this.likesCount = 0,
    required this.region,
    required this.createdAt,
  });

  factory PublicationModel.fromJson(Map<String, dynamic> json) {
    final authorJson = json['author'] as Map<String, dynamic>?;
    return PublicationModel(
      id: json['id']?.toString(),
      authorName: authorJson?['username'] ?? json['authorName'] ?? 'Usuario Anónimo',
      authorRole: authorJson?['role'] ?? json['authorRole'] ?? 'REGULAR',
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'],
      likesCount: json['likes'] ?? 0,
      region: json['regionTag'] ?? json['region'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'imageUrl': imageUrl,
    };
  }
}