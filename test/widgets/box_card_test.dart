import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hakologue/widgets/box_card.dart';
import 'package:hakologue/models/moving_box.dart';
import 'package:hakologue/models/item.dart';

void main() {
  group('BoxCard', () {
    late MovingBox testBox;
    late List<Item> testItems;
    bool tapped = false;

    setUp(() {
      tapped = false;
      testBox = MovingBox(
        id: 'b1',
        projectId: 'p1',
        name: 'キッチン食器',
        room: 'キッチン',
        createdAt: DateTime.now(),
      );
      testItems = [
        Item(id: 'i1', boxId: 'b1', name: 'マグカップ'),
        Item(id: 'i2', boxId: 'b1', name: '皿'),
        Item(id: 'i3', boxId: 'b1', name: '箸'),
      ];
    });

    Widget buildWidget() {
      return MaterialApp(
        home: Scaffold(
          body: BoxCard(
            box: testBox,
            items: testItems,
            onTap: () => tapped = true,
          ),
        ),
      );
    }

    testWidgets('displays box name and room', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('キッチン食器: キッチン'), findsOneWidget);
    });

    testWidgets('displays item names (up to 3)', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('マグカップ, 皿, 箸'), findsOneWidget);
    });

    testWidgets('displays extra count for 4+ items', (tester) async {
      testItems.add(Item(id: 'i4', boxId: 'b1', name: 'フォーク'));
      await tester.pumpWidget(buildWidget());

      expect(find.text('マグカップ, 皿, 箸... 他1件'), findsOneWidget);
    });

    testWidgets('shows unopened status', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('未開封'), findsOneWidget);
    });

    testWidgets('shows opened status', (tester) async {
      testBox.isOpened = true;
      await tester.pumpWidget(buildWidget());

      expect(find.text('開封済み'), findsOneWidget);
    });

    testWidgets('handles empty items', (tester) async {
      testItems = [];
      await tester.pumpWidget(buildWidget());

      expect(find.text('キッチン食器: キッチン'), findsOneWidget);
    });

    testWidgets('responds to tap', (tester) async {
      await tester.pumpWidget(buildWidget());
      await tester.tap(find.byType(BoxCard));

      expect(tapped, true);
    });
  });
}
