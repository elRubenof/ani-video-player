import 'package:ani_video_player/video_configuration.dart';
import 'package:media_kit/media_kit.dart';

class AniController {
  Player player = Player();
  VideoConfiguration videoConfiguration;

  AniController({VideoConfiguration? videoConfiguration})
      : videoConfiguration = videoConfiguration ?? VideoConfiguration();

  Future<void> dispose() async {
    await player.dispose();
  }

  Future<void> play() async => await player.play();
  Future<void> pause() async => await player.pause();
  Future<void> playOrPause() async => await player.playOrPause();

  Duration getPosition() => player.state.position;
  Future<void> seek(Duration duration) async => await player.seek(duration);

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
        httpHeaders: videoConfig.httpHeaders,
        start: videoConfig.details.start,
      ),
    );
  }
}
