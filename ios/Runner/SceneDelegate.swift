import Flutter
import UIKit

/// Custom scene delegate that intercepts `.tallee` files opened from outside the
/// app sandbox (Files app, iCloud Drive, "Open in place" providers).
///
/// Such files are delivered as security-scoped URLs that live outside the app
/// container. Flutter's default deep-linking forwards the raw path without ever
/// starting security-scoped access, so `File(path).exists()` returns `false` in
/// Dart. To fix this we take over URL delivery: we start security-scoped access,
/// copy the file into the app sandbox, and hand the *copied* path to Dart over a
/// method channel. Flutter's automatic deep linking is disabled in Info.plist
/// (`FlutterDeepLinkingEnabled = false`) so it never competes with this logic.
@objc(SceneDelegate)
class SceneDelegate: FlutterSceneDelegate {
  private static let channelName = "de.liquid.tallee/import"
  private static let importsDirName = "imports"

  private var channel: FlutterMethodChannel?
  private var pendingPaths: [String] = []

  // MARK: - Scene lifecycle

  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)
    setupChannelIfNeeded()
    // Cold start: Dart isn't listening yet, so buffer for the initial pull.
    handle(urlContexts: connectionOptions.urlContexts, coldStart: true)
  }

  override func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
    setupChannelIfNeeded()
    // Warm start: the app is already running, so push to Dart directly.
    handle(urlContexts: URLContexts, coldStart: false)
  }

  // MARK: - URL handling

  private func handle(urlContexts: Set<UIOpenURLContext>, coldStart: Bool) {
    let paths = urlContexts.compactMap { copyIntoSandbox($0.url) }
    guard !paths.isEmpty else { return }

    if !coldStart, let channel = channel {
      for path in paths {
        channel.invokeMethod("onFileOpened", arguments: path)
      }
    } else {
      pendingPaths.append(contentsOf: paths)
    }
  }

  /// Copies the security-scoped file at [url] into the app's temporary directory
  /// and returns the copied path, or `nil` on failure.
  private func copyIntoSandbox(_ url: URL) -> String? {
    let shouldStopAccessing = url.startAccessingSecurityScopedResource()
    defer {
      if shouldStopAccessing {
        url.stopAccessingSecurityScopedResource()
      }
    }

    let fileManager = FileManager.default
    let destinationDir = fileManager.temporaryDirectory
      .appendingPathComponent(Self.importsDirName, isDirectory: true)
    let destination = destinationDir.appendingPathComponent(url.lastPathComponent)

    do {
      try fileManager.createDirectory(
        at: destinationDir, withIntermediateDirectories: true, attributes: nil)
    } catch {
      NSLog("SceneDelegate: failed to create imports directory: \(error)")
      return nil
    }

    var coordinatorError: NSError?
    var copyError: Error?
    NSFileCoordinator().coordinate(
      readingItemAt: url, options: .withoutChanges, error: &coordinatorError
    ) { readURL in
      do {
        if fileManager.fileExists(atPath: destination.path) {
          try fileManager.removeItem(at: destination)
        }
        try fileManager.copyItem(at: readURL, to: destination)
      } catch {
        copyError = error
      }
    }

    if let error = coordinatorError ?? copyError {
      NSLog("SceneDelegate: failed to copy imported file: \(error)")
      return nil
    }
    return destination.path
  }

  // MARK: - Method channel

  private func setupChannelIfNeeded() {
    guard channel == nil,
      let controller = window?.rootViewController as? FlutterViewController
    else {
      return
    }

    let channel = FlutterMethodChannel(
      name: Self.channelName, binaryMessenger: controller.binaryMessenger)
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else {
        result(nil)
        return
      }
      switch call.method {
      case "getInitialFile":
        result(self.pendingPaths.isEmpty ? nil : self.pendingPaths.removeFirst())
      default:
        result(FlutterMethodNotImplemented)
      }
    }
    self.channel = channel
  }
}
