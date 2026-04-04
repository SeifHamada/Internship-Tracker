import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:internshiptracker/main.dart';

void main() {
  testWidgets('App shows applications screen', (WidgetTester tester) async {
    await tester.pumpWidget(const InternshipTrackerApp());
    expect(find.text('Applications'), findsOneWidget);
    expect(find.text('Search applications'), findsOneWidget);
  });
}
