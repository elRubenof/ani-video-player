// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'package:ani_video_player/ani_controller.dart';
import 'package:ani_video_player/utils/utility.dart';
import 'package:ani_video_player/widgets/video_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

late AniController _controller;
String _secondsText = "";

MaterialVideoControlsThemeData _theme(BuildContext context) =>
    MaterialVideoControlsTheme.maybeOf(context)?.fullscreen ??
    kDefaultMaterialVideoControlsThemeDataFullscreen;

final kDefaultMaterialVideoControlsThemeData = MaterialVideoControlsThemeData();

final kDefaultMaterialVideoControlsThemeDataFullscreen =
    MaterialVideoControlsThemeData();

class MaterialVideoControlsThemeData {
  Duration controlsHoverDuration = const Duration(seconds: 3);
  Duration controlsTransitionDuration = const Duration(milliseconds: 300);

  double buttonBarHeight = 56.0;
  final bottomButtonBarMargin = const EdgeInsets.only(
    left: 16.0,
    right: 8.0,
    bottom: 42.0,
  );

  MaterialVideoControlsThemeData();
}

class ExitButton extends StatelessWidget {
  const ExitButton({super.key});

  @override
  Widget build(BuildContext context) {
    if (!_controller.videoConfiguration.controls.showBackButton) {
      return Container();
    }

    return CupertinoButton(
      onPressed: () => Navigator.pop(context),
      child: const Icon(
        Icons.arrow_back_ios_rounded,
        color: Colors.white,
      ),
    );
  }
}

// ignore: use_key_in_widget_constructors
class Title extends StatefulWidget {
  @override
  State<Title> createState() => _TitleState();
}

class _TitleState extends State<Title> {
  @override
  Widget build(BuildContext context) {
    final videoDetails = _controller.videoConfiguration.details;

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    double titleSize = height * 0.05;
    if (titleSize > 30) {
      titleSize = 30;
    }

    final style = TextStyle(
      color: Colors.white,
      fontSize: titleSize,
      fontWeight: FontWeight.bold,
      overflow: TextOverflow.ellipsis,
    );

    return Row(
      children: [
        if (videoDetails.title != null)
          Container(
            constraints: BoxConstraints(maxWidth: width * 0.5),
            child: Text(
              videoDetails.title!,
              style: style,
            ),
          ),
        if (videoDetails.extraTitle != null)
          Text(
            videoDetails.extraTitle!,
            style: style,
          )
      ],
    );
  }
}

class MaterialVideoControlsTheme extends InheritedWidget {
  final MaterialVideoControlsThemeData normal;
  final MaterialVideoControlsThemeData fullscreen;
  const MaterialVideoControlsTheme({
    super.key,
    required this.normal,
    required this.fullscreen,
    required super.child,
  });

  static MaterialVideoControlsTheme? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<MaterialVideoControlsTheme>();
  }

  static MaterialVideoControlsTheme of(BuildContext context) {
    final MaterialVideoControlsTheme? result = maybeOf(context);
    assert(
      result != null,
      'No [MaterialVideoControlsTheme] found in [context]',
    );
    return result!;
  }

  @override
  bool updateShouldNotify(MaterialVideoControlsTheme oldWidget) =>
      identical(normal, oldWidget.normal) &&
      identical(fullscreen, oldWidget.fullscreen);
}

/// {@macro material_video_controls}
class MobileVideoControls extends StatefulWidget {
  final AniController controller;
  final bool showFastPlaybackButtons;
  final bool enableDoubleTapSeek;
  final String secondsText;

  const MobileVideoControls({
    super.key,
    required this.controller,
    this.showFastPlaybackButtons = true,
    this.enableDoubleTapSeek = true,
    this.secondsText = "seconds",
  });

  @override
  State<MobileVideoControls> createState() => _MobileVideoControlsState();
}

/// {@macro material_video_controls}
class _MobileVideoControlsState extends State<MobileVideoControls> {
  late bool mount = true;
  late bool visible = true;

  Timer? _timer;

  Duration position = Duration.zero;
  Duration duration = Duration.zero;

  bool _mountSeekBackwardButton = false;
  bool _mountSeekForwardButton = false;
  bool _hideSeekBackwardButton = false;
  bool _hideSeekForwardButton = false;

