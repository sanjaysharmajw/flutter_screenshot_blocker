import Flutter
import UIKit

public class FlutterScreenshotBlockerPlugin: NSObject, FlutterPlugin {
    private var isScreenshotBlocked    = false
    private var screenshotObserver: NSObjectProtocol?
    private var captureObserver: NSObjectProtocol?
    private var eventSink: FlutterEventSink?
    private var secureField: UITextField?
    private var overlayWindow: UIWindow?

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
    //
    // Mechanism: A full-screen UITextField (isSecureTextEntry = true) is added to
    // the window, then Flutter's root view layer (flutterView.layer) is reparented
    // inside field.layer.  The IOSurface "protected" flag on field.layer propagates
    // to every descendant, so Flutter's entire render tree appears as black in any
    // screenshot or screen-recording capture.
    //
    // Key design decision: window.layer is NEVER moved.  Previous versions moved
    // window.layer out of the screen layer, which violated UIKit's core invariant
    // that window.layer must be a direct child of the screen layer.  UIKit
    // internally retains layers during layout and app-lifecycle callbacks; touching
    // window.layer's parent caused EXC_BAD_ACCESS in objc_retain / objc_msgSend.
    //
    // By keeping window.layer in place and only reparenting flutterView.layer
    // (one level lower), UIKit never sees a violated invariant and the crash
    // disappears.
    //
    // Coordinate spaces: field is constrained to fill window exactly, so
    // field.layer's coordinate space == window.layer's coordinate space.
    // UIKit layout will continue updating flutterView.layer.position/bounds with
    // numerically correct values even after the reparent.
    //
    // The UITextField must remain in the UIKit view hierarchy for the full duration
    // of protection; calling removeFromSuperview() silently revokes the IOSurface
    // flag.

    private func enableScreenshotBlocking(result: @escaping FlutterResult) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return result(false) }
            if strongSelf.isScreenshotBlocked { return result(true) }
            guard let window = strongSelf.getKeyWindow() else { return result(false) }
            guard let flutterView = window.rootViewController?.view else { return result(false) }

            let field = UITextField()
            field.isSecureTextEntry        = true
            field.isUserInteractionEnabled = false
            field.backgroundColor          = .clear
            field.translatesAutoresizingMaskIntoConstraints = false
            window.addSubview(field)
            NSLayoutConstraint.activate([
                field.topAnchor.constraint(equalTo: window.topAnchor),
                field.leadingAnchor.constraint(equalTo: window.leadingAnchor),
                field.trailingAnchor.constraint(equalTo: window.trailingAnchor),
                field.bottomAnchor.constraint(equalTo: window.bottomAnchor),
            ])
            // Force UITextField to build its internal sublayer tree synchronously.
            window.setNeedsLayout()
            window.layoutIfNeeded()

            // iOS ≤ 16:  protected IOSurface is at sublayers[0] (first)
            // iOS 17–26: UITextField redesign moved the secure layer to sublayers.last.
            //            The first sublayer is now a decoration/glass-effect layer and
            //            does NOT carry the IOSurface protection flag.
            // SAFE: field.layer is never moved, so all sublayer references stay valid.
            let sublayers = field.layer.sublayers ?? []
            let secureAnchor: CALayer
            if #available(iOS 17.0, *) {
                secureAnchor = sublayers.last ?? field.layer
            } else {
                secureAnchor = sublayers.first ?? field.layer
            }

            // Before: window.layer → [flutterView.layer, field.layer]
            // After:  window.layer → [field.layer → secureAnchor(protected)
            //                                           └─ flutterView.layer → Flutter]
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            secureAnchor.addSublayer(flutterView.layer)
            flutterView.layer.position = CGPoint(x: flutterView.bounds.midX,
                                                 y: flutterView.bounds.midY)
            flutterView.layer.bounds   = flutterView.bounds
            CATransaction.commit()

            strongSelf.secureField         = field
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

            if let window = strongSelf.getKeyWindow(),
               let flutterView = window.rootViewController?.view {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                // Restore flutterView.layer as a direct sublayer of window.layer.
                window.layer.insertSublayer(flutterView.layer, at: 0)
                flutterView.layer.position = CGPoint(x: flutterView.bounds.midX,
                                                     y: flutterView.bounds.midY)
                flutterView.layer.bounds   = flutterView.bounds
                CATransaction.commit()
            }

            // removeFromSuperview also detaches field.layer from window.layer.
            strongSelf.secureField?.removeFromSuperview()
            strongSelf.secureField         = nil
            strongSelf.isScreenshotBlocked = false
            result(true)
        }
    }

    // MARK: - Screen-recording overlay (separate UIWindow)
    //
    // UIScreen.capturedDidChangeNotification fires when screen recording starts/stops.
    // We show a solid black window at a high level so the recording sees black.
    // This window never touches Flutter's window or layer hierarchy.

    private func setupCaptureObserver() {
        captureObserver = NotificationCenter.default.addObserver(
            forName: UIScreen.capturedDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in self?.syncRecordingOverlay() }
        syncRecordingOverlay()
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

        let vc                   = UIViewController()
        vc.view.backgroundColor  = .black
        win.rootViewController   = vc
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
