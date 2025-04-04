import 'package:flutter/material.dart';

class VideoConfiguration {
  final VideoDetails details;
  final VideoControls controls;
  final Map<String, String>? httpHeaders;

  const VideoConfiguration({
    //Mobile Video Controls
    this.details = const VideoDetails(),
    this.controls = const VideoControls(),
    this.httpHeaders,
  });
}

class VideoDetails {
  final String? title;
  final BoxFit fit;
  final double? aspectRatio;

  /// Enable if you want to avoid device to go to sleep while video is playing
  final bool wakelock;

  const VideoDetails({
    this.title,
    this.fit = BoxFit.contain,
    this.aspectRatio,
    this.wakelock = true,
  });
}

class VideoControls {
  /// Style of player controls to be shown over the video
  final Platform platform;

  /// Show an icon button on the top left corner to go to previous screen
  final bool showBackButton;

  /// Show an icon button on the bottom right corner to enable/disable fullscreen
  final bool showFullScreenButton;
  final bool showNextButton;
  final Function? onNextButtonPressed;

  /// Aditional widget on the bottom right corner
  final Widget? extra;

  const VideoControls({
    this.platform = Platform.auto,
    this.showBackButton = true,
    this.showFullScreenButton = true,
    this.showNextButton = true,
    this.onNextButtonPressed,
    this.extra,
  });
}

enum Platform { auto, none, mobile, tv, desktop }
