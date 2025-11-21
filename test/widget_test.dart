import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:recettes_app/main.dart';

void main() {
  testWidgets('Smoke test RecettesApp', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RecettesApp());

    // Ici tu peux vérifier qu’un widget attendu est présent
    // Par exemple vérifier que le LoginScreen est affiché
    expect(find.byType(Scaffold), findsOneWidget);
    expect(
      find.byType(TextField),
      findsWidgets,
    ); // si LoginScreen a des TextFields
  });
}
