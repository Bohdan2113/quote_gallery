import 'package:cloud_firestore/cloud_firestore.dart';

/// Репозиторій для роботи з улюбленими цитатами (зв'язок N–N між користувачами та цитатами).
///
/// Структура в Firestore:
/// collection: favorites
///   documentId: "{userId}_{quoteId}"
///   fields:
///     - userId: string
///     - quoteId: string
///     - createdAt: string (ISO8601)
abstract class IFavoritesRepository {
  /// Повертає множину ID цитат, які користувач позначив як улюблені.
  Future<Set<String>> getUserFavoritesOnce(String userId);

  /// Додає або прибирає цитату з улюблених.
  Future<void> setFavorite({
    required String userId,
    required String quoteId,
    required bool isFavorite,
  });
}

class FavoritesRepository implements IFavoritesRepository {
  FavoritesRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('favorites');

  @override
  Future<Set<String>> getUserFavoritesOnce(String userId) async {
    final snapshot = await _collection.where('userId', isEqualTo: userId).get();
    return snapshot.docs.map((doc) => doc.data()['quoteId'] as String).toSet();
  }

  @override
  Future<void> setFavorite({
    required String userId,
    required String quoteId,
    required bool isFavorite,
  }) async {
    final docId = '${userId}_$quoteId';
    final docRef = _collection.doc(docId);

    if (isFavorite) {
      await docRef.set({
        'userId': userId,
        'quoteId': quoteId,
        'createdAt': DateTime.now().toIso8601String(),
      });
    } else {
      await docRef.delete();
    }
  }
}
