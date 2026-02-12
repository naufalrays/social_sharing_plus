/// Enum representing the various social media platforms.
enum SocialPlatform {
  /// Represents Facebook.
  ///
  /// For [iOS], only URL sharing is supported.
  ///
  /// For [Android], you can share both text, images and video in groups, as a profile picture, as a post/story or message.
  facebook,

  /// Represents LinkedIn.
  ///
  /// For [iOS], only text sharing is supported.
  ///
  /// For [Android], you can share both text, images and video in groups, as a post or message.
  linkedin,

  /// Represents Reddit.
  ///
  /// For [iOS], only text sharing is supported.
  ///
  /// For [Android], you can share both text, images and video as a post.
  reddit,

  /// Represents Reddit.
  ///
  /// For [iOS], only text sharing is supported.
  ///
  /// For [Android], you can share both text, images and video in groups, as a tweet or message.
  twitter,

  /// Represents WhatsApp.
  ///
  /// For [iOS], only text sharing is supported.
  ///
  /// For [Android], you can share both text, images and videos.
  whatsapp,

  /// Represents Telegram.
  ///
  /// For [iOS], only text sharing is supported.
  ///
  /// For [Android], you can share both text, images and videos.
  telegram,

  /// Represents Instagram.
  ///
  /// Share media to Instagram. Android will show a chooser dialog
  /// allowing the user to pick between Feed, Reels, Stories, or Direct.
  ///
  /// **IMPORTANT**: Instagram requires media (image or video) to share. Text-only sharing is not supported.
  instagram,

  /// Represents Instagram Stories.
  ///
  /// Share media to Instagram Stories.
  ///
  /// **IMPORTANT**: Instagram requires media (image or video) to share. Text-only sharing is not supported.
  instagramStories,

  /// Represents Instagram Reels.
  ///
  /// Share video to Instagram Reels.
  ///
  /// **IMPORTANT**: Instagram requires video to share to Reels.
  instagramReels;

  /// Returns the method name corresponding to each social media platform.
  String get methodName {
    switch (this) {
      case SocialPlatform.facebook:
        return 'shareToFacebook';
      case SocialPlatform.linkedin:
        return 'shareToLinkedIn';
      case SocialPlatform.reddit:
        return 'shareToReddit';
      case SocialPlatform.twitter:
        return 'shareToTwitter';
      case SocialPlatform.whatsapp:
        return 'shareToWhatsApp';
      case SocialPlatform.telegram:
        return 'shareToTelegram';
      case SocialPlatform.instagram:
        return 'shareToInstagram';
      case SocialPlatform.instagramStories:
        return 'shareToInstagramStories';
      case SocialPlatform.instagramReels:
        return 'shareToInstagramReels';
    }
  }
}
