import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cashaclin/main.dart';

void main() {
  testWidgets('App starts smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Pasamos isLoggedIn: false como estado inicial para el test
    await tester.pumpWidget(const MyApp(isLoggedIn: false));

    // Verificamos que la app inicie (en este caso, en la pantalla de Login)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
