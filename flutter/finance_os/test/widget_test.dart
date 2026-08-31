import 'package:flutter_test/flutter_test.dart';
import 'package:finance_os/main.dart';

void main() {
  testWidgets('FinanceOS loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const FinanceOSApp());

    expect(find.text('Your financial overview'), findsOneWidget);
    expect(find.text('AVAILABLE BALANCE'), findsOneWidget);
    expect(find.text('Recent transactions'), findsOneWidget);
    expect(find.text('Monthly budgets'), findsOneWidget);
  });
}
