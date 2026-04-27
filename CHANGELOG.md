## 1.0.1

* Initial release — Flutter plugin that prevents screenshots or shows black screen when screenshots are taken using system-level protection.

## 1.0.2

* Updated README with usage examples and platform setup instructions.

## 1.0.3

* **iOS — Fixed EXC_BAD_ACCESS crashes** caused by moving `window.layer` out of the screen layer hierarchy, which violated UIKit's internal invariants and caused `objc_msgSend` / `objc_retain` faults.
* **iOS — Rewrote screenshot blocking mechanism**: instead of reparenting `window.layer`, only `flutterView.layer` (Flutter's root view layer) is reparented into the UITextField's protected IOSurface subtree. `window.layer` now stays untouched.
* **iOS — Fixed sublayer index selection**: uses `sublayers.last` on iOS 17+ / iOS 26 (UITextField redesign moved the protected IOSurface layer to the last sublayer position) and `sublayers.first` on iOS ≤ 16.
* **iOS — Screen recording overlay**: shows a solid black `UIWindow` at a high window level when screen recording is active, without touching Flutter's window or layer hierarchy.
* **iOS — Fixed Dart type error**: nested `metadata` map from the platform channel now correctly cast with `.cast<String, dynamic>()`.
* **iOS — Swift version bumped** to 5.3 in podspec for compatibility.
* **Docs — Added iOS Simulator limitation** section to README: screenshot blocking requires a real iOS device; the IOSurface hardware protection flag is not emulated in the Simulator.
