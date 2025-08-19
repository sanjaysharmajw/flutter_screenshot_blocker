import Flutter
import UIKit

public class FlutterScreenshotBlockerPlugin: NSObject, FlutterPlugin {
  private var isScreenshotBlocked = false
  private var screenshotObserver: NSObjectProtocol?
  private var eventSink: FlutterEventSink?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_screenshot_blocker",
                                       binaryMessenger: registrar.messenger())
    let eventChannel = FlutterEventChannel(name: "flutter_screenshot_blocker/events",
                                           binaryMessenger: registrar.messenger())

    let instance = FlutterScreenshotBlockerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    eventChannel.setStreamHandler(instance)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "enableScreenshotBlocking":
      enableScreenshotBlocking(result: result)
    case "disableScreenshotBlocking":
      disableScreenshotBlocking(result: result)
    case "isScreenshotBlockingEnabled":
      result(isScreenshotBlocked)
    case "enableSecureMode":
      enableSecureMode(result: result)
    case "disableSecureMode":
      disableSecureMode(result: result)
    case "setSecureFlag":
      if let args = call.arguments as? [String: Any],
         let secure = args["secure"] as? Bool {
        setSecureFlag(secure: secure, result: result)
      } else {
        result(false)
      }
    case "enableScreenshotDetection":
      enableScreenshotDetection(result: result)
    case "disableScreenshotDetection":
      disableScreenshotDetection(result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func enableScreenshotBlocking(result: @escaping FlutterResult) {
    DispatchQueue.main.async {
      if let window = UIApplication.shared.windows.first {
// Method 1: Add a security view that prevents screenshots
        let secureView = UIView()
        secureView.backgroundColor = UIColor.clear
        secureView.tag = 99999
        secureView.isUserInteractionEnabled = false

        window.addSubview(secureView)
        secureView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
                                      secureView.topAnchor.constraint(equalTo: window.topAnchor),
                                      secureView.leadingAnchor.constraint(equalTo: window.leadingAnchor),
                                      secureView.trailingAnchor.constraint(equalTo: window.trailingAnchor),
                                      secureView.bottomAnchor.constraint(equalTo: window.bottomAnchor)
                                    ])

// Method 2: Use a secure text field (iOS technique)
        let secureTextField = UITextField()
        secureTextField.isSecureTextEntry = true
        secureTextField.backgroundColor = UIColor.clear
        secureTextField.isUserInteractionEnabled = false
        secureTextField.tag = 99998

        window.addSubview(secureTextField)
        secureTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
                                      secureTextField.centerXAnchor.constraint(equalTo: window.centerXAnchor),
                                      secureTextField.centerYAnchor.constraint(equalTo: window.centerYAnchor),
                                      secureTextField.widthAnchor.constraint(equalToConstant: 1),
                                      secureTextField.heightAnchor.constraint(equalToConstant: 1)
                                    ])

        window.makeSecure()

        self.isScreenshotBlocked = true
        result(true)
      } else {
        result(false)
      }
    }
  }

  private func disableScreenshotBlocking(result: @escaping FlutterResult) {
    DispatchQueue.main.async {
      if let window = UIApplication.shared.windows.first {
// Remove secure views
        window.viewWithTag(99999)?.removeFromSuperview()
        window.viewWithTag(99998)?.removeFromSuperview()

        self.isScreenshotBlocked = false
        result(true)
      } else {
        result(false)
      }
    }
  }

  private func enableSecureMode(result: @escaping FlutterResult) {
    enableScreenshotBlocking(result: result)
  }

  private func disableSecureMode(result: @escaping FlutterResult) {
    disableScreenshotBlocking(result: result)
  }

  private func setSecureFlag(secure: Bool, result: @escaping FlutterResult) {
    if secure {
      enableScreenshotBlocking(result: result)
    } else {
      disableScreenshotBlocking(result: result)
    }
  }

  private func enableScreenshotDetection(result: @escaping FlutterResult) {
// Enable screenshot detection using UIApplicationUserDidTakeScreenshotNotification
    screenshotObserver = NotificationCenter.default.addObserver(
        forName: UIApplication.userDidTakeScreenshotNotification,
        object: nil,
        queue: .main
    ) { [weak self] _ in
      self?.handleScreenshotDetected()
    }

    result(true)
  }

  private func disableScreenshotDetection(result: @escaping FlutterResult) {
    if let observer = screenshotObserver {
      NotificationCenter.default.removeObserver(observer)
      screenshotObserver = nil
    }
    result(true)
  }

  private func handleScreenshotDetected() {
    let eventData: [String: Any] = [
      "type": "screenshot_taken",
      "timestamp": Int64(Date().timeIntervalSince1970 * 1000),
      "metadata": [
        "message": "Screenshot was taken",
        "platform": "ios"
      ]
    ]

    eventSink?(eventData)
  }
}

// Extension to make UIWindow secure
extension UIWindow {
  func makeSecure() {
    DispatchQueue.main.async {
      let field = UITextField()
      field.isSecureTextEntry = true
      self.addSubview(field)
      field.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
      field.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
      self.layer.superlayer?.addSublayer(field.layer)
      field.layer.sublayers?.first?.addSublayer(self.layer)
    }
  }
}

// FlutterEventChannel StreamHandler implementation
extension FlutterScreenshotBlockerPlugin: FlutterStreamHandler {
  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    eventSink = events
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    return nil
  }
}
