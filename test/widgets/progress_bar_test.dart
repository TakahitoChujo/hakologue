import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hakologue/widgets/progress_bar.dart';

void main() {
  group('OpeningProgressBar', () {
    Widget buildWidget({required int opened, required int total}) {
      return MaterialApp(
        home: Scaffold(
          body: OpeningProgressBar(opened: opened, total: total),
        ),
      );
    }

    testWidgets('displays correct counts', (tester) async {
      await tester.pumpWidget(buildWidget(opened: 5, total: 10));

      expect(find.text('5 / 10 箱'), findsOneWidget);
      expect(find.text('開封済み: 5 / 未開封: 5'), findsOneWidget);
      expect(find.text('開封進捗'), findsOneWidget);
    });

    testWidgets('displays zero state', (tester) async {
      await tester.pumpWidget(buildWidget(opened: 0, total: 0));

      expect(find.text('0 / 0 箱'), findsOneWidget);
      expect(find.text('開封済み: 0 / 未開封: 0'), findsOneWidget);
    });

    testWidgets('displays all opened state', (tester) async {
      await tester.pumpWidget(buildWidget(opened: 15, total: 15));

      expect(find.text('15 / 15 箱'), findsOneWidget);
      expect(find.text('開封済み: 15 / 未開封: 0'), findsOneWidget);
    });

    testWidgets('contains LinearProgressIndicator', (tester) async {
      await tester.pumpWidget(buildWidget(opened: 3, total: 10));

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });
}
