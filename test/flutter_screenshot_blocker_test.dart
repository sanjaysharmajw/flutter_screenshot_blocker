import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenshot_blocker/flutter_screenshot_blocker.dart';
import 'package:flutter/services.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_screenshot_blocker');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          switch (methodCall.method) {
            case 'enableScreenshotBlocking':
              return true;
            case 'disableScreenshotBlocking':
              return true;
            case 'isScreenshotBlockingEnabled':
              return true;
            case 'enableSecureMode':
              return true;
            case 'disableSecureMode':
              return true;
            case 'setSecureFlag':
              return true;
            case 'enableScreenshotDetection':
              return true;
            case 'disableScreenshotDetection':
              return true;
            default:
              return null;
          }
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('FlutterScreenshotBlocker', () {
    test('enableScreenshotBlocking returns true', () async {
      final result = await FlutterScreenshotBlocker.enableScreenshotBlocking();
      expect(result, true);
    });

    test('disableScreenshotBlocking returns true', () async {
      final result = await FlutterScreenshotBlocker.disableScreenshotBlocking();
      expect(result, true);
    });

    test('isScreenshotBlockingEnabled returns true', () async {
      final result =
          await FlutterScreenshotBlocker.isScreenshotBlockingEnabled();
      expect(result, true);
    });

    test('enableSecureMode returns true', () async {
      final result = await FlutterScreenshotBlocker.enableSecureMode();
      expect(result, true);
    });

    test('disableSecureMode returns true', () async {
      final result = await FlutterScreenshotBlocker.disableSecureMode();
      expect(result, true);
    });

    test('setSecureFlag returns true', () async {
      final result = await FlutterScreenshotBlocker.setSecureFlag(true);
      expect(result, true);
    });

    test('enableScreenshotDetection returns true', () async {
      final result = await FlutterScreenshotBlocker.enableScreenshotDetection();
      expect(result, true);
    });

    test('disableScreenshotDetection returns true', () async {
      final result =
          await FlutterScreenshotBlocker.disableScreenshotDetection();
      expect(result, true);
    });
  });

  group('ScreenshotEvent', () {
    test('creates ScreenshotEvent from map', () {
      final map = {
        'type': 'screenshot_taken',
        'timestamp': 1634567890000,
        'metadata': {'platform': 'test'},
      };

      final event = ScreenshotEvent.fromMap(map);

      expect(event.type, 'screenshot_taken');
      expect(
        event.timestamp,
        DateTime.fromMillisecondsSinceEpoch(1634567890000),
      );
      expect(event.metadata?['platform'], 'test');
    });

    test('toString returns correct format', () {
      final event = ScreenshotEvent(
        type: 'test',
        timestamp: DateTime.now(),
        metadata: {'key': 'value'},
      );

      expect(event.toString(), contains('ScreenshotEvent'));
      expect(event.toString(), contains('test'));
    });
  });
}
