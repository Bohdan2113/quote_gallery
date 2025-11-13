import 'package:flutter/material.dart';
import 'presentation/screens/auth/auth_screen.dart';
import 'presentation/screens/main/main_screen.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const QuoteGalleryApp());
}

class QuoteGalleryApp extends StatelessWidget {
  const QuoteGalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuoteGallery',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthScreen(),
      routes: {
        '/auth': (context) => const AuthScreen(),
        '/main': (context) => const MainScreen(),
      },
    );
  }
}