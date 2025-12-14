import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/quote_model.dart';

/// Абстракція репозиторію для роботи з цитатами у Firestore.
abstract class IQuotesRepository {
  // Stream<List<QuoteModel>> watchQuotes();

  Future<List<QuoteModel>> getQuotesOnce();

  Future<QuoteModel> createQuote({
    required String text,
    required String author,
    required List<String> tags,
    required String userId,
    required String createdAt,
    String? thumbnailUrl,
  });

  Future<void> updateQuote(QuoteModel quote);

  Future<void> deleteQuote(String id);
}

class QuotesRepository implements IQuotesRepository {
  QuotesRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('quotes');

  // @override
  // Stream<List<QuoteModel>> watchQuotes() {
  //   return _collection
  //       .orderBy('createdAt', descending: true)
  //       .snapshots()
  //       .map(
  //         (snapshot) => snapshot.docs
  //             .map((doc) => QuoteModel.fromJson(doc.data(), doc.id))
  //             .toList(),
  //       );
  // }

  @override
  Future<List<QuoteModel>> getQuotesOnce() async {
    final snapshot = await _collection
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => QuoteModel.fromJson(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<QuoteModel> createQuote({
    required String text,
    required String author,
    required List<String> tags,
    required String userId,
    required String createdAt,
    String? thumbnailUrl,
  }) async {
    final docRef = _collection.doc();
    final model = QuoteModel(
      id: docRef.id,
      text: text,
      author: author,
      tags: tags,
      userId: userId,
      createdAt: createdAt,
      thumbnailUrl: thumbnailUrl,
    );

    await docRef.set(model.toJson());
    return model;
  }

  @override
  Future<void> updateQuote(QuoteModel quote) {
    return _collection.doc(quote.id).update(quote.toJson());
  }

  @override
  Future<void> deleteQuote(String id) {
    return _collection.doc(id).delete();
  }
}
