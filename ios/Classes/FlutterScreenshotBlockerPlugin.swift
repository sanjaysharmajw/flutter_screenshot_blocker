import Flutter
import UIKit

public class FlutterScreenshotBlockerPlugin: NSObject, FlutterPlugin {
    private var isScreenshotBlocked       = false
    private var screenshotObserver: NSObjectProtocol?
    private var captureObserver: NSObjectProtocol?
    private var eventSink: FlutterEventSink?
    private var secureField: UITextField?          // stays in window's view hierarchy
    private var originalWindowSuperLayer: CALayer?
    private var savedWindowPosition: CGPoint?
    private var overlayWindow: UIWindow?           // separate window for recording overlay

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "flutter_screenshot_blocker",
            binaryMessenger: registrar.messenger())
        let eventChannel = FlutterEventChannel(
            name: "flutter_screenshot_blocker/events",
            binaryMessenger: registrar.messenger())
        let instance = FlutterScreenshotBlockerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        eventChannel.setStreamHandler(instance)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "enableScreenshotBlocking":    enableScreenshotBlocking(result: result)
        case "disableScreenshotBlocking":   disableScreenshotBlocking(result: result)
        case "isScreenshotBlockingEnabled": result(isScreenshotBlocked)
        case "enableSecureMode":            enableScreenshotBlocking(result: result)
        case "disableSecureMode":           disableScreenshotBlocking(result: result)
        case "setSecureFlag":
            if let args = call.arguments as? [String: Any],
               let secure = args["secure"] as? Bool {
                if secure { enableScreenshotBlocking(result: result) }
                else      { disableScreenshotBlocking(result: result) }
            } else { result(false) }
        case "enableScreenshotDetection":   enableScreenshotDetection(result: result)
        case "disableScreenshotDetection":  disableScreenshotDetection(result: result)
        default: result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Helpers

    private func getKeyWindow() -> UIWindow? {
        if #available(iOS 13.0, *) {
            let scenes = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
            return scenes.flatMap { $0.windows }.first { $0.isKeyWindow }
                ?? scenes.flatMap { $0.windows }.first
        }
        return UIApplication.shared.keyWindow
    }

    private func isBeingCaptured() -> Bool {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first?.screen.isCaptured ?? false
        }
        if #available(iOS 11.0, *) { return UIScreen.main.isCaptured }
        return false
    }

    // MARK: - Screenshot / recording blocking

    private func enableScreenshotBlocking(result: @escaping FlutterResult) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return result(false) }
            if strongSelf.isScreenshotBlocked { return result(true) }
            guard let window = strongSelf.getKeyWindow() else { return result(false) }
            guard let originalSuper = window.layer.superlayer else { return result(false) }

            // ── How the trick works ───────────────────────────────────────────────
            // UITextField with isSecureTextEntry = true causes iOS to mark its
            // CALayer's IOSurface as "protected".  The protection propagates to
            // every descendant layer.  By reparenting window.layer into that subtree
            // we make Flutter's entire output non-capturable by the OS compositor.
            //
            // CRITICAL: the field MUST remain in the UIKit view hierarchy for the
            // duration of protection.  Calling removeFromSuperview() drops the
            // IOSurface "protected" flag and silently breaks screenshot blocking.
            //
            // Coordinate-system note: field is constrained to fill the window exactly,
            // so field.layer's coordinate space == window.layer's coordinate space ==
            // originalSuper's coordinate space (window is always full-screen at origin
            // 0,0).  UIKit layout passes that update field.layer.position or
            // window.layer.position use values that are numerically identical in all
            // three spaces, so no manual conversion is needed.

            let field = UITextField()
            field.isSecureTextEntry        = true
            field.isUserInteractionEnabled = false
            field.backgroundColor          = .clear
            // autoresizingMask keeps field full-screen on rotation without requiring
            // Auto Layout, which avoids a second layout pass later.
            field.translatesAutoresizingMaskIntoConstraints = false
            window.addSubview(field)
            NSLayoutConstraint.activate([
                field.topAnchor.constraint(equalTo: window.topAnchor),
                field.leadingAnchor.constraint(equalTo: window.leadingAnchor),
                field.trailingAnchor.constraint(equalTo: window.trailingAnchor),
                field.bottomAnchor.constraint(equalTo: window.bottomAnchor),
            ])
            // Force UITextField to build its internal layer tree (including the
            // secure sublayer) synchronously before we inspect it.
            window.layoutIfNeeded()

            // Choose the best secure anchor:
            // • iOS ≤ 16 — the protected IOSurface is on sublayers[0] (first)
            // • iOS 17+ / 26 — TextKit 2 rewrite moved the protected sublayer to the
            //   last position; if sublayers is empty, field.layer itself carries the flag
            let sublayers = field.layer.sublayers ?? []
            let secureAnchor: CALayer = sublayers.last ?? field.layer

            strongSelf.originalWindowSuperLayer = originalSuper
            strongSelf.savedWindowPosition      = window.layer.position
            strongSelf.secureField              = field   // keeps field alive & in hierarchy

            // Step 1 ── promote field.layer to be a SIBLING of window.layer.
            // addSublayer first removes field.layer from window.layer (where UIKit put
            // it), so there is no circular reference when we reparent window.layer next.
            originalSuper.addSublayer(field.layer)

            // Step 2 ── reparent window.layer into the protected subtree.
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            secureAnchor.addSublayer(window.layer)
            window.layer.position = strongSelf.savedWindowPosition
                ?? CGPoint(x: window.bounds.midX, y: window.bounds.midY)
            window.layer.bounds   = CGRect(origin: .zero, size: window.bounds.size)
            CATransaction.commit()

            strongSelf.isScreenshotBlocked = true
            strongSelf.setupCaptureObserver()
            result(true)
        }
    }

    private func disableScreenshotBlocking(result: @escaping FlutterResult) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return result(false) }
            guard strongSelf.isScreenshotBlocked else { return result(true) }

            strongSelf.teardownCaptureObserver()

            if let originalSuper = strongSelf.originalWindowSuperLayer,
               let window = strongSelf.getKeyWindow() {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                // Restore window.layer BEFORE removing field.layer — if we removed
                // field first, window.layer would be taken with it and the screen
                // would go blank.
                originalSuper.addSublayer(window.layer)
                window.layer.position = strongSelf.savedWindowPosition
                    ?? CGPoint(x: window.bounds.midX, y: window.bounds.midY)
                window.layer.bounds   = CGRect(origin: .zero, size: window.bounds.size)
                CATransaction.commit()
            }

            // Now it is safe to remove field from both hierarchies.
            strongSelf.secureField?.removeFromSuperview()   // UIKit view hierarchy
            strongSelf.secureField?.layer.removeFromSuperlayer() // CALayer tree
            strongSelf.secureField              = nil
            strongSelf.originalWindowSuperLayer = nil
            strongSelf.savedWindowPosition      = nil
            strongSelf.isScreenshotBlocked      = false
            result(true)
        }
    }

    // MARK: - Screen-recording overlay (separate UIWindow)
    //
    // UIScreen.capturedDidChangeNotification fires when a screen recording or
    // mirror starts / stops, but NOT for one-shot screenshots (the layer trick
    // above handles those).  We use a dedicated UIWindow at a high level so the
    // overlay never touches Flutter's window view or layer hierarchy.

    private func setupCaptureObserver() {
        captureObserver = NotificationCenter.default.addObserver(
            forName: UIScreen.capturedDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in self?.syncRecordingOverlay() }
        syncRecordingOverlay()   // cover the case where recording was already active
    }

    private func teardownCaptureObserver() {
        if let obs = captureObserver {
            NotificationCenter.default.removeObserver(obs)
            captureObserver = nil
        }
        hideOverlayWindow()
    }

    private func syncRecordingOverlay() {
        isBeingCaptured() ? showOverlayWindow() : hideOverlayWindow()
    }

    private func showOverlayWindow() {
        guard overlayWindow == nil else { return }

        let win: UIWindow
        if #available(iOS 13.0, *) {
            let scene = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first { $0.activationState == .foregroundActive }
                ?? UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }.first
            guard let s = scene else { return }
            win = UIWindow(windowScene: s)
        } else {
            win = UIWindow(frame: UIScreen.main.bounds)
        }

        let vc               = UIViewController()
        vc.view.backgroundColor = .black
        win.rootViewController  = vc
        win.windowLevel          = UIWindow.Level.alert + 100
        win.isUserInteractionEnabled = false
        win.isHidden             = false
        overlayWindow            = win
    }

    private func hideOverlayWindow() {
        overlayWindow?.isHidden = true
        overlayWindow = nil
    }

    // MARK: - Screenshot detection

    private func enableScreenshotDetection(result: @escaping FlutterResult) {
        screenshotObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.userDidTakeScreenshotNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in self?.handleScreenshotDetected() }
        result(true)
    }

    private func disableScreenshotDetection(result: @escaping FlutterResult) {
        if let obs = screenshotObserver {
            NotificationCenter.default.removeObserver(obs)
            screenshotObserver = nil
        }
        result(true)
    }

    private func handleScreenshotDetected() {
        eventSink?([
            "type": "screenshot_taken",
            "timestamp": Int64(Date().timeIntervalSince1970 * 1000),
            "metadata": ["message": "Screenshot was taken", "platform": "ios"]
        ] as [String: Any])
    }
}

// MARK: - FlutterStreamHandler

extension FlutterScreenshotBlockerPlugin: FlutterStreamHandler {
    public func onListen(withArguments arguments: Any?,
                         eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
}
