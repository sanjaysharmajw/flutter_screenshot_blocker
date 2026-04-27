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

Wrap your entire app with `SecureApp` in `main()` — one-line setup that protects every screen automatically. Optionally shows a security warning dialog on first launch.

```dart
void main() {
  runApp(
    SecureApp(
      enableScreenshotBlocking: true,  // block screenshots across the whole app
      showSecurityWarning: true,        // show a security dialog on first launch
      securityWarningMessage: 'This app is protected. Screenshots are disabled.', // optional custom message
      child: MyApp(),
    ),
  );
}
```

| Property | Type | Default | Description |
|---|---|---|---|
| `child` | `Widget` | required | Your root app widget |
| `enableScreenshotBlocking` | `bool` | `true` | Block screenshots app-wide |
| `showSecurityWarning` | `bool` | `true` | Show security dialog on launch |
| `securityWarningMessage` | `String?` | `null` | Custom message in the dialog |

### Method 2: Widget-Level Protection

Wrap only the sensitive part of your UI — not the whole app. `blockScreenshots` blocks capture, `detectScreenshots` fires a callback when a screenshot is attempted, and `child` is the widget you want to protect.

```dart
ScreenshotBlockerWidget(
  blockScreenshots: true,       // makes this widget appear black in screenshots
  detectScreenshots: true,      // listen for screenshot attempts
  onScreenshotDetected: (event) {
    // event.type → 'screenshot_taken' or 'screenshot_blocked'
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Screenshots are not allowed!')),
    );
  },
  child: YourSensitiveWidget(), // e.g. bank balance, OTP, personal info
);
```

| Property | Type | Description |
|---|---|---|
| `child` | `Widget` | The widget to protect |
| `blockScreenshots` | `bool` | Block capture — shows black in screenshots |
| `detectScreenshots` | `bool` | Enable screenshot attempt detection |
| `onScreenshotDetected` | `Function(ScreenshotEvent)?` | Callback when screenshot is attempted |
| `blockedWidget` | `Widget?` | Custom widget shown while protection is active |

### Method 3: Manual Control

Enable blocking in `initState()` when the page opens and disable it in `dispose()` when the page closes.

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

Call `enableScreenshotDetection()` first, then listen to `onScreenshotDetected` stream. Two events are fired — `screenshot_taken` (user took a screenshot) shows a dialog, and `screenshot_blocked` (screenshot was blocked) shows a snackbar. Always cancel the subscription in `dispose()` to avoid memory leaks, and call `disableScreenshotDetection()` to stop native callbacks.

```dart
@override
void initState() {
  super.initState();

  // Step 1: enable native screenshot detection
  FlutterScreenshotBlocker.enableScreenshotDetection();

  // Step 2: listen to events
  _screenshotSubscription = FlutterScreenshotBlocker.onScreenshotDetected
      .listen((ScreenshotEvent event) {
        switch (event.type) {
          case 'screenshot_taken':
            // Fires when user takes a screenshot — show a warning dialog
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
            // Fires when a screenshot attempt was blocked — show a snackbar
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
  // Step 3: always clean up to prevent memory leaks
  FlutterScreenshotBlocker.disableScreenshotDetection();
  _screenshotSubscription?.cancel();
  super.dispose();
}
```

| Event type | When it fires | Recommended action |
|---|---|---|
| `screenshot_taken` | User took a screenshot | Show warning dialog |
| `screenshot_blocked` | Screenshot was blocked by the plugin | Show snackbar / log |

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

