import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hakologue/widgets/qr_display.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  group('QrDisplay', () {
    testWidgets('displays QR code and box name', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QrDisplay(
              boxId: 'test-box-id',
              boxName: 'テスト箱',
            ),
          ),
        ),
      );

      expect(find.text('テスト箱'), findsOneWidget);
      expect(find.byType(QrImageView), findsOneWidget);
    });

    testWidgets('renders QrImageView widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: QrDisplay(
              boxId: 'abc-123',
              boxName: 'テスト',
            ),
          ),
        ),
      );

      expect(find.byType(QrImageView), findsOneWidget);
      expect(find.text('テスト'), findsOneWidget);
    });
  });
}
