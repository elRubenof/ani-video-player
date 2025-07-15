import 'package:ani_video_player/ani_controller.dart';
import 'package:ani_video_player/ani_video_player.dart';
import 'package:flutter/material.dart';

class VideoScreen extends StatefulWidget {
  final AniController controller;

  const VideoScreen({super.key, required this.controller});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AniVideo(controller: widget.controller),
      ),
    );
  }
}
