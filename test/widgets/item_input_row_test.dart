import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hakologue/widgets/item_input_row.dart';

void main() {
  group('ItemInputRow', () {
    String? addedName;
    int? addedQuantity;

    setUp(() {
      addedName = null;
      addedQuantity = null;
    });

    Widget buildWidget() {
      return MaterialApp(
        home: Scaffold(
          body: ItemInputRow(
            onAdd: (name, quantity) {
              addedName = name;
              addedQuantity = quantity;
            },
          ),
        ),
      );
    }

    testWidgets('has name and quantity input fields', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.byType(IconButton), findsOneWidget);
    });

    testWidgets('adds item with name and default quantity', (tester) async {
      await tester.pumpWidget(buildWidget());

      await tester.enterText(
          find.byType(TextField).first, 'マグカップ');
      await tester.tap(find.byType(IconButton));

      expect(addedName, 'マグカップ');
      expect(addedQuantity, 1);
    });

    testWidgets('adds item with custom quantity', (tester) async {
      await tester.pumpWidget(buildWidget());

      await tester.enterText(
          find.byType(TextField).first, '皿');
      await tester.enterText(
          find.byType(TextField).last, '5');
      await tester.tap(find.byType(IconButton));

      expect(addedName, '皿');
      expect(addedQuantity, 5);
    });

    testWidgets('does not add with empty name', (tester) async {
      await tester.pumpWidget(buildWidget());

      await tester.tap(find.byType(IconButton));
      expect(addedName, isNull);
    });

    testWidgets('trims whitespace from name', (tester) async {
      await tester.pumpWidget(buildWidget());

      await tester.enterText(
          find.byType(TextField).first, '  テスト  ');
      await tester.tap(find.byType(IconButton));

      expect(addedName, 'テスト');
    });

    testWidgets('negative quantity becomes 1', (tester) async {
      await tester.pumpWidget(buildWidget());

      await tester.enterText(
          find.byType(TextField).first, 'テスト');
      await tester.enterText(
          find.byType(TextField).last, '-5');
      await tester.tap(find.byType(IconButton));

      expect(addedQuantity, 1);
    });

    testWidgets('non-numeric quantity defaults to 1', (tester) async {
      await tester.pumpWidget(buildWidget());

      await tester.enterText(
          find.byType(TextField).first, 'テスト');
      await tester.enterText(
          find.byType(TextField).last, 'abc');
      await tester.tap(find.byType(IconButton));

      expect(addedQuantity, 1);
    });

    testWidgets('clears input after adding', (tester) async {
      await tester.pumpWidget(buildWidget());

      final nameField = find.byType(TextField).first;
      await tester.enterText(nameField, 'テスト');
      await tester.tap(find.byType(IconButton));
      await tester.pump();

      final nameController = tester
          .widget<TextField>(nameField)
          .controller;
      expect(nameController?.text, '');
    });
  });
}
