class QuoteModel {
  final String id;
  final String text;
  final String author;
  final List<String> tags;

  /// ID користувача (Firebase Auth UID), який створив цитату
  final String userId;
  final String createdAt;

  /// Опціональний URL на зображення/прев’ю цитати в Cloud Storage
  final String? thumbnailUrl;
  bool isFavorite;

  QuoteModel({
    required this.id,
    required this.text,
    required this.author,
    required this.tags,
    required this.userId,
    required this.createdAt,
    this.thumbnailUrl,
    this.isFavorite = false,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json, String id) {
    return QuoteModel(
      id: id,
      text: json['text'] as String? ?? '',
      author: json['author'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      userId: json['userId'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String?,
      // Ознака "улюблена" тепер зберігається у окремій колекції favorites
      // і виставляється на клієнті, тому тут завжди false за замовчуванням.
      isFavorite: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'author': author,
      'tags': tags,
      'userId': userId,
      'createdAt': createdAt,
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
    };
  }

  QuoteModel copyWith({
    String? text,
    String? author,
    List<String>? tags,
    String? thumbnailUrl,
    bool? isFavorite,
  }) {
    return QuoteModel(
      id: id,
      text: text ?? this.text,
      author: author ?? this.author,
      tags: tags ?? this.tags,
      userId: userId,
      createdAt: createdAt,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class UserModel {
  final String email;
  final String name;
  final String password;

  UserModel({required this.email, required this.name, required this.password});
}
