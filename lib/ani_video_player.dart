library ani_video_player;

import 'dart:io';

import 'package:ani_video_player/ani_controller.dart';
import 'package:ani_video_player/controls/mobile_video_player_controls.dart';
import 'package:ani_video_player/controls/tv_video_player_controls.dart';
import 'package:ani_video_player/utils/utility.dart';
import 'package:ani_video_player/video_configuration.dart';
import 'package:ani_video_player/widgets/video_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class AniVideo extends StatefulWidget {
  final AniController controller;

  const AniVideo({super.key, required this.controller});

  static Future<void> ensureInitialized() async {
    await Utility.checkTV();
  }

  static Future<void> launchVideoFullScreen(
    BuildContext context,
    AniController controller, {
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
        builder: (context) => VideoScreen(controller: controller),
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
  bool _init = false;
  late AniController controller;

  @override
  void initState() {
    super.initState();

    controller = widget.controller;
    if (controller.videoConfiguration.details.wakelock) {
      WakelockPlus.enable();
    }

    initVideo();
  }

  void initVideo() {
    final videoConfig = controller.videoConfiguration;

    switch (controller.videoConfiguration.source) {
      case Source.network:
        controller.player = VideoPlayerController.networkUrl(
          Uri.parse(controller.videoConfiguration.url),
          httpHeaders: videoConfig.httpHeaders,
        );
        break;

      case Source.file:
        controller.player = VideoPlayerController.file(
          File(videoConfig.url),
        );
        break;

      case Source.asset:
        controller.player = VideoPlayerController.asset(
          videoConfig.url,
        );
        break;
    }

    final player = controller.player!;
    player.initialize().then((_) {
      setState(() {});
      player.play();

      if (videoConfig.controls.platform == Platform.mobile ||
          (videoConfig.controls.platform == Platform.auto &&
              Utility.isMobile())) {
        //TODO SCAN CHROMECAST
      }
    });

    player.addListener(() {
      if (videoConfig.onComplete != null && player.value.isCompleted) {
        videoConfig.onComplete!(controller);
      }

      if (videoConfig.onBuffering != null) {
        videoConfig.onBuffering!(player.value.isBuffering, controller);
      }

      if (!player.value.isInitialized) {
        if (_init) {
          _init = false;
          initVideo();
        }
      }

      if (player.value.isInitialized && player.value.isPlaying && !_init) {
        _init = true;
        player.seekTo(videoConfig.details.start);
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: ExcludeFocus(
            child: controller.player!.value.isInitialized
                ? AspectRatio(
                    aspectRatio: controller.player!.value.aspectRatio,
                    child: VideoPlayer(controller.player!),
                  )
                : Container(),
          ),
        ),
        getControls(),
      ],
    );
  }

  Widget getControls() {
    switch (controller.videoConfiguration.controls.platform) {
      case Platform.auto:
        if (Utility.isTV()) {
          return TvVideoControls(controller: controller);
        }

        return MobileVideoControls(controller: controller);

      case Platform.tv:
        return TvVideoControls(controller: controller);

      default:
        return MobileVideoControls(controller: controller);
    }
  }
}
