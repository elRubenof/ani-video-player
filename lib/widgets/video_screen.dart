import 'package:ani_video_player/ani_controller.dart';
import 'package:ani_video_player/ani_video_player.dart';
import 'package:flutter/material.dart';

class VideoScreen extends StatefulWidget {
  final String url;
  final AniController? controller;

  const VideoScreen({super.key, required this.url, this.controller});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late AniController controller;

  @override
  Widget build(BuildContext context) {
    controller = widget.controller ?? AniController();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AniVideo(
          url: widget.url,
          controller: controller,
        ),
      ),
    );
  }
}
