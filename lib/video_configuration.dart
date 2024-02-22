import 'package:flutter/material.dart';

class VideoConfiguration {
  Widget? titleWidget;
  bool showNextButton;
  Function? onNextButtonPressed;

  BoxFit fit;
  double? aspectRatio;
  bool wakelock;

  bool showChromecastButton;

  bool showBackButton;
  bool showFullScreenButton;
  Widget? extra;

  bool showFastPlaybackButtons;

  VideoConfiguration({
    this.titleWidget,
    this.showNextButton = false,
    this.onNextButtonPressed,
    //Video
    this.fit = BoxFit.contain,
    this.aspectRatio,
    this.wakelock = true,
    //Connectivity
    this.showChromecastButton = true,
    //Video Controls
    this.showBackButton = true,
    this.showFullScreenButton = true,
    this.extra,
    //Mobile Video Controls
    this.showFastPlaybackButtons = true,
  });
}
