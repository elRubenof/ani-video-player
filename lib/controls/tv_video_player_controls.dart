// ignore_for_file: non_constant_identifier_names, use_build_context_synchronously

import 'dart:async';
import 'package:ani_video_player/ani_controller.dart';
import 'package:ani_video_player/utils/keys.dart';
import 'package:ani_video_player/widgets/video_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'package:media_kit_video/media_kit_video_controls/src/controls/methods/video_state.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/extensions/duration.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/widgets/video_controls_theme_data_injector.dart';

late AniController _controller;
late FocusNode _sliderFocusNode;

MaterialVideoControlsThemeData _theme(BuildContext context) =>
    FullscreenInheritedWidget.maybeOf(context) == null
        ? MaterialVideoControlsTheme.maybeOf(context)?.normal ??
            kDefaultMaterialVideoControlsThemeData
        : MaterialVideoControlsTheme.maybeOf(context)?.fullscreen ??
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

class Title extends StatefulWidget {
  const Title({super.key});

  @override
  State<Title> createState() => _TitleState();
}

class _TitleState extends State<Title> {
  final List<StreamSubscription> subscriptions = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (subscriptions.isEmpty) {
      subscriptions.addAll(
        [
          controller(context).player.stream.playlist.listen(
            (event) {
              setState(() {});
            },
          ),
        ],
      );
    }
  }

  @override
  void dispose() {
    for (final subscription in subscriptions) {
      subscription.cancel();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoDetails = _controller.videoConfiguration.details;

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    double titleSize = height * 0.04;
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
class TvVideoControls extends StatefulWidget {
  final AniController controller;
  final bool showFastPlaybackButtons;
  final bool enableDoubleTapSeek;
  final bool showCastButton;
  final String secondsText;

  const TvVideoControls({
    super.key,
    required this.controller,
    this.showFastPlaybackButtons = true,
    this.enableDoubleTapSeek = true,
    this.showCastButton = true,
    this.secondsText = "seconds",
  });

  @override
  State<TvVideoControls> createState() => _TvVideoControlsState();
}

/// {@macro material_video_controls}
class _TvVideoControlsState extends State<TvVideoControls> {
  // Indicate if controls are been shown or not considering animation duration
  bool mount = true;
  // Indicate if controls should start to be visible or not
  bool visible = true;

  Timer? _timer;

  late /* private */ var playlist = controller(context).player.state.playlist;

  final List<StreamSubscription> subscriptions = [];

  @override
  void initState() {
    _controller = widget.controller;

    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (subscriptions.isEmpty) {
      subscriptions.addAll(
        [
          controller(context).player.stream.playlist.listen(
            (event) {
              setState(() {
                playlist = event;
              });
            },
          ),
          controller(context).player.stream.buffering.listen(
            (event) {
              setState(() {});
            },
          ),
          _controller.forceBufferingStream.listen(
            (event) {
              setState(() {});
            },
          ),
        ],
      );

      _timer = Timer(
        _theme(context).controlsHoverDuration,
        () {
          Future.delayed(Duration.zero).then((_) async {
            while (_controller.duration == Duration.zero) {
              await Future.delayed(const Duration(milliseconds: 500));
            }

            await Future.delayed(_theme(context).controlsHoverDuration);
            if (mounted) {
              setState(() {
                visible = false;
              });

              _sliderFocusNode.requestFocus();
            }
          });
        },
      );
    }
  }

  @override
  void dispose() {
    for (final subscription in subscriptions) {
      subscription.cancel();
    }

    super.dispose();
  }

  void onTap() {
    if (_controller.isBuffering()) return;

    if (!visible && !mount) {
      show();
    } else {
      hide();
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

      _sliderFocusNode.requestFocus();
    });
  }

  void hide() {
    setState(() {
      visible = false;
    });

    _timer?.cancel();
    _sliderFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return VideoControlsThemeDataInjector(
      child: Theme(
        data: Theme.of(context).copyWith(
          focusColor: const Color(0x00000000),
          hoverColor: const Color(0x00000000),
          splashColor: const Color(0x00000000),
          highlightColor: const Color(0x00000000),
        ),
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
                child: Opacity(
                  opacity: mount ? 1 : 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                    color: Colors.black.withValues(alpha: 0.5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Title(),
                            DurationIndicator(),
                          ],
                        ),
                        MaterialSeekBar(
                          visible: visible,
                          show: show,
                          hide: hide,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Buffering Indicator.
              IgnorePointer(
                child: Padding(
                  padding:
                      // Add padding in fullscreen!
                      isFullscreen(context)
                          ? MediaQuery.of(context).padding
                          : EdgeInsets.zero,
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
  final bool visible;
  final Function() show;
  final Function() hide;

  const MaterialSeekBar({
    Key? key,
    this.delta,
    required this.visible,
    required this.show,
    required this.hide,
  }) : super(key: key);

  @override
  MaterialSeekBarState createState() => MaterialSeekBarState();
}

class MaterialSeekBarState extends State<MaterialSeekBar> {
  bool tapped = false;
  double slider = 0.0;

  Duration newPosition = Duration.zero;

  late bool playing = controller(context).player.state.playing;
  late Duration position = controller(context).player.state.position;
  late Duration duration = controller(context).player.state.duration;
  late Duration buffer = controller(context).player.state.buffer;

  final List<StreamSubscription> subscriptions = [];

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void listener() {
    setState(() {
      final delta = widget.delta?.value ?? Duration.zero;
      position = controller(context).player.state.position + delta;
    });
  }

  @override
  void initState() {
    _sliderFocusNode = FocusNode();

    super.initState();
    widget.delta?.addListener(listener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (subscriptions.isEmpty && widget.delta == null) {
      subscriptions.addAll(
        [
          controller(context).player.stream.playing.listen((event) {
            setState(() {
              playing = event;
            });
          }),
          controller(context).player.stream.completed.listen((event) {
            setState(() {
              position = Duration.zero;
            });
          }),
          controller(context).player.stream.position.listen((event) {
            setState(() {
              if (!tapped) {
                position = event;
              }
            });
          }),
          controller(context).player.stream.duration.listen((event) {
            setState(() {
              duration = event;
            });
          }),
          controller(context).player.stream.buffer.listen((event) {
            setState(() {
              buffer = event;
            });
          }),
        ],
      );
    }
  }

  @override
  void dispose() {
    widget.delta?.removeListener(listener);
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  /// Returns the current playback position in percentage.
  double get positionPercent {
    if (position == Duration.zero || duration == Duration.zero) {
      return 0.0;
    } else {
      final value = position.inMilliseconds / duration.inMilliseconds;
      return value.clamp(0.0, 1.0);
    }
  }

  /// Returns the current playback buffer position in percentage.
  double get bufferPercent {
    if (buffer == Duration.zero || duration == Duration.zero) {
      return 0.0;
    } else {
      final value = buffer.inMilliseconds / duration.inMilliseconds;
      return value.clamp(0.0, 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final controls = _controller.videoConfiguration.controls;

    double trackHeight = height * 0.005;
    if (trackHeight > 3) {
      trackHeight = 3;
    }

    double titleSize = MediaQuery.of(context).size.height * 0.04;
    if (titleSize > 30) {
      titleSize = 30;
    }

    return Container(
      clipBehavior: Clip.none,
      child: LayoutBuilder(
        builder: (context, constraints) => Column(
          children: [
            Focus(
              autofocus: true,
              focusNode: _sliderFocusNode,
              onKeyEvent: (node, event) {
                final key = event.logicalKey.keyLabel;

                if (key == Keys.keyBack || key == Keys.keyExit) {
                  if (event is! KeyUpEvent) return KeyEventResult.handled;

                  if (widget.visible) {
                    widget.hide();
                  } else {
                    Navigator.pop(context);
                  }

                  return KeyEventResult.handled;
                }

                widget.show();
                switch (key) {
                  case Keys.keyLeft:
                    seek(-10, event is KeyUpEvent);
                    return KeyEventResult.handled;

                  case Keys.keyRight:
                    seek(10, event is KeyUpEvent);
                    return KeyEventResult.handled;

                  case Keys.keyDown:
                    if (!widget.visible) {
                      return KeyEventResult.handled;
                    }

                  case Keys.keyEnter:
                  case Keys.keyCenter:
                  case Keys.keySpace:
                    if (event is KeyUpEvent) {
                      _controller.playOrPause();
                    }
                }

                return KeyEventResult.ignored;
              },
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
                              width: constraints.maxWidth * bufferPercent,
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
                            position.label(reference: position),
                            style: TextStyle(
                              color: Colors.white,
                              height: 1.3,
                              fontSize: titleSize * 0.6,
                            ),
                          ),
                        ),
                      ),
                    ],
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
                  if (controls.showNextButton)
                    VideoButton(
                      enable: controls.onNextButtonPressed != null,
                      label: controls.nextButtonLabel,
                      iconData: Icons.skip_next_rounded,
                      onFocusChange: (value) {
                        if (!value && _sliderFocusNode.hasFocus) return;

                        widget.show();
                      },
                      onPressed: () =>
                          controls.onNextButtonPressed!(_controller),
                      onPressBack: widget.hide,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> seek(int seconds, bool apply) async {
    if (apply) {
      if (newPosition == Duration.zero) return;

      _controller.seek(newPosition);
      newPosition = Duration.zero;

      await _controller.play();
      return;
    }

    if (newPosition == Duration.zero) {
      newPosition = _controller.position;
    }

    newPosition += Duration(seconds: seconds);

    await _controller.pause();
    setState(() => position = newPosition.clamp(Duration.zero, duration));
  }
}

// POSITION INDICATOR

/// Material design position indicator.
class DurationIndicator extends StatefulWidget {
  const DurationIndicator({super.key});

  @override
  DurationIndicatorState createState() => DurationIndicatorState();
}

class DurationIndicatorState extends State<DurationIndicator> {
  late Duration position = controller(context).player.state.position;
  late Duration duration = controller(context).player.state.duration;

  final List<StreamSubscription> subscriptions = [];

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (subscriptions.isEmpty) {
      subscriptions.addAll(
        [
          controller(context).player.stream.position.listen((event) {
            setState(() {
              position = event;
            });
          }),
          controller(context).player.stream.duration.listen((event) {
            setState(() {
              duration = event;
            });
          }),
        ],
      );
    }
  }

  @override
  void dispose() {
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double titleSize = MediaQuery.of(context).size.height * 0.04;
    if (titleSize > 30) {
      titleSize = 30;
    }

    return Text(
      duration.label(reference: duration),
      style: TextStyle(
        height: 1.0,
        fontSize: titleSize * 0.6,
        color: Colors.white,
      ),
    );
  }
}
