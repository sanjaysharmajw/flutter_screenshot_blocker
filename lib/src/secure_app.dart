import 'package:flutter/material.dart';
import '../flutter_screenshot_blocker.dart';

class SecureApp extends StatefulWidget {
  final Widget child;
  final bool enableScreenshotBlocking;
  final bool showSecurityWarning;
  final String? securityWarningMessage;

  const SecureApp({
    super.key,
    required this.child,
    this.enableScreenshotBlocking = true,
    this.showSecurityWarning = true,
    this.securityWarningMessage,
  });

  @override
  State<SecureApp> createState() => _SecureAppState();
}

class _SecureAppState extends State<SecureApp> {
  bool isSecured = false;

  @override
  void initState() {
    super.initState();
    _initializeSecurity();
  }

  Future<void> _initializeSecurity() async {
    if (widget.enableScreenshotBlocking) {
      final result = await FlutterScreenshotBlocker.enableScreenshotBlocking();
      setState(() {
        isSecured = result;
      });

      if (widget.showSecurityWarning && result) {
        _showSecurityWarning();
      }
    }
  }

  void _showSecurityWarning() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.security, color: Colors.green, size: 48),
            title: const Text('App Secured'),
            content: Text(
              widget.securityWarningMessage ??
                  'This app is now protected. Screenshots and screen recording are disabled for your security.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Understood'),
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
