package com.example.social_sharing_plus

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.core.content.FileProvider
import com.example.social_sharing_plus.utils.MediaType
import com.example.social_sharing_plus.utils.SharePaths
import com.example.social_sharing_plus.utils.SocialConstants
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.io.File

/** SocialSharingPlusPlugin */
class SocialSharingPlusPlugin : FlutterPlugin, MethodCallHandler {

    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, SocialConstants.CHANNEL_NAME)
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            SocialConstants.FACEBOOK ->
                    shareToSocialMedia(SocialConstants.FACEBOOK_PACKAGE_NAME, call, result)
            SocialConstants.TWITTER ->
                    shareToSocialMedia(SocialConstants.TWITTER_PACKAGE_NAME, call, result)
            SocialConstants.LINKEDIN ->
                    shareToSocialMedia(SocialConstants.LINKEDIN_PACKAGE_NAME, call, result)
            SocialConstants.WHATSAPP ->
                    shareToSocialMedia(SocialConstants.WHATSAPP_PACKAGE_NAME, call, result)
            SocialConstants.REDDIT ->
                    shareToSocialMedia(SocialConstants.REDDIT_PACKAGE_NAME, call, result)
            SocialConstants.TELEGRAM ->
                    shareToSocialMedia(SocialConstants.TELEGRAM_PACKAGE_NAME, call, result)
            SocialConstants.INSTAGRAM ->
                    shareToInstagram(call, result)
            SocialConstants.INSTAGRAM_STORIES ->
                    shareToInstagramStories(call, result)
            SocialConstants.INSTAGRAM_REELS ->
                    shareToInstagramReels(call, result)
            else -> result.notImplemented()
        }
    }

    private fun shareToSocialMedia(packageName: String, call: MethodCall, result: Result) {
        val content: String? = call.argument<String>("content")

        val media: Any? = call.argument<Any>("media")
        val isOpenBrowser: Boolean = call.argument<Boolean>("isOpenBrowser") ?: false

        val mediaUris: List<Uri?> =
                when (media) {
                    is String -> {
                      
                        val file = File(media)
                        listOf(
                                FileProvider.getUriForFile(
                                        context,
                                        "${context.packageName}.fileprovider",
                                        file
                                )
                        )
                    }
                    is List<*> -> {
                      
                        media.mapNotNull { mediaUriString ->
                            if (mediaUriString is String) {
                                val file = File(mediaUriString)
                                FileProvider.getUriForFile(
                                        context,
                                        "${context.packageName}.fileprovider",
                                        file
                                )
                            } else {
                                null
                            }
                        }
                    }
                    else -> emptyList()
                }

        if (mediaUris.isNotEmpty()) {
            shareMultipleMedia(packageName, content, mediaUris, result, isOpenBrowser)
        } else {
            shareSingleMedia(packageName, content, null, result, isOpenBrowser)
        }
    }

    private fun shareSingleMedia(
            packageName: String,
            content: String?,
            mediaUri: Uri?,
            result: Result,
            isOpenBrowser: Boolean
    ) {
        val intent: Intent =
                Intent(Intent.ACTION_SEND).apply {
                    type =
                            mediaUri?.let {
                                val extension: String = mediaUri.toString().substringAfterLast(".")
                                if (extension == SharePaths.MP4.reference) MediaType.VIDEO.reference
                                else MediaType.IMAGE.reference
                            }
                                    ?: SharePaths.TEXT_PLAIN.reference

                    putExtra(Intent.EXTRA_TEXT, content)
                    mediaUri?.let {
                        putExtra(Intent.EXTRA_STREAM, it)
                        addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                    }
                    setPackage(packageName)
                }

        if (intent.resolveActivity(context.packageManager) != null) {
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(intent)
            result.success(null)
        } else {
            if (isOpenBrowser) {
                openInBrowser(packageName, content ?: "", mediaUri)
                result.success(null)
            } else {
                result.error("APP_NOT_INSTALLED", "$packageName is not installed", null)
            }
        }
    }

    private fun shareMultipleMedia(
            packageName: String,
            content: String?,
            mediaUris: List<Uri?>,
            result: Result,
            isOpenBrowser: Boolean
    ) {
        val intent: Intent =
                Intent(Intent.ACTION_SEND_MULTIPLE).apply {
                    type =
                            MediaType.IMAGE
                                    .reference
                    putExtra(Intent.EXTRA_TEXT, content)

                    if (mediaUris.isNotEmpty()) {
                        putParcelableArrayListExtra(Intent.EXTRA_STREAM, ArrayList(mediaUris))
                        addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                    }
                    setPackage(packageName)
                }

        if (intent.resolveActivity(context.packageManager) != null) {
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(intent)
            result.success(null)
        } else {
            if (isOpenBrowser) {
                openInBrowser(packageName, content ?: "", mediaUris.firstOrNull())
                result.success(null)
            } else {
                result.error("APP_NOT_INSTALLED", "$packageName is not installed", null)
            }
        }
    }

    private fun parseMediaUris(call: MethodCall): List<Uri> {
        val media: Any? = call.argument<Any>("media")
        return when (media) {
            is String -> {
                val file = File(media)
                listOf(
                        FileProvider.getUriForFile(
                                context,
                                "${context.packageName}.fileprovider",
                                file
                        )
                )
            }
            is List<*> -> {
                media.mapNotNull { mediaUriString ->
                    if (mediaUriString is String) {
                        val file = File(mediaUriString)
                        FileProvider.getUriForFile(
                                context,
                                "${context.packageName}.fileprovider",
                                file
                        )
                    } else {
                        null
                    }
                }
            }
            else -> emptyList()
        }
    }

    private fun isVideoUri(uri: Uri): Boolean {
        val extension = uri.toString().substringAfterLast(".")
        return extension.equals("mp4", ignoreCase = true) ||
               extension.equals("mov", ignoreCase = true) ||
               extension.equals("avi", ignoreCase = true)
    }

    /**
     * Share to Instagram.
     * Uses ACTION_SEND targeting Instagram package.
     * Android will show a disambiguation dialog letting the user
     * choose between Feed, Reels, Stories, or Direct.
     */
    private fun shareToInstagram(call: MethodCall, result: Result) {
        val content: String? = call.argument<String>("content")
        val isOpenBrowser: Boolean = call.argument<Boolean>("isOpenBrowser") ?: false
        val mediaUris = parseMediaUris(call)

        if (mediaUris.isEmpty()) {
            result.error("NO_MEDIA", "Instagram requires media (image or video) to share", null)
            return
        }

        val mediaUri = mediaUris[0]
        val intent = Intent(Intent.ACTION_SEND).apply {
            type = if (isVideoUri(mediaUri)) "video/*" else "image/*"
            putExtra(Intent.EXTRA_STREAM, mediaUri)
            content?.let { putExtra(Intent.EXTRA_TEXT, it) }
            setPackage(SocialConstants.INSTAGRAM_PACKAGE_NAME)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }

        try {
            context.startActivity(intent)
            result.success(null)
        } catch (e: Exception) {
            handleInstagramNotInstalled(content, mediaUri, isOpenBrowser, result)
        }
    }

    /**
     * Share to Instagram Stories.
     * Uses the custom intent action "com.instagram.share.ADD_TO_STORY".
     */
    private fun shareToInstagramStories(call: MethodCall, result: Result) {
        val content: String? = call.argument<String>("content")
        val isOpenBrowser: Boolean = call.argument<Boolean>("isOpenBrowser") ?: false
        val mediaUris = parseMediaUris(call)

        if (mediaUris.isEmpty()) {
            result.error("NO_MEDIA", "Instagram Stories requires media (image or video) to share", null)
            return
        }

        val mediaUri = mediaUris[0]

        // Grant URI permission to Instagram before creating intent
        context.grantUriPermission(
                SocialConstants.INSTAGRAM_PACKAGE_NAME,
                mediaUri,
                Intent.FLAG_GRANT_READ_URI_PERMISSION
        )

        val intent = Intent(SocialConstants.INSTAGRAM_STORIES_INTENT).apply {
            setDataAndType(mediaUri, if (isVideoUri(mediaUri)) "video/*" else "image/*")
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)

            // Optional: content link
            content?.let { putExtra("content_url", it) }
        }

        try {
            context.startActivity(intent)
            result.success(null)
        } catch (e: Exception) {
            handleInstagramNotInstalled(content, mediaUri, isOpenBrowser, result)
        }
    }

    /**
     * Share to Instagram Reels.
     * Uses the custom intent action "com.instagram.share.ADD_TO_REEL".
     * Requires a video.
     */
    private fun shareToInstagramReels(call: MethodCall, result: Result) {
        val content: String? = call.argument<String>("content")
        val isOpenBrowser: Boolean = call.argument<Boolean>("isOpenBrowser") ?: false
        val mediaUris = parseMediaUris(call)

        if (mediaUris.isEmpty()) {
            result.error("NO_MEDIA", "Instagram Reels requires a video to share", null)
            return
        }

        val mediaUri = mediaUris[0]
        if (!isVideoUri(mediaUri)) {
            result.error("INVALID_MEDIA", "Instagram Reels requires a video file (mp4, mov)", null)
            return
        }

        // Grant URI permission to Instagram before creating intent
        context.grantUriPermission(
                SocialConstants.INSTAGRAM_PACKAGE_NAME,
                mediaUri,
                Intent.FLAG_GRANT_READ_URI_PERMISSION
        )

        val intent = Intent(SocialConstants.INSTAGRAM_REELS_INTENT).apply {
            setDataAndType(mediaUri, "video/*")
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)

            // Optional: content link
            content?.let { putExtra("content_url", it) }
        }

        try {
            context.startActivity(intent)
            result.success(null)
        } catch (e: Exception) {
            handleInstagramNotInstalled(content, mediaUri, isOpenBrowser, result)
        }
    }

    private fun handleInstagramNotInstalled(
            content: String?,
            mediaUri: Uri?,
            isOpenBrowser: Boolean,
            result: Result
    ) {
        if (isOpenBrowser) {
            openInBrowser(SocialConstants.INSTAGRAM_PACKAGE_NAME, content ?: "", mediaUri)
            result.success(null)
        } else {
            result.error(
                    "APP_NOT_INSTALLED",
                    "${SocialConstants.INSTAGRAM_PACKAGE_NAME} is not installed",
                    null
            )
        }
    }

    private fun openInBrowser(packageName: String, content: String, mediaUri: Uri?) {
        val webIntent = Intent(Intent.ACTION_VIEW)
        val webUrlString: String? =
                when (packageName) {
                    SocialConstants.FACEBOOK_PACKAGE_NAME ->
                            "${SocialConstants.FACEBOOK_WEB_URL}$content"
                    SocialConstants.TWITTER_PACKAGE_NAME ->
                            "${SocialConstants.TWITTER_WEB_URL}$content"
                    SocialConstants.LINKEDIN_PACKAGE_NAME ->
                            "${SocialConstants.LINKEDIN_WEB_URL}$content"
                    SocialConstants.WHATSAPP_PACKAGE_NAME ->
                            "${SocialConstants.WHATSAPP_WEB_URL}$content"
                    SocialConstants.REDDIT_PACKAGE_NAME ->
                            "${SocialConstants.REDDIT_WEB_URL}$content"
                    SocialConstants.TELEGRAM_PACKAGE_NAME ->
                            "${SocialConstants.TELEGRAM_WEB_URL}$content"
                    SocialConstants.INSTAGRAM_PACKAGE_NAME ->
                            "${SocialConstants.INSTAGRAM_WEB_URL}$content"
                    else -> null
                }

        val mediaParam: String? =
                mediaUri?.let {
                    val extension: String = mediaUri.toString().substringAfterLast(".")
                    if (extension == SharePaths.MP4.reference)
                            "${SharePaths.VIDEO_URL.reference}${Uri.encode(mediaUri.toString())}"
                    else "${SharePaths.IMAGE_URL.reference}${Uri.encode(mediaUri.toString())}"
                }

        val finalUrlString: String? =
                webUrlString?.let { url -> if (mediaParam != null) "$url&$mediaParam" else url }

        finalUrlString?.let {
            webIntent.data = Uri.parse(it)
            webIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            context.startActivity(webIntent)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
