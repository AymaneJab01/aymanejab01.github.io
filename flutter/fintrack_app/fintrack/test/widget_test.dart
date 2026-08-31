import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App title renders', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: Text('FinTrack'))),
      ),
    );
    expect(find.text('FinTrack'), findsOneWidget);
  });
}
