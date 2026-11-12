import 'package:flutter_test/flutter_test.dart';
import 'package:safefid/main.dart';

void main() {
  testWidgets('SafeFiD app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const SafeFiDApp());

    expect(find.byType(SafeFiDApp), findsOneWidget);
  });
}
