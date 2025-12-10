import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/mock/mock_data.dart';
import '../../data/models/quote_model.dart';

enum QuotesStatus { initial, loading, loaded, error }

class QuotesProvider extends ChangeNotifier {
  QuotesStatus _status = QuotesStatus.initial;
  List<QuoteModel> _quotes = [];
  String? _errorMessage;

  QuotesStatus get status => _status;
  List<QuoteModel> get quotes => List.unmodifiable(_quotes);
  String? get errorMessage => _errorMessage;

  Future<void> loadQuotes() async {
    _setStatus(QuotesStatus.loading);

    try {
      // Імітація завантаження даних (наприклад, із локальної БД або API)
      await Future<void>.delayed(const Duration(milliseconds: 500));

      final result = List<QuoteModel>.from(MockData.mockQuotes);
      _quotes = result;
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
}
