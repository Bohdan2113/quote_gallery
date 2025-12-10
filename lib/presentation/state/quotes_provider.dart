import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/models/quote_model.dart';
import '../../data/repositories/quotes_repository.dart';
import '../../data/repositories/favorites_repository.dart';
import '../../data/repositories/auth_repository.dart';

enum QuotesStatus { initial, loading, loaded, error }

class QuotesProvider extends ChangeNotifier {
  QuotesProvider({
    required IQuotesRepository repository,
    required IFavoritesRepository favoritesRepository,
    required AuthRepository authRepository,
  }) : _repository = repository,
       _favoritesRepository = favoritesRepository,
       _authRepository = authRepository {
    // Перераховуємо улюблені цитати при зміні користувача
    _authSubscription = _authRepository.authStateChanges.listen((_) {
      _refreshFavoritesForCurrentUser();
    });
  }

  final IQuotesRepository _repository;
  final IFavoritesRepository _favoritesRepository;
  final AuthRepository _authRepository;

  QuotesStatus _status = QuotesStatus.initial;
  List<QuoteModel> _quotes = [];
  String? _errorMessage;
  Set<String> _favoriteIds = {};
  StreamSubscription<dynamic>? _authSubscription;

  QuotesStatus get status => _status;
  List<QuoteModel> get quotes => List.unmodifiable(_quotes);
  String? get errorMessage => _errorMessage;

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadQuotes() async {
    _setStatus(QuotesStatus.loading);

    try {
      final result = await _repository.getQuotesOnce();
      _quotes = result;

      // Перераховуємо улюблені для поточного користувача
      await _refreshFavoritesForCurrentUser();

      _errorMessage = null;
      _setStatus(QuotesStatus.loaded);
    } catch (e) {
      _errorMessage = 'Не вдалося завантажити цитати. Спробуйте ще раз.';
      _setStatus(QuotesStatus.error);
    }
  }

  /// Метод, який навмисне генерує помилку завантаження.
  /// Може бути використаний у звіті як приклад обробки помилкового сценарію.
  Future<void> loadQuotesWithError() async {
    _setStatus(QuotesStatus.loading);

    try {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      throw Exception('Test error');
    } catch (e) {
      _errorMessage = e.toString();
      _setStatus(QuotesStatus.error);
    }
  }

  void _setStatus(QuotesStatus newStatus) {
    _status = newStatus;
    notifyListeners();
  }

  Future<void> _refreshFavoritesForCurrentUser() async {
    final user = _authRepository.currentUser;

    // Спочатку очищаємо локальні улюблені
    _favoriteIds.clear();
    for (final quote in _quotes) {
      quote.isFavorite = false;
    }

    // Якщо користувач є – підтягуємо його улюблені
    if (user != null) {
      _favoriteIds = await _favoritesRepository.getUserFavoritesOnce(user.uid);
      for (final quote in _quotes) {
        quote.isFavorite = _favoriteIds.contains(quote.id);
      }
    }

    notifyListeners();
  }

  /// Створення нової цитати в Firestore.
  Future<void> createQuote({
    required String text,
    required String author,
    required List<String> tags,
    String? thumbnailUrl,
  }) async {
    final user = _authRepository.currentUser;
    if (user == null) {
      throw Exception('Користувач не авторизований');
    }

    final createdAt = DateTime.now().toIso8601String();

    final created = await _repository.createQuote(
      text: text,
      author: author,
      tags: tags,
      userId: user.uid,
      createdAt: createdAt,
      thumbnailUrl: thumbnailUrl,
    );

    _quotes = [created, ..._quotes];
    notifyListeners();
  }

  /// Оновлення існуючої цитати.
  Future<void> updateQuote(QuoteModel updated) async {
    await _repository.updateQuote(updated);
    _quotes = _quotes.map((q) => q.id == updated.id ? updated : q).toList();
    notifyListeners();
  }

  /// Видалення цитати.
  Future<void> deleteQuote(String id) async {
    await _repository.deleteQuote(id);
    _quotes = _quotes.where((q) => q.id != id).toList();
    notifyListeners();
  }

  /// Перемикання стану "обране" для цитати.
  Future<void> toggleFavorite(QuoteModel quote) async {
    final user = _authRepository.currentUser;
    if (user == null) {
      throw Exception('Користувач не авторизований');
    }

    final newValue = !quote.isFavorite;

    // Оновлюємо локальний стан
    quote.isFavorite = newValue;
    if (newValue) {
      _favoriteIds.add(quote.id);
    } else {
      _favoriteIds.remove(quote.id);
    }
    notifyListeners();

    // Оновлюємо зв'язок у колекції favorites (N–N)
    await _favoritesRepository.setFavorite(
      userId: user.uid,
      quoteId: quote.id,
      isFavorite: newValue,
    );
  }
}
