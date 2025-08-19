import 'dart:async';

import 'package:flutter/material.dart';
import '../flutter_screenshot_blocker.dart';

class ScreenshotBlockerWidget extends StatefulWidget {
  final Widget child;
  final bool blockScreenshots;
  final bool detectScreenshots;
  final void Function(ScreenshotEvent)? onScreenshotDetected;
  final Widget? blockedWidget;

  const ScreenshotBlockerWidget({
    Key? key,
    required this.child,
    this.blockScreenshots = true,
    this.detectScreenshots = true,
    this.onScreenshotDetected,
    this.blockedWidget,
  }) : super(key: key);

  @override
  State<ScreenshotBlockerWidget> createState() =>
      _ScreenshotBlockerWidgetState();
}

class _ScreenshotBlockerWidgetState extends State<ScreenshotBlockerWidget>
    with WidgetsBindingObserver {
  bool _isProtectionEnabled = false;
  StreamSubscription? _screenshotSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeProtection();
    _setupScreenshotDetection();
  }

  @override
  void dispose() {
    _cleanupProtection();
    _screenshotSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _initializeProtection() async {
    if (widget.blockScreenshots) {
      final result = await FlutterScreenshotBlocker.enableSecureMode();
      setState(() {
        _isProtectionEnabled = result;
      });
    }
  }

  Future<void> _cleanupProtection() async {
    if (_isProtectionEnabled) {
      await FlutterScreenshotBlocker.disableSecureMode();
    }
  }

  void _setupScreenshotDetection() {
    if (widget.detectScreenshots) {
      FlutterScreenshotBlocker.enableScreenshotDetection();

      _screenshotSubscription = FlutterScreenshotBlocker.onScreenshotDetected
          .listen((event) {
            widget.onScreenshotDetected?.call(event);

            // Show default feedback if no custom handler
            if (widget.onScreenshotDetected == null) {
              _showScreenshotBlockedSnackbar();
            }
          });
    }
  }

  void _showScreenshotBlockedSnackbar() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Screenshots are not allowed in this app'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Re-enable protection when app resumes
    if (state == AppLifecycleState.resumed && widget.blockScreenshots) {
      _initializeProtection();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
