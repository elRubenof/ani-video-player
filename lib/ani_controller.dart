import 'package:ani_video_player/video_configuration.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/extensions/duration.dart';

class AniController {
  bool _disposed = false;
  Player player = Player();
  VideoConfiguration videoConfiguration;

  AniController({VideoConfiguration? videoConfiguration})
      : videoConfiguration = videoConfiguration ?? VideoConfiguration();

  Future<void> dispose() async {
    await player.dispose();
    _disposed = true;
  }

  Future<void> play() async => await player.play();
  Future<void> pause() async => await player.pause();
  Future<void> playOrPause() async => await player.playOrPause();

  Future<void> seek(Duration duration) async {
    await player.seek(
      duration.clamp(Duration.zero, this.duration),
    );
  }

  Duration get position => player.state.position;
  Duration get duration => player.state.duration;

  bool get disposed => _disposed;

  bool isBuffering() => player.state.buffering;

  Future<void> setVideo(String url, {VideoConfiguration? videoConfig}) async {
    if (videoConfig != null) {
      videoConfiguration = videoConfig;
    } else {
      videoConfig = videoConfiguration;
    }

    await player.open(
      Media(
        url,
        start: videoConfig.details.start,
        httpHeaders: videoConfig.httpHeaders,
      ),
    );
  }
}
