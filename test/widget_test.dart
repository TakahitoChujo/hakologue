import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hakologue/app.dart';

void main() {
  testWidgets('App launches and shows home screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: HakologueApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ハコピー'), findsWidgets);
  });
}
