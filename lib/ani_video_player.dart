library ani_video_player;

import 'dart:io';

import 'package:ani_video_player/desktop_video_player_controls.dart';
import 'package:ani_video_player/utils/utility.dart';
import 'package:ani_video_player/video_configuration.dart';
import 'package:ani_video_player/widgets/video_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class AniVideo extends StatefulWidget {
  final String url;
  final VideoConfiguration? videoConfiguration;

  const AniVideo({
    super.key,
    required this.url,
    this.videoConfiguration,
  });

  static Future<void> ensureInitialized() async {
    MediaKit.ensureInitialized();
    await Utility.checkTV();
  }

  static Future<void> launchVideo(
    BuildContext context,
    String url, {
    VideoConfiguration? videoConfiguration,
  }) async {
    if (Utility.isMobile()) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoScreen(
          url: url,
          videoConfiguration: videoConfiguration,
        ),
      ),
    );

    if (Utility.isMobile()) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
  }

  @override
  State<AniVideo> createState() => _AniVideoState();
}

class _AniVideoState extends State<AniVideo> {
  late final player = Player();
  late final VideoConfiguration videoConfig;

  @override
  void initState() {
    super.initState();

    player.open(Media(widget.url));
    videoConfig = widget.videoConfiguration ?? VideoConfiguration();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      top: false,
      child: Center(
        child: Video(
          controller: VideoController(player),
          controls: (state) => getPlatformControls(state, videoConfig),
          fit: videoConfig.fit,
          aspectRatio: videoConfig.aspectRatio,
          wakelock: videoConfig.wakelock,
        ),
      ),
    );
  }

  Widget getPlatformControls(VideoState state, VideoConfiguration videoConfig) {
    //TODO
    /*
    if (Utility.isTV()) {
      return TvVideoControls(state, videoConfig);
    }
    */

    //TODO
    /*
    if (Utility.isMobile()) {
      return MobileVideoControls(state, videoConfig);
    }
    */

    return DesktopVideoControls(state, videoConfig);
  }
}
