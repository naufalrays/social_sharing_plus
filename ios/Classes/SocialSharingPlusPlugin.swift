import Flutter
import UIKit
import Photos

public class SocialSharingPlusPlugin: NSObject, FlutterPlugin {
    
    /// Retains the document interaction controller for Instagram Stories sharing.
    private var documentInteractionController: UIDocumentInteractionController?
    
    // MARK: - FlutterPlugin Protocol Methods
    
    /// Registers the plugin with the Flutter engine.
    ///
    /// - Parameters:
    ///   - registrar: FlutterPluginRegistrar object.
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "social_sharing_plus", binaryMessenger: registrar.messenger())
        let instance = SocialSharingPlusPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    // MARK: - Method Call Handler
    
    /// Handles method calls from Flutter.
    ///
    /// - Parameters:
    ///   - call: Flutter method call object.
    ///   - result: FlutterResult object to complete the call.
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any] else {
            result(FlutterError(code: "ARGUMENT_ERROR", message: "Invalid arguments", details: nil))
            return
        }
        
        let isOpenBrowser = arguments["isOpenBrowser"] as? Bool ?? false

        switch call.method {
        case "shareToFacebook":
            shareToFacebook(arguments: arguments, result: result, isOpenBrowser: isOpenBrowser)
        case "shareToTwitter":
            shareToTwitter(arguments: arguments, result: result, isOpenBrowser: isOpenBrowser)
        case "shareToLinkedIn":
            shareToLinkedIn(arguments: arguments, result: result, isOpenBrowser: isOpenBrowser)
        case "shareToWhatsApp":
            shareToWhatsApp(arguments: arguments, result: result, isOpenBrowser: isOpenBrowser)
        case "shareToReddit":
            shareToReddit(arguments: arguments, result: result, isOpenBrowser: isOpenBrowser)
        case "shareToTelegram":
            shareToTelegram(arguments: arguments, result: result, isOpenBrowser: isOpenBrowser)
        case "shareToInstagram":
            shareToInstagram(arguments: arguments, result: result, isOpenBrowser: isOpenBrowser)
        case "shareToInstagramStories":
            shareToInstagramStories(arguments: arguments, result: result, isOpenBrowser: isOpenBrowser)
        case "shareToInstagramReels":
            shareToInstagramReels(arguments: arguments, result: result, isOpenBrowser: isOpenBrowser)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: - Share Methods
    
    /// Shares content to Facebook.
    ///
    /// - Parameters:
    ///   - arguments: Arguments dictionary containing content and image URIs.
    ///   - result: FlutterResult object to complete the call.
    ///   - isOpenBrowser: Flag indicating whether to open in browser if app not installed.
    private func shareToFacebook(arguments: [String: Any], result: @escaping FlutterResult, isOpenBrowser: Bool) {
        if let content = arguments["content"] as? String, let imageUri = arguments["media"] as? String {
            shareContentAndImageToSpecificApp(content: content, imageUri: imageUri, appUrlScheme: "fb://publish/profile/me?text=\(content)", webUrlString: "https://www.facebook.com/sharer/sharer.php?u=\(content)", result: result, isOpenBrowser: isOpenBrowser)
        } else if let content = arguments["content"] as? String {
            let urlString = "fb://publish/profile/me?text=\(content)"
            let webUrlString = "https://www.facebook.com/sharer/sharer.php?u=\(content)"
            openUrl(urlString: urlString, webUrlString: webUrlString, result: result, isOpenBrowser: isOpenBrowser)
        } else if let imageUri = arguments["media"] as? String {
            shareImageToSpecificApp(imageUri: imageUri, appUrlScheme: "fb://", result: result, isOpenBrowser: isOpenBrowser)
        }
    }

    /// Shares content to Twitter.
    ///
    /// - Parameters:
    ///   - arguments: Arguments dictionary containing content and image URIs.
    ///   - result: FlutterResult object to complete the call.
    ///   - isOpenBrowser: Flag indicating whether to open in browser if app not installed.
    private func shareToTwitter(arguments: [String: Any], result: @escaping FlutterResult, isOpenBrowser: Bool) {
        if let content = arguments["content"] as? String, let imageUri = arguments["media"] as? String {
            shareContentAndImageToSpecificApp(content: content, imageUri: imageUri, appUrlScheme: "twitter://post?message=\(content)", webUrlString: "https://x.com/intent/tweet?text=\(content)", result: result, isOpenBrowser: isOpenBrowser)
        } else if let content = arguments["content"] as? String {
            let urlString = "twitter://post?message=\(content)"
            let webUrlString = "https://x.com/intent/tweet?text=\(content)"
            openUrl(urlString: urlString, webUrlString: webUrlString, result: result, isOpenBrowser: isOpenBrowser)
        } else if let imageUri = arguments["media"] as? String {
            shareImageToSpecificApp(imageUri: imageUri, appUrlScheme: "twitter://", result: result, isOpenBrowser: isOpenBrowser)
        }
    }

    /// Shares content to LinkedIn.
    ///
    /// - Parameters:
    ///   - arguments: Arguments dictionary containing content URI.
    ///   - result: FlutterResult object to complete the call.
    ///   - isOpenBrowser: Flag indicating whether to open in browser if app not installed.
    private func shareToLinkedIn(arguments: [String: Any], result: @escaping FlutterResult, isOpenBrowser: Bool) {
        if let content = arguments["content"] as? String {
            let urlString = "linkedin://shareArticle?mini=true&url=\(content)"
            let webUrlString = "https://www.linkedin.com/sharing/share-offsite/?url=\(content)"
            openUrl(urlString: urlString, webUrlString: webUrlString, result: result, isOpenBrowser: isOpenBrowser)
        }
    }

    /// Shares content to WhatsApp.
    ///
    /// - Parameters:
    ///   - arguments: Arguments dictionary containing content and image URIs.
    ///   - result: FlutterResult object to complete the call.
    ///   - isOpenBrowser: Flag indicating whether to open in browser if app not installed.
    private func shareToWhatsApp(arguments: [String: Any], result: @escaping FlutterResult, isOpenBrowser: Bool) {
        if let content = arguments["content"] as? String, let imageUri = arguments["media"] as? String {
            shareContentAndImageToSpecificApp(content: content, imageUri: imageUri, appUrlScheme: "whatsapp://send?text=\(content)", webUrlString: "https://api.whatsapp.com/send?text=\(content)", result: result, isOpenBrowser: isOpenBrowser)
        } else if let content = arguments["content"] as? String {
            let urlString = "whatsapp://send?text=\(content)"
            let webUrlString = "https://api.whatsapp.com/send?text=\(content)"
            openUrl(urlString: urlString, webUrlString: webUrlString, result: result, isOpenBrowser: isOpenBrowser)
        } else if let imageUri = arguments["media"] as? String {
            shareImageToSpecificApp(imageUri: imageUri, appUrlScheme: "whatsapp://", result: result, isOpenBrowser: isOpenBrowser)
        }
    }

    /// Shares content to Reddit.
    ///
    /// - Parameters:
    ///   - arguments: Arguments dictionary containing content URI.
    ///   - result: FlutterResult object to complete the call.
    ///   - isOpenBrowser: Flag indicating whether to open in browser if app not installed.
    private func shareToReddit(arguments: [String: Any], result: @escaping FlutterResult, isOpenBrowser: Bool) {
        if let content = arguments["content"] as? String {
            let urlString = "reddit://submit?url=\(content)"
            let webUrlString = "https://www.reddit.com/submit?title=\(content)"
            openUrl(urlString: urlString, webUrlString: webUrlString, result: result, isOpenBrowser: isOpenBrowser)
        }
    }

    /// Shares content to Telegram.
    ///
    /// - Parameters:
    ///   - arguments: Arguments dictionary containing content and image URIs.
    ///   - result: FlutterResult object to complete the call.
    ///   - isOpenBrowser: Flag indicating whether to open in browser if app not installed.
    private func shareToTelegram(arguments: [String: Any], result: @escaping FlutterResult, isOpenBrowser: Bool) {
        if let content = arguments["content"] as? String, let imageUri = arguments["media"] as? String {
            shareContentAndImageToSpecificApp(content: content, imageUri: imageUri, appUrlScheme: "tg://msg?text=\(content)", webUrlString: "https://t.me/share/url?url=\(content)", result: result, isOpenBrowser: isOpenBrowser)
        } else if let content = arguments["content"] as? String {
            let urlString = "tg://msg?text=\(content)"
            let webUrlString = "https://t.me/share/url?url=\(content)"
            openUrl(urlString: urlString, webUrlString: webUrlString, result: result, isOpenBrowser: isOpenBrowser)
        } else if let imageUri = arguments["media"] as? String {
            shareImageToSpecificApp(imageUri: imageUri, appUrlScheme: "tg://", result: result, isOpenBrowser: isOpenBrowser)
        }
    }

    // MARK: - Instagram Share Methods

    /// Shares media to Instagram.
    /// Opens Instagram with the media, allowing the user to choose between Feed, Stories, Reels, or Direct.
    ///
    /// On iOS, this saves the media to the photo library and opens Instagram.
    /// Instagram will let the user choose what to do with the most recent photo/video.
    ///
    /// - Parameters:
    ///   - arguments: Arguments dictionary containing media path.
    ///   - result: FlutterResult object to complete the call.
    ///   - isOpenBrowser: Flag indicating whether to open in browser if app not installed.
    private func shareToInstagram(arguments: [String: Any], result: @escaping FlutterResult, isOpenBrowser: Bool) {
        guard let mediaPath = arguments["media"] as? String else {
            result(FlutterError(code: "NO_MEDIA", message: "Instagram requires media (image or video) to share", details: nil))
            return
        }

        let fileUrl = URL(fileURLWithPath: mediaPath)
        let isVideo = ["mp4", "mov", "avi"].contains(fileUrl.pathExtension.lowercased())

        // Save media to photo library, then open Instagram
        saveMediaToPhotoLibrary(fileUrl: fileUrl, isVideo: isVideo) { success in
            DispatchQueue.main.async {
                if success {
                    let instagramUrl = "instagram://library?AssetPath=\(mediaPath)"
                    if let url = URL(string: instagramUrl), UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        result(nil)
                    } else if isOpenBrowser {
                        if let webUrl = URL(string: "https://www.instagram.com/") {
                            UIApplication.shared.open(webUrl, options: [:], completionHandler: nil)
                        }
                        result(nil)
                    } else {
                        result(FlutterError(code: "APP_NOT_INSTALLED", message: "Instagram is not installed", details: nil))
                    }
                } else {
                    result(FlutterError(code: "SAVE_ERROR", message: "Failed to save media to photo library", details: nil))
                }
            }
        }
    }

    /// Shares media directly to Instagram Stories using UIDocumentInteractionController.
    ///
    /// - Parameters:
    ///   - arguments: Arguments dictionary containing media path.
    ///   - result: FlutterResult object to complete the call.
    ///   - isOpenBrowser: Flag indicating whether to open in browser if app not installed.
    private func shareToInstagramStories(arguments: [String: Any], result: @escaping FlutterResult, isOpenBrowser: Bool) {
        guard let mediaPath = arguments["media"] as? String else {
            result(FlutterError(code: "NO_MEDIA", message: "Instagram Stories requires media (image or video) to share", details: nil))
            return
        }

        let instagramStoriesUrl = URL(string: "instagram-stories://share")!
        if UIApplication.shared.canOpenURL(instagramStoriesUrl) {
            let fileUrl = URL(fileURLWithPath: mediaPath)
            let isVideo = ["mp4", "mov", "avi"].contains(fileUrl.pathExtension.lowercased())

            guard let mediaData = try? Data(contentsOf: fileUrl) else {
                result(FlutterError(code: "FILE_ERROR", message: "Unable to read media file", details: nil))
                return
            }

            let pasteboardItems: [[String: Any]]
            if isVideo {
                pasteboardItems = [["com.instagram.sharedSticker.backgroundVideo": mediaData]]
            } else {
                pasteboardItems = [["com.instagram.sharedSticker.backgroundImage": mediaData]]
            }

            let pasteboardOptions: [UIPasteboard.OptionsKey: Any] = [
                .expirationDate: Date(timeIntervalSinceNow: 300)
            ]

            UIPasteboard.general.setItems(pasteboardItems, options: pasteboardOptions)
            UIApplication.shared.open(instagramStoriesUrl, options: [:], completionHandler: nil)
            result(nil)
        } else if isOpenBrowser {
            if let webUrl = URL(string: "https://www.instagram.com/") {
                UIApplication.shared.open(webUrl, options: [:], completionHandler: nil)
            }
            result(nil)
        } else {
            result(FlutterError(code: "APP_NOT_INSTALLED", message: "Instagram is not installed", details: nil))
        }
    }

    /// Shares video to Instagram Reels.
    ///
    /// - Parameters:
    ///   - arguments: Arguments dictionary containing video path.
    ///   - result: FlutterResult object to complete the call.
    ///   - isOpenBrowser: Flag indicating whether to open in browser if app not installed.
    private func shareToInstagramReels(arguments: [String: Any], result: @escaping FlutterResult, isOpenBrowser: Bool) {
        guard let mediaPath = arguments["media"] as? String else {
            result(FlutterError(code: "NO_MEDIA", message: "Instagram Reels requires a video to share", details: nil))
            return
        }

        let fileUrl = URL(fileURLWithPath: mediaPath)
        let isVideo = ["mp4", "mov", "avi"].contains(fileUrl.pathExtension.lowercased())

        if !isVideo {
            result(FlutterError(code: "INVALID_MEDIA", message: "Instagram Reels requires a video file (mp4, mov)", details: nil))
            return
        }

        let instagramReelsUrl = URL(string: "instagram-reels://share")!
        if UIApplication.shared.canOpenURL(instagramReelsUrl) {
            guard let videoData = try? Data(contentsOf: fileUrl) else {
                result(FlutterError(code: "FILE_ERROR", message: "Unable to read video file", details: nil))
                return
            }

            let pasteboardItems: [[String: Any]] = [
                ["com.instagram.sharedSticker.backgroundVideo": videoData]
            ]
            let pasteboardOptions: [UIPasteboard.OptionsKey: Any] = [
                .expirationDate: Date(timeIntervalSinceNow: 300)
            ]

            UIPasteboard.general.setItems(pasteboardItems, options: pasteboardOptions)
            UIApplication.shared.open(instagramReelsUrl, options: [:], completionHandler: nil)
            result(nil)
        } else if isOpenBrowser {
            if let webUrl = URL(string: "https://www.instagram.com/") {
                UIApplication.shared.open(webUrl, options: [:], completionHandler: nil)
            }
            result(nil)
        } else {
            result(FlutterError(code: "APP_NOT_INSTALLED", message: "Instagram is not installed", details: nil))
        }
    }

    // MARK: - Helper Methods

    /// Saves media (image or video) to the photo library.
    ///
    /// - Parameters:
    ///   - fileUrl: URL of the media file.
    ///   - isVideo: Whether the media is a video.
    ///   - completion: Completion handler with success status.
    private func saveMediaToPhotoLibrary(fileUrl: URL, isVideo: Bool, completion: @escaping (Bool) -> Void) {
        let performSave: () -> Void = {
            PHPhotoLibrary.shared().performChanges({
                if isVideo {
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileUrl)
                } else {
                    if let image = UIImage(contentsOfFile: fileUrl.path) {
                        PHAssetChangeRequest.creationRequestForAsset(from: image)
                    }
                }
            }) { success, error in
                completion(success)
            }
        }

        if #available(iOS 14, *) {
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                guard status == .authorized || status == .limited else {
                    completion(false)
                    return
                }
                performSave()
            }
        } else {
            PHPhotoLibrary.requestAuthorization { status in
                guard status == .authorized else {
                    completion(false)
                    return
                }
                performSave()
            }
        }
    }
    
    // MARK: - URL Handling
    
    /// Opens the specified URL.
    ///
    /// - Parameters:
    ///   - urlString: URL string to open.
    ///   - webUrlString: Web URL string to open if app URL is not available.
    ///   - result: FlutterResult object to complete the call.
    ///   - isOpenBrowser: Flag indicating whether to open in browser if app not installed.
    private func openUrl(urlString: String, webUrlString: String, result: @escaping FlutterResult, isOpenBrowser: Bool) {
        if let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                result(nil)
            } else if isOpenBrowser, let webUrl = URL(string: webUrlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") {
                UIApplication.shared.open(webUrl, options: [:], completionHandler: nil)
                result(nil)
            } else {
                result(FlutterError(code: "APP_NOT_INSTALLED", message: "App not installed and browser option is not enabled", details: nil))
            }
        } else {
            result(FlutterError(code: "URL_ERROR", message: "Invalid URL", details: nil))
        }
    }
    
    // MARK: - Image Sharing
    
    /// Shares an image to a specific app.
    ///
    /// - Parameters:
    ///   - imageUri: Image file URI.
    ///   - appUrlScheme: App URL scheme to open.
    ///   - result: FlutterResult object to complete the call.
    ///   - isOpenBrowser: Flag indicating whether to open in browser if app not installed.
    private func shareImageToSpecificApp(imageUri: String, appUrlScheme: String, result: @escaping FlutterResult, isOpenBrowser: Bool) {
        guard let image = UIImage(contentsOfFile: imageUri) else {
            result(FlutterError(code: "IMAGE_ERROR", message: "Invalid image path", details: nil))
            return
        }
        guard let imageData = image.pngData() else {
            result(FlutterError(code: "IMAGE_DATA_ERROR", message: "Unable to get image data", details: nil))
            return
        }

        let pasteboard = UIPasteboard.general
        pasteboard.setData(imageData, forPasteboardType: "public.png")

        let urlString = "\(appUrlScheme)"
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            result(nil)
        } else if isOpenBrowser {
            result(FlutterError(code: "APP_NOT_INSTALLED", message: "App not installed and browser option is not enabled", details: nil))
        } else {
            result(FlutterError(code: "APP_NOT_INSTALLED", message: "App not installed", details: nil))
        }
    }

    /// Shares content and image to a specific app.
    ///
    /// - Parameters:
    ///   - content: Content string to share.
    ///   - imageUri: Image file URI.
    ///   - appUrlScheme: App URL scheme to open.
    ///   - webUrlString: Web URL string to open if app URL is not available.
    ///   - result: FlutterResult object to complete the call.
    ///   - isOpenBrowser: Flag indicating whether to open in browser if app not installed.
    private func shareContentAndImageToSpecificApp(content: String, imageUri: String, appUrlScheme: String, webUrlString: String, result: @escaping FlutterResult, isOpenBrowser: Bool) {
        guard let image = UIImage(contentsOfFile: imageUri) else {
            result(FlutterError(code: "IMAGE_ERROR", message: "Invalid image path", details: nil))
            return
        }
        guard let imageData = image.pngData() else {
            result(FlutterError(code: "IMAGE_DATA_ERROR", message: "Unable to get image data", details: nil))
            return
        }

        let pasteboard = UIPasteboard.general
        pasteboard.setData(imageData, forPasteboardType: "public.png")

        var urlString = "\(appUrlScheme)"
        if appUrlScheme.contains("twitter://") {
            urlString += "post?message=\(content)"
        } else if appUrlScheme.contains("fb://") {
            urlString += "publish/profile/me?text=\(content)"
        } else if appUrlScheme.contains("whatsapp://") {
            urlString += "send?text=\(content)"
        } else if appUrlScheme.contains("tg://") {
            urlString += "msg?text=\(content)"
        }

        if let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            result(nil)
        } else if isOpenBrowser, let webUrl = URL(string: webUrlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") {
            UIApplication.shared.open(webUrl, options: [:], completionHandler: nil)
            result(nil)
        } else {
            result(FlutterError(code: "APP_NOT_INSTALLED", message: "App not installed and browser option is not enabled", details: nil))
        }
    }
}