  final ValueNotifier<Duration> _seekBarDeltaValueNotifier =
      ValueNotifier<Duration>(Duration.zero);

  @override
  void initState() {
    _controller = widget.controller;
    _secondsText = widget.secondsText;
    _controller.player!.addListener(listener);

    _timer = Timer(
      _theme(context).controlsHoverDuration,
      () {
        Future.delayed(Duration.zero).then((_) async {
          while (_controller.duration == Duration.zero) {
            await Future.delayed(const Duration(milliseconds: 500));
          }

          // ignore: use_build_context_synchronously
          await Future.delayed(_theme(context).controlsHoverDuration);
          if (mounted) {
            setState(() {
              visible = false;
            });
          }
        });
      },
    );

    super.initState();
  }

  void listener() {
    if (!mounted) return;

    if (_controller.player!.value.isInitialized) {
      setState(() {
        position = _controller.player!.value.position;
        duration = _controller.player!.value.duration;
      });
    }
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void onTap() {
    if (_controller.isBuffering()) return;

    if (!visible && !mount) {
      setState(() {
        mount = true;
        visible = true;
      });

      _timer?.cancel();
      _timer = Timer(_theme(context).controlsHoverDuration, () {
        if (mounted) {
          setState(() {
            visible = false;
          });
        }
      });
    } else {
      setState(() {
        visible = false;
      });

      _timer?.cancel();
    }
  }

  void show() {
    setState(() {
      mount = true;
      visible = true;
    });

    _timer?.cancel();
    _timer = Timer(_theme(context).controlsHoverDuration, () {
      if (mounted) {
        setState(() {
          visible = false;
        });
      }
    });
  }

  void onDoubleTapSeekBackward() {
    setState(() {
      _mountSeekBackwardButton = true;
    });
  }

  void onDoubleTapSeekForward() {
    setState(() {
      _mountSeekForwardButton = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Theme(
      data: Theme.of(context).copyWith(
        focusColor: const Color(0x00000000),
        hoverColor: const Color(0x00000000),
        splashColor: const Color(0x00000000),
        highlightColor: const Color(0x00000000),
      ),
      child: Focus(
        autofocus: true,
        child: Material(
          elevation: 0.0,
          borderOnForeground: false,
          animationDuration: Duration.zero,
          color: const Color(0x00000000),
          shadowColor: const Color(0x00000000),
          surfaceTintColor: const Color(0x00000000),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Controls:
              AnimatedOpacity(
                curve: Curves.easeInOut,
                opacity: visible ? 1.0 : 0.0,
                duration: _theme(context).controlsTransitionDuration,
                onEnd: () {
                  setState(() {
                    if (!visible) {
                      mount = false;
                    }
                  });
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    widget.enableDoubleTapSeek
                        ? Positioned.fill(
                            left: 16.0,
                            top: 16.0,
                            right: 16.0,
                            bottom: 16.0,
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: onTap,
                                    onDoubleTap: !mount
                                        ? onDoubleTapSeekBackward
                                        : () {},
                                    child: Container(
                                      color: const Color(0x00000000),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: onTap,
                                    onDoubleTap:
                                        !mount ? onDoubleTapSeekForward : () {},
                                    child: Container(
                                      color: const Color(0x00000000),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : GestureDetector(onTap: onTap),
                    if (mount)
                      GestureDetector(
                        onTap: onTap,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.05,
                          ),
                          color: Colors.black.withValues(alpha: 0.5),
                          child: Stack(
                            children: [
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      if (_controller.videoConfiguration
                                          .controls.showBackButton)
                                        Container(
                                          alignment: Alignment.centerLeft,
                                          height:
                                              _theme(context).buttonBarHeight,
                                          child: Transform.translate(
                                            offset: const Offset(-20, 0),
                                            child: const ExitButton(),
                                          ),
                                        ),
                                      Row(
                                        children: [
                                          //TODO CAST
                                          Container(),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Title(),
                                          DurationIndicator(duration: duration),
                                        ],
                                      ),
                                      MaterialSeekBar(
                                        position: position,
                                        duration: duration,
                                        onSeekStart: () {
                                          _timer?.cancel();
                                        },
                                        onSeekEnd: () {
                                          _timer = Timer(
                                            _theme(context)
                                                .controlsHoverDuration,
                                            () {
                                              if (mounted) {
                                                setState(
                                                  () => visible = false,
                                                );
                                              }
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              // Only display [primaryButtonBar] if [buffering] is false.
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (widget.showFastPlaybackButtons)
                                      BackwardButton(onPressed: show),
                                    AnimatedOpacity(
                                      curve: Curves.easeInOut,
                                      opacity:
                                          _controller.isBuffering() ? 0.0 : 1.0,
                                      duration: _theme(context)
                                          .controlsTransitionDuration,
                                      child: MaterialPlayOrPauseButton(
                                        playing:
                                            _controller.player!.value.isPlaying,
                                        onPressed: show,
                                      ),
                                    ),
                                    if (widget.showFastPlaybackButtons)
                                      ForwardButton(onPressed: show),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Double-Tap Seek Seek-Bar:
              if (!mount)
                if (_mountSeekBackwardButton || _mountSeekForwardButton)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.05,
                    ),
                    color: Colors.black.withValues(alpha: 0.5),
                    child: Column(
                      children: [
                        const Spacer(),
                        Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Title(),
                                    DurationIndicator(duration: duration),
                                  ],
                                ),
                                MaterialSeekBar(
                                  delta: _seekBarDeltaValueNotifier,
                                  position: position,
                                  duration: duration,
                                ),
                              ],
                            ),
                            Container(
                              height: _theme(context).buttonBarHeight,
                              margin: _theme(context).bottomButtonBarMargin,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              // Buffering Indicator.
              IgnorePointer(
                child: Center(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: 0.0,
                      end: _controller.isBuffering() ? 1.0 : 0.0,
                    ),
                    duration: _theme(context).controlsTransitionDuration,
                    builder: (context, value, child) {
                      // Only mount the buffering indicator if the opacity is greater than 0.0.
                      // This has been done to prevent redundant resource usage in [CircularProgressIndicator].
                      if (value > 0.0) {
                        return Opacity(
                          opacity: value,
                          child: child!,
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // Double-Tap Seek Button(s):
              if (!mount)
                if (_mountSeekBackwardButton || _mountSeekForwardButton)
                  Positioned.fill(
                    child: Row(
                      children: [
                        Expanded(
                          child: _mountSeekBackwardButton
                              ? TweenAnimationBuilder<double>(
                                  tween: Tween<double>(
                                    begin: 0.0,
                                    end: _hideSeekBackwardButton ? 0.0 : 1.0,
                                  ),
                                  duration: const Duration(milliseconds: 200),
                                  builder: (context, value, child) => Opacity(
                                    opacity: value,
                                    child: child,
                                  ),
                                  onEnd: () {
                                    if (_hideSeekBackwardButton) {
                                      setState(() {
                                        _hideSeekBackwardButton = false;
                                        _mountSeekBackwardButton = false;
                                      });
                                    }
                                  },
                                  child: _BackwardSeekIndicator(
                                    onChanged: (value) {
                                      _seekBarDeltaValueNotifier.value = -value;
                                    },
                                    onSubmitted: (value) {
                                      setState(() {
                                        _hideSeekBackwardButton = true;
                                      });

                                      var result =
                                          _controller.player!.value.position -
                                              value;
                                      result = Utility.clampDuration(
                                        result,
                                        Duration.zero,
                                        _controller.player!.value.duration,
                                      );

                                      _controller.seek(result);
                                    },
                                  ),
                                )
                              : const SizedBox(),
                        ),
                        Expanded(
                          child: _mountSeekForwardButton
                              ? TweenAnimationBuilder<double>(
                                  tween: Tween<double>(
                                    begin: 0.0,
                                    end: _hideSeekForwardButton ? 0.0 : 1.0,
                                  ),
                                  duration: const Duration(milliseconds: 200),
                                  builder: (context, value, child) => Opacity(
                                    opacity: value,
                                    child: child,
                                  ),
                                  onEnd: () {
                                    if (_hideSeekForwardButton) {
                                      setState(() {
                                        _hideSeekForwardButton = false;
                                        _mountSeekForwardButton = false;
                                      });
                                    }
                                  },
                                  child: _ForwardSeekIndicator(
                                    onChanged: (value) {
                                      _seekBarDeltaValueNotifier.value = value;
                                    },
                                    onSubmitted: (value) {
                                      setState(() {
                                        _hideSeekForwardButton = true;
                                      });
                                      var result =
                                          _controller.player!.value.position +
                                              value;
                                      result = Utility.clampDuration(
                                        result,
                                        Duration.zero,
                                        _controller.player!.value.duration,
                                      );

                                      _controller.seek(result);
                                    },
                                  ),
                                )
                              : const SizedBox(),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

// SEEK BAR

/// Material design seek bar.
class MaterialSeekBar extends StatefulWidget {
  final ValueNotifier<Duration>? delta;
  final VoidCallback? onSeekStart;
  final VoidCallback? onSeekEnd;
  final Duration position;
  final Duration duration;

  const MaterialSeekBar({
    Key? key,
    this.delta,
    this.onSeekStart,
    this.onSeekEnd,
    required this.position,
    required this.duration,
  }) : super(key: key);

  @override
  MaterialSeekBarState createState() => MaterialSeekBarState();
}

class MaterialSeekBarState extends State<MaterialSeekBar> {
  bool tapped = false;
  bool playing = false;

  double slider = 0.0;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    widget.delta?.addListener(listener);
  }

  void listener() {
    setState(() {
      final delta = widget.delta?.value ?? Duration.zero;
      position = _controller.player!.value.position + delta;
    });
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void onPointerMove(PointerMoveEvent e, BoxConstraints constraints) {
    final percent = e.localPosition.dx / constraints.maxWidth;
    setState(() {
      tapped = true;
      slider = percent.clamp(0.0, 1.0);
      setState(() => position = widget.duration * slider);
    });
  }

  void onPointerDown() {
    widget.onSeekStart?.call();

    if (_controller.player!.value.isPlaying) {
      playing = true;
      _controller.player!.pause();
    }

    setState(() {
      tapped = true;
    });
  }

  void onPointerUp() {
    widget.onSeekEnd?.call();
    setState(() {
      tapped = false;
    });

    _controller.seek(widget.duration * slider).then((_) {
      if (playing) _controller.play();
      playing = false;
    });

    setState(() {
      // Explicitly set the position to prevent the slider from jumping.
      position = widget.duration * slider;
    });
  }

  void onPanStart(DragStartDetails e, BoxConstraints constraints) {
    final percent = e.localPosition.dx / constraints.maxWidth;
    setState(() {
      tapped = true;
      slider = percent.clamp(0.0, 1.0);
    });
  }

  void onPanDown(DragDownDetails e, BoxConstraints constraints) {
    final percent = e.localPosition.dx / constraints.maxWidth;
    setState(() {
      tapped = true;
      slider = percent.clamp(0.0, 1.0);
    });
  }

  void onPanUpdate(DragUpdateDetails e, BoxConstraints constraints) {
    final percent = e.localPosition.dx / constraints.maxWidth;
    setState(() {
      tapped = true;
      slider = percent.clamp(0.0, 1.0);
      setState(() => position = widget.duration * slider);
    });
  }

  /// Returns the current playback position in percentage.
  double get positionPercent {
    if (position == Duration.zero || widget.duration == Duration.zero) {
      return 0.0;
    } else {
      final value = position.inMilliseconds / widget.duration.inMilliseconds;
      return value.clamp(0.0, 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final controls = _controller.videoConfiguration.controls;

    if (!tapped) position = widget.position;

    double trackHeight = height * 0.005;
    if (trackHeight > 3) {
      trackHeight = 3;
    }

    return Container(
      clipBehavior: Clip.none,
      child: LayoutBuilder(
        builder: (context, constraints) => Column(
          children: [
            GestureDetector(
              onHorizontalDragUpdate: (_) {},
              onPanStart: (e) => onPanStart(e, constraints),
              onPanDown: (e) => onPanDown(e, constraints),
              onPanUpdate: (e) => onPanUpdate(e, constraints),
              child: Listener(
                onPointerMove: (e) => onPointerMove(e, constraints),
                onPointerDown: (e) => onPointerDown(),
                onPointerUp: (e) => onPointerUp(),
                child: Container(
                  color: Colors.transparent,
                  width: constraints.maxWidth,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.bottomCenter,
                      children: [
                        // Full bar
                        Container(
                          width: constraints.maxWidth,
                          height: trackHeight,
                          alignment: Alignment.bottomLeft,
                          color: const Color(0x3DFFFFFF),
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.bottomLeft,
                            children: [
                              Container(
                                width: constraints.maxWidth * 0,
                                color: const Color(0x3DFFFFFF),
                              ),
                            ],
                          ),
                        ),
                        // Progress bar
                        Positioned(
                          left: 0,
                          bottom: -trackHeight * 0.5,
                          child: Container(
                            height: trackHeight * 2,
                            width: constraints.maxWidth * positionPercent,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        // Position mark
                        Positioned(
                          left: constraints.maxWidth * positionPercent,
                          bottom: -trackHeight * 3.75 / 2,
                          child: Container(
                            width: 2.3,
                            height: trackHeight * 4.75,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                12.8 / 3,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: constraints.maxWidth * positionPercent - 48,
                          bottom: -1.0 * 12.8 / 2 + 2.4 / 2 - 20,
                          child: Container(
                            width: 100,
                            alignment: Alignment.center,
                            child: Text(
                              Utility.labelDuration(position),
                              style: TextStyle(
                                color: Colors.white,
                                height: 1.3,
                                fontSize:
                                    height * (Utility.isMobile() ? 0.03 : 0.02),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 15, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  controls.extra ?? Container(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      controls.extra2 ?? Container(),
                      if (controls.extra2 != null && controls.showNextButton)
                        const SizedBox(width: 15),
                      if (controls.showNextButton)
                        VideoButton(
                          enable: controls.onNextButtonPressed != null,
                          iconData: Icons.skip_next_rounded,
                          onPressed: () =>
                              controls.onNextButtonPressed!(_controller),
                        ),
                      const MaterialFullscreenButton(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// BUTTON: PLAY/PAUSE

/// A material design play/pause button.
class MaterialPlayOrPauseButton extends StatefulWidget {
  final bool playing;
  final Function? onPressed;

  const MaterialPlayOrPauseButton({
    super.key,
    required this.playing,
    this.onPressed,
  });

  @override
  MaterialPlayOrPauseButtonState createState() =>
      MaterialPlayOrPauseButtonState();
}

class MaterialPlayOrPauseButtonState extends State<MaterialPlayOrPauseButton>
    with SingleTickerProviderStateMixin {
  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: () {
        _controller.playOrPause();

        if (widget.onPressed != null) widget.onPressed!();
      },
      child: Icon(
        widget.playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
        color: Colors.white,
        size: MediaQuery.of(context).size.width * 0.06,
      ),
    );
  }
}

/// Material design skip next button.
class ForwardButton extends StatelessWidget {
  final Function? onPressed;

  const ForwardButton({Key? key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 30),
      child: CupertinoButton(
        onPressed: () {
          _controller.seek(
            _controller.player!.value.position + const Duration(seconds: 10),
          );

          if (onPressed != null) onPressed!();
        },
        child: Icon(
          Icons.forward_10_rounded,
          color: Colors.white,
          size: MediaQuery.of(context).size.width * 0.05,
        ),
      ),
    );
  }
}

// BUTTON: SKIP PREVIOUS

/// Material design skip previous button.
class BackwardButton extends StatelessWidget {
  final Function? onPressed;

  const BackwardButton({Key? key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 30),
      child: CupertinoButton(
        onPressed: () {
          _controller.seek(
            _controller.player!.value.position - const Duration(seconds: 10),
          );

          if (onPressed != null) onPressed!();
        },
        child: Icon(
          Icons.replay_10_rounded,
          color: Colors.white,
          size: MediaQuery.of(context).size.width * 0.05,
        ),
      ),
    );
  }
}

// BUTTON: FULL SCREEN

/// Material design fullscreen button.
class MaterialFullscreenButton extends StatelessWidget {
  /// Icon for [MaterialFullscreenButton].
  final Widget? icon;

  /// Overriden icon size for [MaterialFullscreenButton].
  final double? iconSize;

  /// Overriden icon color for [MaterialFullscreenButton].
  final Color? iconColor;

  const MaterialFullscreenButton({
    Key? key,
    this.icon,
    this.iconSize,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!_controller.videoConfiguration.controls.showFullScreenButton) {
      return Container();
    }

    //TODO IMPLEMENT FULLSCREEN SYSTEM
    return IconButton(
      onPressed: () {},
      icon: icon ??
          (true
              ? const Icon(Icons.fullscreen_exit)
              : const Icon(Icons.fullscreen)),
      iconSize: 24,
      color: Colors.white,
    );
  }
}

// BUTTON: CUSTOM

/// Material design custom button.
class MaterialCustomButton extends StatelessWidget {
  /// Icon for [MaterialCustomButton].
  final Widget? icon;

  /// Icon size for [MaterialCustomButton].
  final double? iconSize;

  /// Icon color for [MaterialCustomButton].
  final Color? iconColor;

  /// The callback that is called when the button is tapped or otherwise activated.
  final VoidCallback onPressed;

  const MaterialCustomButton({
    Key? key,
    this.icon,
    this.iconSize,
    this.iconColor,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: icon ?? const Icon(Icons.settings),
      padding: EdgeInsets.zero,
      iconSize: 24,
      color: Colors.white,
    );
  }
}

// POSITION INDICATOR

/// Material design position indicator.
class DurationIndicator extends StatefulWidget {
  final Duration duration;

  const DurationIndicator({super.key, required this.duration});

  @override
  DurationIndicatorState createState() => DurationIndicatorState();
}

class DurationIndicatorState extends State<DurationIndicator> {
  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      Utility.labelDuration(widget.duration),
      style: const TextStyle(
        height: 1.0,
        fontSize: 12.0,
        color: Colors.white,
      ),
    );
  }
}

class _BackwardSeekIndicator extends StatefulWidget {
  final void Function(Duration) onChanged;
  final void Function(Duration) onSubmitted;
  const _BackwardSeekIndicator({
    Key? key,
    required this.onChanged,
    required this.onSubmitted,
  }) : super(key: key);

  @override
  State<_BackwardSeekIndicator> createState() => _BackwardSeekIndicatorState();
}

class _BackwardSeekIndicatorState extends State<_BackwardSeekIndicator> {
  Duration value = const Duration(seconds: 10);

  Timer? timer;

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    timer = Timer(const Duration(milliseconds: 400), () {
      widget.onSubmitted.call(value);
    });
  }

  void increment() {
    if (timer != null && !timer!.isActive) return;
    _controller.pause();

    timer?.cancel();
    timer = Timer(const Duration(milliseconds: 400), () {
      widget.onSubmitted.call(value);
      _controller.play();
    });
    widget.onChanged.call(value);
    setState(() {
      value += const Duration(seconds: 10);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0x88767676),
            Color(0x00767676),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: InkWell(
        onTap: increment,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.fast_rewind,
                size: 24.0,
                color: Color(0xFFFFFFFF),
              ),
              const SizedBox(height: 8.0),
              Text(
                '${value.inSeconds} $_secondsText',
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Color(0xFFFFFFFF),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ForwardSeekIndicator extends StatefulWidget {
  final void Function(Duration) onChanged;
  final void Function(Duration) onSubmitted;
  const _ForwardSeekIndicator({
    Key? key,
    required this.onChanged,
    required this.onSubmitted,
  }) : super(key: key);

  @override
  State<_ForwardSeekIndicator> createState() => _ForwardSeekIndicatorState();
}

class _ForwardSeekIndicatorState extends State<_ForwardSeekIndicator> {
  Duration value = const Duration(seconds: 10);

  Timer? timer;

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    super.initState();
    timer = Timer(const Duration(milliseconds: 400), () {
      widget.onSubmitted.call(value);
    });
  }

  void increment() {
    if (timer != null && !timer!.isActive) return;
    _controller.pause();

    timer?.cancel();
    timer = Timer(const Duration(milliseconds: 400), () {
      widget.onSubmitted.call(value);
      _controller.play();
    });
    widget.onChanged.call(value);
    setState(() {
      value += const Duration(seconds: 10);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0x00767676),
            Color(0x88767676),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: InkWell(
        onTap: increment,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.fast_forward,
                size: 24.0,
                color: Color(0xFFFFFFFF),
              ),
              const SizedBox(height: 8.0),
              Text(
                '${value.inSeconds} segundos',
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
