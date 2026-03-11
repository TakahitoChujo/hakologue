import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hakologue/widgets/room_filter_chips.dart';

void main() {
  group('RoomFilterChips', () {
    String? selectedRoom;
    String? lastCallback;

    setUp(() {
      selectedRoom = null;
      lastCallback = null;
    });

    Widget buildWidget() {
      return MaterialApp(
        home: Scaffold(
          body: RoomFilterChips(
            selectedRoom: selectedRoom,
            onSelected: (room) => lastCallback = room,
          ),
        ),
      );
    }

    testWidgets('shows all filter chip', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('全て'), findsOneWidget);
    });

    testWidgets('shows all room chips', (tester) async {
      await tester.pumpWidget(buildWidget());

      expect(find.text('リビング'), findsOneWidget);
      expect(find.text('キッチン'), findsOneWidget);
      expect(find.text('寝室'), findsOneWidget);
    });

    testWidgets('tapping a room chip triggers callback', (tester) async {
      await tester.pumpWidget(buildWidget());

      await tester.tap(find.text('キッチン'));
      expect(lastCallback, 'キッチン');
    });

    testWidgets('tapping all chip triggers null callback', (tester) async {
      selectedRoom = 'キッチン';
      await tester.pumpWidget(buildWidget());

      await tester.tap(find.text('全て'));
      expect(lastCallback, isNull);
    });
  });
}
