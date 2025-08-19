import 'package:flutter/material.dart';
import 'package:flutter_screenshot_blocker/flutter_screenshot_blocker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Screenshot Blocker Demo',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: SecureApp(
        enableScreenshotBlocking: true,
        showSecurityWarning: true,
        child: const DemoScreen(),
      ),
    );
  }
}

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  bool _isProtectionEnabled = true;
  int _screenshotAttempts = 0;
  String _lastEvent = 'No events detected';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screenshot Blocker Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(
              _isProtectionEnabled ? Icons.security : Icons.security_outlined,
            ),
            onPressed: _toggleProtection,
          ),
        ],
      ),
      body: ScreenshotBlockerWidget(
        blockScreenshots: _isProtectionEnabled,
        detectScreenshots: true,
        onScreenshotDetected: (event) {
          setState(() {
            _screenshotAttempts++;
            _lastEvent = '${event.type} at ${event.timestamp}';
          });

          // Show custom feedback
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Screenshot blocked! Event: ${event.type}'),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Dismiss',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Card
              Card(
                color: _isProtectionEnabled
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        _isProtectionEnabled
                            ? Icons.shield
                            : Icons.shield_outlined,
                        color: _isProtectionEnabled ? Colors.green : Colors.red,
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isProtectionEnabled
                                  ? 'Protected'
                                  : 'Unprotected',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(
                                    color: _isProtectionEnabled
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              _isProtectionEnabled
                                  ? 'Screenshots will show black screen'
                                  : 'Screenshots are allowed',
                              style: TextStyle(
                                color: _isProtectionEnabled
                                    ? Colors.green.shade600
                                    : Colors.red.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isProtectionEnabled,
                        onChanged: (value) => _toggleProtection(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Statistics Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Security Statistics',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Screenshot Attempts:'),
                          Text(
                            '$_screenshotAttempts',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Last Event: $_lastEvent',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Sensitive Content Card
              Expanded(
                child: Card(
                  color: Colors.amber.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.warning_amber,
                              color: Colors.orange.shade700,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Sensitive Information',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: Colors.orange.shade700,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          '🔐 Banking Details:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text('Account Number: 1234 5678 9012 3456'),
                        const Text('Routing Number: 987654321'),
                        const Text('PIN: 9876'),
                        const SizedBox(height: 16),

                        const Text(
                          '💳 Credit Card:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text('Card Number: 4532 1234 5678 9012'),
                        const Text('CVV: 123'),
                        const Text('Expiry: 12/28'),
                        const SizedBox(height: 16),

                        const Text(
                          '📊 Account Balance:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '\$125,430.50',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),

                        const Spacer(),

                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade300),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue.shade700,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Try taking a screenshot now!\n'
                                  'With protection ON: Black screen\n'
                                  'With protection OFF: Normal screenshot',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Control Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _toggleProtection,
                      icon: Icon(
                        _isProtectionEnabled
                            ? Icons.shield_outlined
                            : Icons.shield,
                      ),
                      label: Text(
                        _isProtectionEnabled
                            ? 'Disable Protection'
                            : 'Enable Protection',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isProtectionEnabled
                            ? Colors.red
                            : Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _resetStats,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset Stats'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleProtection() async {
    if (_isProtectionEnabled) {
      await FlutterScreenshotBlocker.disableScreenshotBlocking();
    } else {
      await FlutterScreenshotBlocker.enableScreenshotBlocking();
    }

    setState(() {
      _isProtectionEnabled = !_isProtectionEnabled;
    });

   if(mounted) {
     ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isProtectionEnabled
              ? 'Screenshot protection enabled - screenshots will be black'
              : 'Screenshot protection disabled - screenshots allowed',
        ),
        backgroundColor: _isProtectionEnabled ? Colors.green : Colors.orange,
      ),
    );
   }
  }

  void _resetStats() {
    setState(() {
      _screenshotAttempts = 0;
      _lastEvent = 'No events detected';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Statistics reset'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
