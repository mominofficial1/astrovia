import 'package:flutter_test/flutter_test.dart';
import 'package:astrovia/main.dart';
import 'package:astrovia/screens/screen_01_cinematic_entry.dart';

void main() {
  testWidgets('Astrovia smoke test renders Cinematic Entry', (WidgetTester tester) async {
    await tester.pumpWidget(const AstroviaApp());
    expect(find.byType(Screen01CinematicEntry), findsOneWidget);
  });
}
