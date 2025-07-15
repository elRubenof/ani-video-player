import 'package:ani_video_player/ani_controller.dart';
import 'package:flutter/material.dart';

class VideoConfiguration {
  String url;
  final VideoDetails details;
  final VideoControls controls;
  Map<String, String>? httpHeaders;
  final Function(AniController controller)? onComplete;
  final Function(bool value, AniController controller)? onBuffering;

  VideoConfiguration({
    required this.url,
    VideoDetails? details,
    VideoControls? controls,
    this.httpHeaders,
    this.onComplete,
    this.onBuffering,
  })  : details = details ?? VideoDetails(),
        controls = controls ?? VideoControls();
}

class VideoDetails {
  String? title;
  String? extraTitle;
  BoxFit fit;
  double? aspectRatio;
  Duration start;

  /// Enable if you want to avoid device to go to sleep while video is playing
  bool wakelock;

  VideoDetails({
    this.title,
    this.extraTitle,
    this.fit = BoxFit.contain,
    this.aspectRatio,
    this.wakelock = true,
    this.start = Duration.zero,
  });
}

class VideoControls {
  /// Style of player controls to be shown over the video
  final Platform platform;

  /// Show an icon button on the top left corner to go to previous screen
  bool showBackButton;

  /// Show an icon button on the bottom right corner to enable/disable fullscreen
  bool showFullScreenButton;
  bool showNextButton;
  String? nextButtonLabel;
  Function(AniController controller)? onNextButtonPressed;

  /// Aditional widget on the bottom left corner
  final Widget? extra;

  VideoControls({
    this.platform = Platform.auto,
    this.showBackButton = true,
    this.showFullScreenButton = true,
    this.showNextButton = true,
    this.nextButtonLabel,
    this.onNextButtonPressed,
    this.extra,
  });
}

enum Platform { auto, none, mobile, tv }
