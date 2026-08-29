import 'package:flutter_test/flutter_test.dart';

import 'package:expense_splitter/main.dart';

void main() {
  testWidgets('Expense Splitter app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const ExpenseSplitterApp());

    expect(find.text('Expense Splitter'), findsOneWidget);
  });
}
