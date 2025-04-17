library ani_video_player;

import 'package:ani_video_player/ani_controller.dart';
import 'package:ani_video_player/controls/desktop_video_player_controls.dart';
import 'package:ani_video_player/controls/mobile_video_player_controls.dart';
import 'package:ani_video_player/utils/utility.dart';
import 'package:ani_video_player/video_configuration.dart';
import 'package:ani_video_player/widgets/video_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class AniVideo extends StatefulWidget {
  final String url;
  final AniController? controller;

  const AniVideo({
    super.key,
    required this.url,
    this.controller,
  });

  static Future<void> ensureInitialized() async {
    MediaKit.ensureInitialized();
    await Utility.checkTV();
  }

  static Future<void> launchVideoFullScreen(
    BuildContext context,
    String url, {
    AniController? controller,
    bool hideDeviceUI = true,
    bool changeOrientation = true,
  }) async {
    late Orientation oldOrientation;
    if (Utility.isMobile()) {
      oldOrientation = MediaQuery.of(context).orientation;

      if (changeOrientation) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
      }

      if (hideDeviceUI) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      }
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoScreen(
          url: url,
          controller: controller,
        ),
      ),
    );

    if (Utility.isMobile()) {
      if (changeOrientation && oldOrientation == Orientation.portrait) {
        SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      }

      if (hideDeviceUI) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
    }
  }

  @override
  State<AniVideo> createState() => _AniVideoState();
}

class _AniVideoState extends State<AniVideo> {
  late AniController controller;
  @override
  void initState() {
    super.initState();

    controller = widget.controller ?? AniController();

    final player = controller.player;
    final videoConfig = controller.videoConfiguration;

    player.open(
      Media(widget.url, httpHeaders: videoConfig.httpHeaders),
    );

    if (videoConfig.onComplete != null) {
      player.stream.completed.listen((value) {
        if (value) videoConfig.onComplete!(controller);
      });
    }

    if (videoConfig.onBuffering != null) {
      player.stream.buffering.listen(
        (value) {
          videoConfig.onBuffering!(value, controller);
        },
      );
    }
  }

  @override
  void dispose() {
    controller.player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Video(
        controller: VideoController(controller.player),
        controls: (state) => getControls(),
        fit: controller.videoConfiguration.details.fit,
        aspectRatio: controller.videoConfiguration.details.aspectRatio,
        wakelock: controller.videoConfiguration.details.wakelock,
      ),
    );
  }

  Widget getControls() {
    switch (controller.videoConfiguration.controls.platform) {
      case Platform.auto:
        if (Utility.isDesktop()) {
          return DesktopVideoControls(controller);
        }

        if (Utility.isTV()) {
          //return TVVideoControls(state, videoConfig);
        }

        return MobileVideoControls(controller: controller);

      case Platform.desktop:
        return DesktopVideoControls(controller);

      case Platform.tv:
      //return TVVideoControls(state, videoConfig);

      default:
        return MobileVideoControls(controller: controller);
    }
  }
}
