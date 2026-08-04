import 'package:booking/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Booking app builds a MaterialApp', (WidgetTester tester) async {
    await tester.pumpWidget(const Booking(
      opno: 'test-opno',
      token: 'test-token',
      isStandalone: true,
    ));

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
