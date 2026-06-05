class PublicationModel {
  final int? id;
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
    return PublicationModel(
      id: json['id'],
      authorName: json['authorName'] ?? 'Usuario',
      authorRole: json['authorRole'] ?? 'REGULAR',
      content: json['content'] ?? '',
      imageUrl: json['imageUrl'],
      likesCount: json['likesCount'] ?? 0,
      region: json['region'] ?? '',
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