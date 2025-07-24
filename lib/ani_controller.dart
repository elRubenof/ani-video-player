import 'dart:async';

import 'package:ani_video_player/utils/utility.dart';
import 'package:ani_video_player/video_configuration.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class AniController {
  bool _disposed = false;
  bool _forceBuffering = false;

  final StreamController<bool> _forceBufferingController =
      StreamController<bool>.broadcast();

  Stream<bool> get forceBufferingStream => _forceBufferingController.stream;

  VideoPlayerController? player;
  VideoConfiguration videoConfiguration;

  AniController(this.videoConfiguration);

  Future<void> dispose() async {
    if (videoConfiguration.details.wakelock) WakelockPlus.disable();

    if (player != null && player!.value.isInitialized) {
      await player!.pause();
      await player!.dispose();
    }

    _disposed = true;
  }

  Future<void> play() async {
    if (videoConfiguration.details.wakelock) WakelockPlus.enable();
    await player!.play();
  }

  Future<void> pause() async {
    if (videoConfiguration.details.wakelock) WakelockPlus.disable();
    await player!.pause();
  }

  Future<void> playOrPause() async =>
      player!.value.isPlaying ? await pause() : await play();

  Future<void> seek(Duration duration) async {
    await player!.seekTo(
      Utility.clampDuration(duration, Duration.zero, this.duration),
    );
  }

  Duration get position => player!.value.position;
  Duration get duration => player!.value.duration;

  bool get disposed => _disposed;

  bool isBuffering() => player!.value.isBuffering || _forceBuffering;
  void setForceBuffering(bool value) {
    if (_forceBuffering != value) {
      _forceBuffering = value;
      _forceBufferingController.add(value);
    }
  }

  Future<void> setVideo(String url, {VideoConfiguration? videoConfig}) async {
    if (videoConfiguration.details.wakelock) WakelockPlus.enable();

    if (videoConfig != null) {
      videoConfiguration = videoConfig;
    } else {
      videoConfig = videoConfiguration;
    }

    videoConfiguration.url = url;

    player!.dispose();
    player!.value = VideoPlayerValue(duration: duration);
  }
}
