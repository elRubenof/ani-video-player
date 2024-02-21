import 'package:ani_video_player/ani_video_player.dart';
import 'package:ani_video_player/video_configuration.dart';
import 'package:flutter/material.dart';

class VideoScreen extends StatefulWidget {
  final String url;
  final VideoConfiguration? videoConfiguration;

  const VideoScreen({super.key, required this.url, this.videoConfiguration});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late VideoConfiguration videoConfig;

  @override
  Widget build(BuildContext context) {
    videoConfig = widget.videoConfiguration ?? VideoConfiguration();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AniVideo(
          url: widget.url,
          videoConfiguration: videoConfig,
        ),
      ),
    );
  }
}
