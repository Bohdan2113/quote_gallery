// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:quote_gallery/main.dart';
import 'package:quote_gallery/presentation/state/quotes_provider.dart';

void main() {
  testWidgets('App builds without provider errors', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => QuotesProvider())],
        child: const QuoteGalleryApp(),
      ),
    );

    // Просто перевіряємо, що головний екран будується без помилок.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
