import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nhatro_management/features/onboarding/presentation/views/welcome_view.dart';

void main() {
  testWidgets('WelcomeView hiển thị thương hiệu và nút bắt đầu quản lý', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: WelcomeView(),
    ));

    expect(find.textContaining('LOZIDO'), findsWidgets);
    expect(find.text('Bắt đầu quản lý'), findsOneWidget);
  });
}
