![Logo](https://github.com/sanjaysharmajw/flutter_screenshot_blocker/blob/main/screenshots/flutter_screenshot_blocker.png?raw=true)

| ![Pub Publisher](https://img.shields.io/pub/publisher/flutter_screenshot_blocker) | ![Pub Points](https://img.shields.io/pub/points/flutter_screenshot_blocker) | ![Pub Popularity](https://img.shields.io/pub/popularity/flutter_screenshot_blocker) | ![Pub Version](https://img.shields.io/pub/v/flutter_screenshot_blocker) | ![Pub Likes](https://img.shields.io/pub/likes/flutter_screenshot_blocker) |
|---|---|---|---|---|



# Flutter Screenshot Blocker

A powerful Flutter plugin that prevents screenshots or shows black screen when screenshots are taken. This plugin provides **system-level protection** using native platform code.

## 🌟 Features

- ✅ **System-Level Screenshot Blocking** - Uses FLAG_SECURE on Android and secure views on iOS
- 📱 **Black Screen on Screenshot** - When screenshots are attempted, they show black screen
- 📱 **Black Screen on Screen recording** - Screen recordings will show black screen
- 🔍 **Screenshot Detection** - Detect when users attempt to take screenshots
- 🎯 **Widget-Level Protection** - Apply protection to specific parts of your app
- 🔒 **Secure App Wrapper** - Easy-to-use app-wide protection
- 📊 **Event Streaming** - Real-time screenshot attempt notifications
- 🚀 **Cross-Platform** - Works on both Android and iOS
- 💪 **Native Implementation** - Maximum security with platform-specific code

## 🚀 Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
flutter_screenshot_blocker: ^1.0.3
```

Run:

```bash
flutter pub get
```
## 📱 Platform Setup

### 🤖 Android Setup

No additional setup required! The plugin automatically applies `FLAG_SECURE` to prevent screenshots. You can setup it if needed. So you can use the **`manifest `** given below

To block screenshots in your Flutter app, update the **`AndroidManifest.xml`** as shown below: (Optional)

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.flutter_screenshot_blocker_example">

    <!-- (Optional) Permission for detecting screenshots -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />

    <application
        android:label="flutter_screenshot_blocker_example"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">

            <!-- Enable FLAG_SECURE to block screenshots and screen recordings -->
            <meta-data
                android:name="flutter_screenshot_blocker.secure"
                android:value="true" />

            <!-- Flutter theme metadata -->
            <meta-data
                android:name="io.flutter.embedding.android.NormalTheme"
                android:resource="@style/NormalTheme" />

            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>

        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>

```

###  iOS Setup

No additional setup required! The plugin uses secure UITextField technique and screenshot detection. You can setup it if needed. So you can use the **`Info.plist `** given below

To enable screenshot protection and enhance app security on iOS, add the following keys to your **`ios/Runner/Info.plist`** file.

```xml
// ios/Runner/Info.plist additions
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <!-- ... existing keys ... -->

  <!-- Add screenshot protection info -->
  <key>NSPhotoLibraryUsageDescription</key>
  <string>This app needs to detect screenshots for security purposes.</string>

  <key>UIRequiredDeviceCapabilities</key>
  <array>
    <string>armv7</string>
  </array>

  <!-- Prevent screenshots in app switcher -->
  <key>UIApplicationSupportsMultipleScenes</key>
  <false/>

  <key>LSRequiresIPhoneOS</key>
  <true/>

  <!-- Security settings -->
  <key>flutter_screenshot_blocker</key>
  <dict>
    <key>enable_protection</key>
    <true/>
    <key>show_security_warning</key>
    <true/>
  </dict>
</dict>
</plist>

```

## 📖 Usage

### Method 1: Secure App Wrapper (Easiest)

Wrap your entire app with `SecureApp`:

```dart
void main() {
  runApp(
    SecureApp(
      enableScreenshotBlocking: true,
      showSecurityWarning: true,
      child: MyApp(),
    ),
  );
}

```

### Method 2: Widget-Level Protection

Protect specific widgets:

```dart
ScreenshotBlockerWidget(
    blockScreenshots: true,
    detectScreenshots: true,
    onScreenshotDetected: (event) {
      print('Screenshot blocked: ${event.type}');
      // Show your custom message
    },
    child: YourSensitiveWidget(),
  );
```

### Method 3: Manual Control

Control protection manually:

```dart
class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  @override
  void initState() {
    super.initState();
    // Enable protection when page loads
    FlutterScreenshotBlocker.enableScreenshotBlocking();
  }

  @override
  void dispose() {
    // Disable protection when leaving page
    FlutterScreenshotBlocker.disableScreenshotBlocking();
    super.dispose();
  }
}

```

### Screenshot Detection Events

Listen to screenshot attempts:

```dart
StreamSubscription? _screenshotSubscription;

@override
void initState() {
  super.initState();

  _screenshotSubscription = FlutterScreenshotBlocker.onScreenshotDetected
      .listen((ScreenshotEvent event) {
        switch (event.type) {
          case 'screenshot_taken':
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: Text('Screenshot Detected!'),
                content: Text('Screenshots are not allowed in this app.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('OK'),
                  ),
                ],
              ),
            );
            break;
          case 'screenshot_blocked':
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Screenshot blocked for security!'),
                backgroundColor: Colors.red,
              ),
            );
            break;
        }
      });
}

@override
void dispose() {
  _screenshotSubscription?.cancel();
  super.dispose();
}

```

## ⚙️ API Reference

### FlutterScreenshotBlocker Class

| Method | Return Type | Description |
|--------|------------|-------------|
| `enableScreenshotBlocking()` | `Future<bool>` | Enable screenshot blocking |
| `disableScreenshotBlocking()` | `Future<bool>` | Disable screenshot blocking |
| `isScreenshotBlockingEnabled()` | `Future<bool>` | Check if blocking is enabled |
| `enableSecureMode()` | `Future<bool>` | Enable secure mode |
| `disableSecureMode()` | `Future<bool>` | Disable secure mode |
| `setSecureFlag(bool)` | `Future<bool>` | Set secure flag state |
| `enableScreenshotDetection()` | `Future<bool>` | Enable screenshot detection |
| `disableScreenshotDetection()` | `Future<bool>` | Disable screenshot detection |
| `onScreenshotDetected` | `Stream<ScreenshotEvent>` | Stream of screenshot events |

### ScreenshotBlockerWidget Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `child` | `Widget` | required | Widget to protect |
| `blockScreenshots` | `bool` | `true` | Enable screenshot blocking |
| `detectScreenshots` | `bool` | `true` | Enable screenshot detection |
| `onScreenshotDetected` | `Function(ScreenshotEvent)?` | `null` | Screenshot event callback |
| `blockedWidget` | `Widget?` | `null` | Custom widget when blocked |

### SecureApp Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `child` | `Widget` | required | App widget |
| `enableScreenshotBlocking` | `bool` | `true` | Enable protection |
| `showSecurityWarning` | `bool` | `true` | Show security dialog |
| `securityWarningMessage` | `String?` | `null` | Custom warning message |

## 🔒 How It Works

### Android Implementation
- Uses `WindowManager.LayoutParams.FLAG_SECURE` flag
- Prevents screenshots at the system level
- Screenshots show black screen instead of app content
- Detects screenshot attempts via system callbacks

### iOS Implementation
- Uses secure `UITextField` technique to prevent screenshots
- Implements `UIApplicationUserDidTakeScreenshotNotification` for detection
- Creates secure view layers that prevent screen capture
- Screenshots show black/empty screen

## ⚠️ Important Notes

### Security Level
This plugin provides **system-level protection** which means:
- ✅ Screenshots will show black screen
- ✅ Screen recordings will show black screen
- ✅ App switcher will show protected content
- ❌ Cannot prevent physical camera recording of screen
- ❌ Cannot prevent rooted/jailbroken device bypasses

### Platform Differences
- **Android**: Uses FLAG_SECURE, very effective
- **iOS**: Uses secure view techniques, good protection
- **Web**: Not supported (web platform limitations)

## 🧪 Testing

The plugin includes comprehensive tests. Run them with:

```bash
flutter test
```
To test the screenshot blocking:
- Enable protection in the demo app
- Try taking a screenshot
- The screenshot should show a black screen
- Disable protection and try again - normal screenshot

### ⚠️ iOS Simulator Limitation

**Screenshot blocking does NOT work on iOS Simulator.** Always test on a real iOS device.

| Feature | iOS Simulator | Real iOS Device |
|---------|:---:|:---:|
| Screenshot blocking (black screen) | ❌ | ✅ |
| Screen recording overlay (black) | ❌ | ✅ |
| Screenshot detection event | ⚠️ Unreliable | ✅ |
| UI / layout testing | ✅ | ✅ |

**Why Simulator doesn't work:**
- iOS Simulator runs on macOS and uses macOS's display compositor, not the iOS compositor
- The `IOSurface` hardware-level protection flag that makes screenshots black is an iOS-only hardware feature
- The Simulator is just a macOS window — macOS can freely screenshot everything inside it
- `UIScreen.capturedDidChangeNotification` for recording detection also doesn't fire correctly

**To test on a real device:**
```bash
# List connected devices
flutter devices

# Run on a specific device
flutter run -d <device-udid>
```

## 🔧 Troubleshooting

### Screenshots Still Work
- Make sure you called `enableScreenshotBlocking()`
- Check that the method returned `true`
- On iOS, ensure your app is in the foreground
- Try using `SecureApp` wrapper for app-wide protection

### Detection Not Working
- Ensure `enableScreenshotDetection()` was called
- Check that you're listening to the event stream
- On Android, some devices may not support detection

### Performance Issues
- Screenshot blocking has minimal impact
- Detection uses system notifications, very efficient
- Consider disabling detection if not needed

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License.

---

## 🎯 Use Cases

Perfect for:
- 🏦 **Banking Apps** - Protect account numbers and balances
- 🏥 **Medical Apps** - Secure patient information
- 💼 **Business Apps** - Protect confidential documents
- 🔐 **Security Apps** - Prevent sensitive data leakage
- 📱 **Enterprise Apps** - Meet corporate security requirements

## ⭐ Star This Repo

If this plugin helped you, please ⭐ star this repository!