library ani_video_player;

import 'package:ani_video_player/ani_controller.dart';
import 'package:ani_video_player/controls/mobile_video_player_controls.dart';
import 'package:ani_video_player/controls/tv_video_player_controls.dart';
import 'package:ani_video_player/utils/utility.dart';
import 'package:ani_video_player/video_configuration.dart';
import 'package:ani_video_player/widgets/video_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
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
  UniqueKey _key = UniqueKey();

  late AniController controller;

  @override
  void initState() {
    super.initState();

    controller = widget.controller;
    if (controller.videoConfiguration.details.wakelock) {
      WakelockPlus.enable();
    }
  }

  void initVideo() {
    controller.player = VlcPlayerController.network(
      controller.videoConfiguration.url,
      hwAcc: HwAcc.disabled,
      options: VlcPlayerOptions(
        http: VlcHttpOptions(
          Utility.parseHttpHeaders(
            controller.videoConfiguration.httpHeaders ?? {},
          ),
        ),
      ),
    );

    final player = controller.player!;
    final videoConfig = controller.videoConfiguration;

    final platform = videoConfig.controls.platform;
    if (platform == Platform.mobile || Utility.isMobile()) {
      player.addOnInitListener(() async {
        await player.startRendererScanning();
      });

      player.addOnRendererEventListener((type, id, name) {
        if (!kReleaseMode) {
          debugPrint('OnRendererEventListener $type $id $name');
        }
      });
    }

    player.addListener(() {
      if (videoConfig.onComplete != null &&
          player.value.isEnded &&
          player.value.duration != Duration.zero &&
          player.value.position == player.value.duration) {
        videoConfig.onComplete!(controller);
      }

      if (videoConfig.onBuffering != null) {
        videoConfig.onBuffering!(player.value.isBuffering, controller);
      }

      if (!player.value.isInitialized) {
        if (_init) {
          _init = false;
          setState(() => _key = UniqueKey());
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
    initVideo();

    return Stack(
      key: _key,
      children: [
        Center(
          child: ExcludeFocus(
            child: VlcPlayer(
              controller: controller.player!,
              aspectRatio: 16 / 9,
              placeholder: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
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
