import 'package:ani_video_player/video_configuration.dart';
import 'package:media_kit/media_kit.dart';

class AniController {
  final Player player;
  VideoConfiguration videoConfiguration;

  AniController(this.player, this.videoConfiguration);

  Future<void> dispose() async {
    await player.dispose();
  }

  Future<void> play() => player.play();
  Future<void> pause() => player.pause();
  Future<void> playOrPause() => player.playOrPause();

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
