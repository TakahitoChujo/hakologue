import 'package:flutter_test/flutter_test.dart';
import 'package:hakologue/data/room_presets.dart';

void main() {
  group('RoomPresets', () {
    test('has 8 predefined rooms', () {
      expect(RoomPresets.rooms.length, 8);
    });

    test('contains expected rooms', () {
      expect(RoomPresets.rooms, contains('リビング'));
      expect(RoomPresets.rooms, contains('キッチン'));
      expect(RoomPresets.rooms, contains('寝室'));
      expect(RoomPresets.rooms, contains('書斎'));
      expect(RoomPresets.rooms, contains('子供部屋'));
      expect(RoomPresets.rooms, contains('洗面所'));
      expect(RoomPresets.rooms, contains('玄関'));
      expect(RoomPresets.rooms, contains('その他'));
    });

    test('every room has an icon', () {
      for (final room in RoomPresets.rooms) {
        expect(RoomPresets.roomIcons.containsKey(room), true,
            reason: '$room should have an icon');
        expect(RoomPresets.roomIcons[room]!.isNotEmpty, true);
      }
    });

    test('roomIcons has no extra keys', () {
      for (final key in RoomPresets.roomIcons.keys) {
        expect(RoomPresets.rooms.contains(key), true,
            reason: 'Icon key "$key" should be in rooms list');
      }
    });
  });
}
