class QuoteModel {
  final String id;
  final String text;
  final String author;
  final List<String> tags;
  final String userId;
  final String createdAt;
  bool isFavorite;

  QuoteModel({
    required this.id,
    required this.text,
    required this.author,
    required this.tags,
    required this.userId,
    required this.createdAt,
    this.isFavorite = false,
  });
}

class UserModel {
  final String email;
  final String name;
  final String password;

  UserModel({
    required this.email,
    required this.name,
    required this.password,
  });
}