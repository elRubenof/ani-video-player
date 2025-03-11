import 'package:flutter/material.dart';

class VideoConfiguration {
  Widget? titleWidget;
  bool showNextButton;
  Function? onNextButtonPressed;
  //Video
  BoxFit fit;
  double? aspectRatio;
  bool wakelock;
  //Connectivity
  bool enableCast;
  //Video Controls
  bool showBackButton;
  bool showFullScreenButton;
  Widget? extra;
  //Mobile Video Controls
  bool showFastPlaybackButtons;
  bool enableDoubleTapSeek;

  VideoConfiguration({
    this.titleWidget,
    this.showNextButton = false,
    this.onNextButtonPressed,
    //Video
    this.fit = BoxFit.contain,
    this.aspectRatio,
    this.wakelock = true,
    //Connectivity
    this.enableCast = true,
    //Video Controls
    this.showBackButton = true,
    this.showFullScreenButton = true,
    this.extra,
    //Mobile Video Controls
    this.showFastPlaybackButtons = true,
    this.enableDoubleTapSeek = true,
  });
}
