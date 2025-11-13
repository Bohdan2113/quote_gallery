import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Централізований сервіс для роботи з Firebase Analytics
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  bool _isInitialized = false;

  /// Ініціалізація Analytics
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _analytics.setAnalyticsCollectionEnabled(true);
      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      if (kDebugMode) {
        print('Analytics initialization error: $e');
      }
    }
  }

  /// Отримати екземпляр FirebaseAnalytics для навігації
  FirebaseAnalytics get analytics => _analytics;

  /// Логування події входу
  Future<void> logLogin({String method = 'email'}) async {
    if (!_isInitialized) return;

    try {
      await _analytics.logLogin(loginMethod: method);
    } catch (e) {
      if (kDebugMode) {
        print('Analytics logLogin error: $e');
      }
    }
  }

  /// Логування події реєстрації
  Future<void> logSignUp({String method = 'email'}) async {
    if (!_isInitialized) return;

    try {
      await _analytics.logSignUp(signUpMethod: method);
    } catch (e) {
      if (kDebugMode) {
        print('Analytics logSignUp error: $e');
      }
    }
  }

  /// Логування створення цитати
  Future<void> logCreateQuote({String? author, int? tagsCount}) async {
    final parameters = <String, dynamic>{};
    if (author != null) parameters['author'] = author;
    if (tagsCount != null) parameters['tags_count'] = tagsCount;

    await logEvent(
      name: 'create_quote',
      parameters: parameters.isNotEmpty ? parameters : null,
    );
  }

  /// Логування відкриття профілю
  Future<void> logOpenProfile() async {
    await logEvent(name: 'open_profile');
  }

  /// Логування перегляду всіх цитат
  Future<void> logViewAllQuotes() async {
    await logEvent(name: 'view_all_quotes');
  }

  /// Логування перегляду моїх цитат
  Future<void> logViewMyQuotes() async {
    await logEvent(name: 'view_my_quotes');
  }

  /// Логування перегляду улюблених
  Future<void> logViewFavorites() async {
    await logEvent(name: 'view_favorites');
  }

  /// Логування пошуку
  Future<void> logSearch({String? query}) async {
    await logEvent(
      name: 'search',
      parameters: query != null ? {'query': query} : null,
    );
  }

  /// Логування додавання до улюблених
  Future<void> logAddToFavorites({String? quoteId}) async {
    await logEvent(
      name: 'add_to_favorites',
      parameters: quoteId != null ? {'quote_id': quoteId} : null,
    );
  }

  /// Логування видалення з улюблених
  Future<void> logRemoveFromFavorites({String? quoteId}) async {
    await logEvent(
      name: 'remove_from_favorites',
      parameters: quoteId != null ? {'quote_id': quoteId} : null,
    );
  }

  /// Логування видалення цитати
  Future<void> logDeleteQuote() async {
    await logEvent(name: 'delete_quote');
  }

  /// Логування відкриття екрану створення цитати
  Future<void> logOpenCreateQuote() async {
    await logEvent(name: 'open_create_quote');
  }

  /// Логування події виходу
  Future<void> logLogout() async {
    await logEvent(name: 'logout');
  }

  /// Загальний метод для логування подій
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    if (!_isInitialized) return;

    // Перевірка довжини назви події (Firebase обмежує до 40 символів)
    if (name.length > 40) return;

    try {
      // Конвертація параметрів в правильний формат
      Map<String, Object>? params;
      if (parameters != null && parameters.isNotEmpty) {
        params = {};
        for (final entry in parameters.entries) {
          final key = entry.key.length > 40
              ? entry.key.substring(0, 40)
              : entry.key;
          final value = entry.value;
          if (value is String) {
            params[key] = value.length > 100 ? value.substring(0, 100) : value;
          } else if (value is num || value is bool) {
            params[key] = value;
          } else {
            params[key] = value.toString();
          }
        }
      }

      await _analytics.logEvent(name: name, parameters: params);
    } catch (e) {
      if (kDebugMode) {
        print('Analytics logEvent error for "$name": $e');
      }
    }
  }
}
