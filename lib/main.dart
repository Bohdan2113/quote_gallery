import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/quotes_repository.dart';
import 'data/repositories/favorites_repository.dart';
import 'presentation/screens/auth/auth_screen.dart';
import 'presentation/screens/main/main_screen.dart';
import 'presentation/state/quotes_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_strings.dart';
import 'core/services/analytics_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ініціалізація Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Ініціалізація Analytics
  await AnalyticsService().initialize();

  // Налаштування Crashlytics для обробки помилок (не підтримується на веб)
  if (!kIsWeb) {
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    // Обробка асинхронних помилок
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthRepository>(create: (_) => AuthRepository()),
        Provider<IQuotesRepository>(create: (_) => QuotesRepository()),
        Provider<IFavoritesRepository>(create: (_) => FavoritesRepository()),
        ChangeNotifierProvider(
          create: (context) => QuotesProvider(
            repository: context.read<IQuotesRepository>(),
            favoritesRepository: context.read<IFavoritesRepository>(),
            authRepository: context.read<AuthRepository>(),
          )..loadQuotes(),
        ),
      ],
      child: const QuoteGalleryApp(),
    ),
  );
}

class QuoteGalleryApp extends StatelessWidget {
  const QuoteGalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    final analyticsService = AnalyticsService();

    return MaterialApp(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Налаштування Firebase Analytics для автоматичного відстеження навігації
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analyticsService.analytics),
      ],
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) {
            return const MainScreen();
          }
          return const AuthScreen();
        },
      ),
      routes: {
        '/auth': (context) => const AuthScreen(),
        '/main': (context) => const MainScreen(),
      },
    );
  }
}
