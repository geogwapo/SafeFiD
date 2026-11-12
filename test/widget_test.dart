import 'package:flutter_test/flutter_test.dart';
import 'package:hello_flutter/main.dart';

void main() {
  testWidgets('SafeFiD app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const SafeFiDApp());

    expect(find.byType(SafeFiDApp), findsOneWidget);
  });
}
