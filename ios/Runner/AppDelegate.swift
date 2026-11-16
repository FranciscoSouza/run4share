import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    guard let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "Run4shareSystem")
    else { return }
    // Same channel as Android's MainActivity (lib/app/system.dart and
    // lib/features/share/share_actions.dart).
    let channel = FlutterMethodChannel(
      name: "run4share/system",
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      switch call.method {
      // The sticker-only PNG onto the pasteboard, to paste into a story.
      case "copyImage":
        guard let args = call.arguments as? [String: Any],
          let path = args["path"] as? String,
          let data = FileManager.default.contents(atPath: path)
        else {
          result(false)
          return
        }
        UIPasteboard.general.setData(data, forPasteboardType: "public.png")
        result(true)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
