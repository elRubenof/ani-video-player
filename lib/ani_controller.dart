import 'dart:async';

import 'package:ani_video_player/utils/utility.dart';
import 'package:ani_video_player/video_configuration.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class AniController {
  bool _disposed = false;
  bool _forceBuffering = false;

  final StreamController<bool> _forceBufferingController =
      StreamController<bool>.broadcast();

  Stream<bool> get forceBufferingStream => _forceBufferingController.stream;

  VlcPlayerController? player;
  VideoConfiguration videoConfiguration;

  AniController(this.videoConfiguration);

  Future<void> dispose() async {
    if (player!.value.isInitialized) {
      await player!.stop();
      await player!.stopRendererScanning();
    }

    await player!.dispose();
    _disposed = true;
  }

  Future<void> play() async => await player!.play();
  Future<void> pause() async => await player!.pause();
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
    if (videoConfig != null) {
      videoConfiguration = videoConfig;
    } else {
      videoConfig = videoConfiguration;
    }

    videoConfiguration.url = url;
    player!.value = VlcPlayerValue(duration: duration);
  }
}
