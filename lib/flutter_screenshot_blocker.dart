library flutter_screenshot_blocker;

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

export 'src/screenshot_blocker_widget.dart';
export 'src/secure_app.dart';

class FlutterScreenshotBlocker {
  static const MethodChannel _channel = MethodChannel(
    'flutter_screenshot_blocker',
  );

  /// Enable screenshot blocking for the entire app
  static Future<bool> enableScreenshotBlocking() async {
    try {
      final result = await _channel.invokeMethod('enableScreenshotBlocking');
      return result == true;
    } catch (e) {
      debugPrint('Error enabling screenshot blocking: $e');
      return false;
    }
  }

  /// Disable screenshot blocking for the entire app
  static Future<bool> disableScreenshotBlocking() async {
    try {
      final result = await _channel.invokeMethod('disableScreenshotBlocking');
      return result == true;
    } catch (e) {
      debugPrint('Error disabling screenshot blocking: $e');
      return false;
    }
  }

  /// Check if screenshot blocking is currently enabled
  static Future<bool> isScreenshotBlockingEnabled() async {
    try {
      final result = await _channel.invokeMethod('isScreenshotBlockingEnabled');
      return result == true;
    } catch (e) {
      debugPrint('Error checking screenshot blocking status: $e');
      return false;
    }
  }

  /// Enable secure mode (prevents screenshots and makes app secure)
  static Future<bool> enableSecureMode() async {
    try {
      final result = await _channel.invokeMethod('enableSecureMode');
      return result == true;
    } catch (e) {
      debugPrint('Error enabling secure mode: $e');
      return false;
    }
  }

  /// Disable secure mode
  static Future<bool> disableSecureMode() async {
    try {
      final result = await _channel.invokeMethod('disableSecureMode');
      return result == true;
    } catch (e) {
      debugPrint('Error disabling secure mode: $e');
      return false;
    }
  }

  /// Set window flags to secure (Android) / prevent capture (iOS)
  static Future<bool> setSecureFlag(bool secure) async {
    try {
      final result = await _channel.invokeMethod('setSecureFlag', {
        'secure': secure,
      });
      return result == true;
    } catch (e) {
      debugPrint('Error setting secure flag: $e');
      return false;
    }
  }

  /// Enable screenshot detection (will trigger callback when screenshot is attempted)
  static Future<bool> enableScreenshotDetection() async {
    try {
      final result = await _channel.invokeMethod('enableScreenshotDetection');
      return result == true;
    } catch (e) {
      debugPrint('Error enabling screenshot detection: $e');
      return false;
    }
  }

  /// Disable screenshot detection
  static Future<bool> disableScreenshotDetection() async {
    try {
      final result = await _channel.invokeMethod('disableScreenshotDetection');
      return result == true;
    } catch (e) {
      debugPrint('Error disabling screenshot detection: $e');
      return false;
    }
  }

  /// Stream of screenshot detection events
  static Stream<ScreenshotEvent> get onScreenshotDetected {
    return _eventChannel.receiveBroadcastStream().map((event) {
      return ScreenshotEvent.fromMap(Map<String, dynamic>.from(event));
    });
  }

  static const EventChannel _eventChannel = EventChannel(
    'flutter_screenshot_blocker/events',
  );
}

class ScreenshotEvent {
  final String type;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  ScreenshotEvent({required this.type, required this.timestamp, this.metadata});

  factory ScreenshotEvent.fromMap(Map<String, dynamic> map) {
    return ScreenshotEvent(
      type: map['type'] ?? 'unknown',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      metadata: map['metadata'],
    );
  }

  @override
  String toString() {
    return 'ScreenshotEvent(type: $type, timestamp: $timestamp, metadata: $metadata)';
  }
}
