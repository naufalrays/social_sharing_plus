import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_sharing_plus/social_sharing_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SharePage(),
    );
  }
}

class SharePage extends StatefulWidget {
  const SharePage({super.key});

  @override
  State<SharePage> createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
  final TextEditingController _controller = TextEditingController();

  /// Non-Instagram platforms
  static const List<SocialPlatform> _generalPlatforms = [
    SocialPlatform.facebook,
    SocialPlatform.linkedin,
    SocialPlatform.reddit,
    SocialPlatform.twitter,
    SocialPlatform.whatsapp,
    SocialPlatform.telegram,
    SocialPlatform.instagram,
  ];

  /// Instagram-specific platforms (direct sharing without chooser popup)
  static const List<SocialPlatform> _instagramPlatforms = [
    SocialPlatform.instagramStories,
    SocialPlatform.instagramReels,
  ];

  final ImagePicker _picker = ImagePicker();
  String? _mediaPath;
  List<String> _mediaPaths = [];

  String _instagramLabel(SocialPlatform platform) {
    switch (platform) {
      case SocialPlatform.instagramStories:
        return 'Instagram Stories';
      case SocialPlatform.instagramReels:
        return 'Instagram Reels';
      default:
        return platform.name.capitalize;
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) _mediaPath = pickedFile.path;
    });
  }

  Future<void> _pickVideo() async {
    final XFile? pickedFile =
        await _picker.pickVideo(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) _mediaPath = pickedFile.path;
    });
  }

  Future<void> _pickMultiMedia() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();

    setState(() {
      _mediaPaths = pickedFiles.map((file) => file.path).toList();
    });
  }

  Future<void> _pickMultiVideo() async {
    final XFile? pickedFile =
        await _picker.pickVideo(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _mediaPaths.add(pickedFile.path);
      }
    });
  }

  Future<void> _share(SocialPlatform platform) async {
    final String content = _controller.text;

    // Check if we should use multiple share (if _mediaPaths has items)
    final bool shouldUseMultipleShare = _mediaPaths.isNotEmpty;

    // Check if Instagram requires media
    final bool isInstagram = platform == SocialPlatform.instagram ||
        platform == SocialPlatform.instagramStories ||
        platform == SocialPlatform.instagramReels;

    if (isInstagram && _mediaPath == null && _mediaPaths.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('Instagram requires media (image or video) to share.'),
        ));
      return;
    }

    if (shouldUseMultipleShare) {
      await SocialSharingPlus.shareToSocialMediaWithMultipleMedia(
        platform,
        media: _mediaPaths,
        content: content,
        isOpenBrowser: true,
        onAppNotInstalled: () {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Text('${platform.name.capitalize} is not installed.'),
            ));
        },
      );
    } else {
      await SocialSharingPlus.shareToSocialMedia(
        platform,
        content,
        media: _mediaPath,
        isOpenBrowser: true,
        onAppNotInstalled: () {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
              content: Text('${platform.name.capitalize} is not installed.'),
            ));
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('social_sharing_plus'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(24),
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter a text',
                  ),
                ),
              ),
              // Show selected media info
              if (_mediaPath != null || _mediaPaths.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      children: [
                        if (_mediaPath != null)
                          Text(
                            '✓ Single media selected',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        if (_mediaPaths.isNotEmpty)
                          Text(
                            '✓ ${_mediaPaths.length} media files selected',
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        const SizedBox(height: 4),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _mediaPath = null;
                              _mediaPaths = [];
                            });
                          },
                          child: const Text('Clear Selection'),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('Pick Image'),
                  ),
                  const SizedBox(width: 20),
                  if (Platform.isAndroid)
                    ElevatedButton(
                      onPressed: _pickVideo,
                      child: const Text('Pick Video'),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _pickMultiMedia,
                      child: const Text('Pick Multi Image'),
                    ),
                    const SizedBox(width: 20),
                    if (Platform.isAndroid)
                      ElevatedButton(
                        onPressed: _pickMultiVideo,
                        child: const Text('Pick Multi Video'),
                      ),
                  ],
                ),
              ),
              ..._generalPlatforms.map(
                (SocialPlatform platform) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ElevatedButton(
                    onPressed: () => _share(platform),
                    child: Text('Share to ${platform.name.capitalize}'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Divider(),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Instagram (Direct)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ..._instagramPlatforms.map(
                (SocialPlatform platform) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ElevatedButton.icon(
                    onPressed: () => _share(platform),
                    icon: const Icon(Icons.camera_alt),
                    label: Text(_instagramLabel(platform)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String get capitalize => "${this[0].toUpperCase()}${substring(1)}";
}
