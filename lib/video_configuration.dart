import 'package:flutter/material.dart';

class VideoConfiguration {
  String? title;
  bool showNextButton;
  Function? onNextButtonPressed;

  BoxFit fit;
  double? aspectRatio;
  bool wakelock;

  bool showBackButton;

  VideoConfiguration({
    this.title,
    this.showNextButton = false,
    this.onNextButtonPressed,
    //Video
    this.fit = BoxFit.contain,
    this.aspectRatio,
    this.wakelock = true,
    //Desktop Controls
    this.showBackButton = true,
  });
}
