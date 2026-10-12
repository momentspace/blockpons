import 'package:blockpons/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app opens the puzzle view and shows a retry action', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const BlockponsApp());
    expect(find.text('BLOCKPONS'), findsOneWidget);
    expect(find.text('SCORE'), findsOneWidget);
    expect(find.text('BEST'), findsOneWidget);
    expect(find.text('リトライ'), findsOneWidget);
  });
}
