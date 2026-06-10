import 'package:atlas_code_example/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E', () {
    testWidgets('lists countries and finds Portugal by search', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'portugal');
      await tester.pumpAndSettle();

      expect(find.textContaining('PT · +351'), findsOneWidget);
    });
  });
}