If this plugin helped you, please ⭐ star this repository!![Logo](https://github.com/sanjaysharmajw/flutter_screenshot_blocker/blob/main/screenshots/flutter_screenshot_blocker.png?raw=true)

| ![Pub Publisher](https://img.shields.io/pub/publisher/flutter_screenshot_blocker) | ![Pub Points](https://img.shields.io/pub/points/flutter_screenshot_blocker) | ![Pub Popularity](https://img.shields.io/pub/popularity/flutter_screenshot_blocker) | ![Pub Version](https://img.shields.io/pub/v/flutter_screenshot_blocker) | ![Pub Likes](https://img.shields.io/pub/likes/flutter_screenshot_blocker) |
|---|---|---|---|---|



# Flutter Screenshot Blocker

A powerful Flutter plugin that prevents screenshots or shows black screen when screenshots are taken. This plugin provides **system-level protection** using native platform code.

## 🌟 Features

- ✅ **System-Level Screenshot Blocking** - Uses FLAG_SECURE on Android and secure views on iOS
- 📱 **Black Screen on Screenshot** - When screenshots are attempted, they show black screen
- 📱 **Black Screen on Screen Recording** - Screen recordings will show black screen
- 🔍 **Screenshot Detection** - Detect when users attempt to take screenshots
- 🎯 **Widget-Level Protection** - Apply protection to specific parts of your app
- 🔒 **Secure App Wrapper** - Easy-to-use app-wide protection
- 📊 **Event Streaming** - Real-time screenshot attempt notifications
- 🚀 **Cross-Platform** - Works on both Android and iOS
- 💪 **Native Implementation** - Maximum security with platform-specific code

## 📋 Requirements

| Platform | Minimum Version |
|---|---|
| Flutter | 3.0.0+ |
| Dart | 2.17.0+ |
| iOS | 12.0+ |
| Android | API 21 (Android 5.0)+ |

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

No additional setup required! The plugin automatically applies `FLAG_SECURE` to prevent screenshots. You can setup it if needed. So you can use the **`manifest`** given below.

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

### 🍎 iOS Setup

No additional setup required! The plugin uses the secure `UITextField` technique and screenshot detection. You can setup it if needed. So you can use the **`Info.plist`** given below.

To enable screenshot protection and enhance app security on iOS, add the following keys to your **`ios/Runner/Info.plist`** file.

```xml
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
</dict>
</plist>
```

## 📖 Usage

Add the import at the top of your Dart file:

```dart
import 'package:flutter_screenshot_blocker/flutter_screenshot_blocker.dart';
```

---

### Method 1: Secure App Wrapper (Easiest)

Wrap your entire app with `SecureApp` in `main()` — one-line setup that protects every screen automatically. Optionally shows a security warning dialog on first launch.

```dart
void main() {
  runApp(
    SecureApp(
      enableScreenshotBlocking: true,   // block screenshots across the whole app
      showSecurityWarning: true,         // show a security dialog on first launch
      securityWarningMessage: 'This app is protected. Screenshots are disabled.', // optional custom message
      child: MyApp(),
    ),
  );
}
```

| Property | Type | Default | Description |
|---|---|---|---|
| `child` | `Widget` | required | Your root app widget |
| `enableScreenshotBlocking` | `bool` | `true` | Block screenshots app-wide |
| `showSecurityWarning` | `bool` | `true` | Show security dialog on launch |
| `securityWarningMessage` | `String?` | `null` | Custom message in the dialog |

---

### Method 2: Widget-Level Protection

Wrap only the sensitive part of your UI — not the whole app. `blockScreenshots` blocks capture, `detectScreenshots` fires a callback when a screenshot is attempted, and `child` is the widget you want to protect.

```dart
ScreenshotBlockerWidget(
  blockScreenshots: true,       // makes this widget appear black in screenshots
  detectScreenshots: true,      // listen for screenshot attempts
  onScreenshotDetected: (event) {
    // event.type → 'screenshot_taken' or 'screenshot_blocked'
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Screenshots are not allowed!')),
    );
  },
  child: YourSensitiveWidget(), // e.g. bank balance, OTP, personal info
);
```

| Property | Type | Default | Description |
|---|---|---|---|
| `child` | `Widget` | required | The widget to protect |
| `blockScreenshots` | `bool` | `true` | Block capture — shows black in screenshots |
| `detectScreenshots` | `bool` | `true` | Enable screenshot attempt detection |
| `onScreenshotDetected` | `Function(ScreenshotEvent)?` | `null` | Callback when screenshot is attempted |
| `blockedWidget` | `Widget?` | `null` | Custom widget shown while protection is active |

---

### Method 3: Manual Control

Enable blocking in `initState()` when the page opens and disable it in `dispose()` when the page closes.

```dart
class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  StreamSubscription? _screenshotSubscription;

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
    _screenshotSubscription?.cancel();
    super.dispose();
  }
}
```

---

### Screenshot Detection Events

Call `enableScreenshotDetection()` first, then listen to `onScreenshotDetected` stream. Two events are fired — `screenshot_taken` (user took a screenshot) shows a dialog, and `screenshot_blocked` (screenshot was blocked) shows a snackbar. Always cancel the subscription in `dispose()` to avoid memory leaks, and call `disableScreenshotDetection()` to stop native callbacks.

```dart
@override
void initState() {
  super.initState();

  // Step 1: enable native screenshot detection
  FlutterScreenshotBlocker.enableScreenshotDetection();

  // Step 2: listen to events
  _screenshotSubscription = FlutterScreenshotBlocker.onScreenshotDetected
      .listen((ScreenshotEvent event) {
        switch (event.type) {
          case 'screenshot_taken':
            // Fires when user takes a screenshot — show a warning dialog
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
            // Fires when a screenshot attempt was blocked — show a snackbar
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
  // Step 3: always clean up to prevent memory leaks
  FlutterScreenshotBlocker.disableScreenshotDetection();
  _screenshotSubscription?.cancel();
  super.dispose();
}
```

| Event type | When it fires | Recommended action |
|---|---|---|
| `screenshot_taken` | User took a screenshot | Show warning dialog |
| `screenshot_blocked` | Screenshot was blocked by the plugin | Show snackbar / log |

---

### Check & Toggle Protection State

```dart
// Check if blocking is currently active
bool isEnabled = await FlutterScreenshotBlocker.isScreenshotBlockingEnabled();

// Toggle using a single method
await FlutterScreenshotBlocker.setSecureFlag(true);  // enable
await FlutterScreenshotBlocker.setSecureFlag(false); // disable
```

---

### ScreenshotEvent Model

Every event from `onScreenshotDetected` is a `ScreenshotEvent` object with these fields:

| Field | Type | Description |
|---|---|---|
| `type` | `String` | `'screenshot_taken'` or `'screenshot_blocked'` |
| `timestamp` | `DateTime` | When the event occurred |
| `metadata` | `Map<String, dynamic>?` | Extra info — e.g. `platform: 'android'` |

```dart
FlutterScreenshotBlocker.onScreenshotDetected.listen((ScreenshotEvent event) {
  print(event.type);               // 'screenshot_taken'
  print(event.timestamp);          // 2024-01-01 12:00:00.000
  print(event.metadata?['platform']); // 'ios' or 'android'
});
```

## ⚙️ API Reference

### FlutterScreenshotBlocker Class

| Method | Return Type | Description |
|--------|------------|-------------|
| `enableScreenshotBlocking()` | `Future<bool>` | Enable screenshot blocking |
| `disableScreenshotBlocking()` | `Future<bool>` | Disable screenshot blocking |
| `isScreenshotBlockingEnabled()` | `Future<bool>` | Check if blocking is currently enabled |
| `enableSecureMode()` | `Future<bool>` | Alias for `enableScreenshotBlocking()` |
| `disableSecureMode()` | `Future<bool>` | Alias for `disableScreenshotBlocking()` |
| `setSecureFlag(bool)` | `Future<bool>` | Enable or disable blocking with a single call |
| `enableScreenshotDetection()` | `Future<bool>` | Start listening for screenshot attempts |
| `disableScreenshotDetection()` | `Future<bool>` | Stop listening for screenshot attempts |
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
- Uses `WindowManager.LayoutParams.FLAG_SECURE` at the window level
- The OS marks the window as non-capturable — screenshots and recordings show black
- Screenshot detection uses `ContentObserver` watching the media store for new images

### iOS Implementation
- Creates a full-screen `UITextField` with `isSecureTextEntry = true`
- Reparents Flutter's root view layer (`flutterView.layer`) into the UITextField's protected IOSurface subtree
- The OS compositor marks that IOSurface as non-capturable — screenshots show black
- Screen recording detection uses `UIScreen.capturedDidChangeNotification`; when recording is active, a solid black `UIWindow` overlays the app at a high window level
- Screenshot detection uses `UIApplication.userDidTakeScreenshotNotification`

## ⚠️ Important Notes

### Security Level
This plugin provides **system-level protection** which means:
- ✅ Screenshots will show black screen
- ✅ Screen recordings will show black screen
- ✅ App switcher will show protected content
- ❌ Cannot prevent physical camera recording of screen
- ❌ Cannot prevent rooted/jailbroken device bypasses

### Platform Differences
- **Android**: Uses `FLAG_SECURE` — very effective across all Android versions
- **iOS**: Uses secure `UITextField` layer technique — requires a real device (not Simulator)
- **Web**: Not supported (web platform limitations) - Next Feature(Coming Soon)


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
- The `IOSurface` hardware-level protection flag is an iOS-only hardware feature — macOS does not emulate it
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

### Screenshots Still Visible
- Make sure `enableScreenshotBlocking()` was called and returned `true`
- On iOS, always test on a **real device** — Simulator will never show black
- On iOS, ensure the app is in the foreground when blocking is enabled
- Try `SecureApp` wrapper for guaranteed app-wide protection

### Detection Not Working
- Ensure `enableScreenshotDetection()` was called before listening to the stream
- Check you are subscribed to `onScreenshotDetected` stream
- On Android, some OEM devices may delay or suppress screenshot notifications
- On iOS Simulator, detection events are unreliable — use a real device

### Screen Recording Not Showing Black (iOS)
- Screen recording overlay relies on `UIScreen.capturedDidChangeNotification`
- This only fires on real devices — not on Simulator
- Ensure `enableScreenshotBlocking()` was called (the capture observer is set up inside it)

### Performance Issues
- Screenshot blocking has minimal performance impact
- Detection uses system notifications — very efficient
- Consider disabling detection when not needed to reduce overhead

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
