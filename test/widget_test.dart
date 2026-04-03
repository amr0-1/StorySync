import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mtrack/main.dart';

void main() {
  testWidgets('App loads and displays Library tab', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: MTrackApp()));

    // Wait for the app to settle
    await tester.pumpAndSettle();

    // Verify that the Library tab is displayed
    expect(find.text('Library'), findsWidgets);
    expect(find.text('Search'), findsWidgets);
  });
}
