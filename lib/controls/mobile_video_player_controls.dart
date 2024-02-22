// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'package:ani_video_player/video_configuration.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'package:media_kit_video/media_kit_video_controls/src/controls/methods/video_state.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/extensions/duration.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/widgets/video_controls_theme_data_injector.dart';

VideoConfiguration _videoConfig = VideoConfiguration();

Widget MobileVideoControls(VideoState state, VideoConfiguration videoConfig) {
  _videoConfig = videoConfig;

  return const VideoControlsThemeDataInjector(
    child: _MaterialVideoControls(),
  );
}

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

class ExitButton extends StatelessWidget {
  const ExitButton({super.key});

  @override
  Widget build(BuildContext context) {
    if (!_videoConfig.showBackButton) return Container();

    return CupertinoButton(
      onPressed: () => Navigator.pop(context),
      child: const Icon(
        Icons.arrow_back_ios_rounded,
        color: Colors.white,
      ),
    );
  }
}

class Title extends StatelessWidget {
  const Title({super.key});

  @override
  Widget build(BuildContext context) {
    return _videoConfig.titleWidget ?? Container();
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
class _MaterialVideoControls extends StatefulWidget {
  const _MaterialVideoControls();

  @override
  State<_MaterialVideoControls> createState() => _MaterialVideoControlsState();
}

/// {@macro material_video_controls}
class _MaterialVideoControlsState extends State<_MaterialVideoControls> {
  late bool mount = false;
  late bool visible = false;

  Timer? _timer;

  late /* private */ var playlist = controller(context).player.state.playlist;
  late bool buffering = controller(context).player.state.buffering;

  bool _mountSeekBackwardButton = false;
  bool _mountSeekForwardButton = false;
  bool _hideSeekBackwardButton = false;
  bool _hideSeekForwardButton = false;

  final ValueNotifier<Duration> _seekBarDeltaValueNotifier =
      ValueNotifier<Duration>(Duration.zero);

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
          controller(context).player.stream.playlist.listen(
            (event) {
              setState(() {
                playlist = event;
              });
            },
          ),
          controller(context).player.stream.buffering.listen(
            (event) {
              setState(() {
                buffering = event;
              });
            },
          ),
        ],
      );

      _timer = Timer(
        _theme(context).controlsHoverDuration,
        () {
          if (mounted) {
            setState(() {
              visible = false;
            });
          }
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
    if (!visible) {
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
                    Positioned.fill(
                      left: 16.0,
                      top: 16.0,
                      right: 16.0,
                      bottom: 16.0,
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: onTap,
                              onDoubleTap:
                                  !mount ? onDoubleTapSeekBackward : () {},
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
                    ),
                    if (mount)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (_videoConfig.showBackButton)
                                Container(
                                  alignment: Alignment.centerLeft,
                                  height: _theme(context).buttonBarHeight,
                                  child: Transform.translate(
                                    offset: const Offset(-20, 0),
                                    child: const ExitButton(),
                                  ),
                                ),
                              Row(
                                children: [
                                  if (_videoConfig.showChromecastButton)
                                    //TODO
                                    Container(),
                                ],
                              ),
                            ],
                          ),
                          // Only display [primaryButtonBar] if [buffering] is false.
                          Expanded(
                            child: AnimatedOpacity(
                              curve: Curves.easeInOut,
                              opacity: buffering ? 0.0 : 1.0,
                              duration:
                                  _theme(context).controlsTransitionDuration,
                              child: const Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ReplayButton(),
                                    MaterialPlayOrPauseButton(),
                                    ForwardButton(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              const Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Title(),
                                  DurationIndicator(),
                                ],
                              ),
                              MaterialSeekBar(
                                onSeekStart: () {
                                  _timer?.cancel();
                                },
                                onSeekEnd: () {
                                  _timer = Timer(
                                    _theme(context).controlsHoverDuration,
                                    () {
                                      if (mounted) {
                                        setState(() => visible = false);
                                      }
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              // Double-Tap Seek Seek-Bar:
              if (!mount)
                if (_mountSeekBackwardButton || _mountSeekForwardButton)
                  Column(
                    children: [
                      const Spacer(),
                      Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          MaterialSeekBar(
                            delta: _seekBarDeltaValueNotifier,
                          ),
                          Container(
                            height: _theme(context).buttonBarHeight,
                            margin: _theme(context).bottomButtonBarMargin,
                          ),
                        ],
                      ),
                    ],
                  ),
              // Buffering Indicator.
              IgnorePointer(
                child: Padding(
                  padding:
                      // Add padding in fullscreen!
                      isFullscreen(context)
                          ? MediaQuery.of(context).padding
                          : EdgeInsets.zero,
                  child: Column(
                    children: [
                      Container(
                        height: _theme(context).buttonBarHeight,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      Expanded(
                        child: Center(
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              begin: 0.0,
                              end: buffering ? 1.0 : 0.0,
                            ),
                            duration:
                                _theme(context).controlsTransitionDuration,
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
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: _theme(context).buttonBarHeight,
                        margin: _theme(context).bottomButtonBarMargin,
                      ),
                    ],
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
                                      var result = controller(context)
                                              .player
                                              .state
                                              .position -
                                          value;
                                      result = result.clamp(
                                        Duration.zero,
                                        controller(context)
                                            .player
                                            .state
                                            .duration,
                                      );
                                      controller(context).player.seek(result);
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
                                      var result = controller(context)
                                              .player
                                              .state
                                              .position +
                                          value;
                                      result = result.clamp(
                                        Duration.zero,
                                        controller(context)
                                            .player
                                            .state
                                            .duration,
                                      );
                                      controller(context).player.seek(result);
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

  const MaterialSeekBar({
    Key? key,
    this.delta,
    this.onSeekStart,
    this.onSeekEnd,
  }) : super(key: key);

  @override
  MaterialSeekBarState createState() => MaterialSeekBarState();
}

class MaterialSeekBarState extends State<MaterialSeekBar> {
  bool tapped = false;
  double slider = 0.0;

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

  void onPointerMove(PointerMoveEvent e, BoxConstraints constraints) {
    final percent = e.localPosition.dx / constraints.maxWidth;
    setState(() {
      tapped = true;
      slider = percent.clamp(0.0, 1.0);
    });
  }

  void onPointerDown() {
    widget.onSeekStart?.call();
    setState(() {
      tapped = true;
    });
  }

  void onPointerUp() {
    widget.onSeekEnd?.call();
    setState(() {
      tapped = false;
    });
    controller(context).player.seek(duration * slider);
    setState(() {
      // Explicitly set the position to prevent the slider from jumping.
      position = duration * slider;
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
    });
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
                        Container(
                          width: constraints.maxWidth,
                          height: 2.4,
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
                              Container(
                                width: tapped
                                    ? constraints.maxWidth * slider
                                    : constraints.maxWidth * positionPercent,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          left: tapped
                              ? (constraints.maxWidth - 12.8 / 2) * slider
                              : (constraints.maxWidth - 12.8 / 2) *
                                  positionPercent,
                          bottom: -1.0 * 12.8 / 2 + 2.4 / 2,
                          child: Container(
                            width: 12.8 / 3,
                            height: 12.8,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                12.8 / 3,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _videoConfig.extra ?? Container(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_videoConfig.showNextButton)
                      Container(
                        height: 24,
                        margin: const EdgeInsets.only(bottom: 10),
                        child: CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: _videoConfig.onNextButtonPressed != null
                              ? () => _videoConfig.onNextButtonPressed!()
                              : () {},
                          child: Icon(
                            Icons.skip_next_rounded,
                            color: Colors.white.withOpacity(
                              _videoConfig.onNextButtonPressed != null
                                  ? 1
                                  : 0.3,
                            ),
                          ),
                        ),
                      ),
                    const MaterialFullscreenButton(),
                  ],
                )
              ],
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
  const MaterialPlayOrPauseButton({super.key});

  @override
  MaterialPlayOrPauseButtonState createState() =>
      MaterialPlayOrPauseButtonState();
}

class MaterialPlayOrPauseButtonState extends State<MaterialPlayOrPauseButton>
    with SingleTickerProviderStateMixin {
  bool playing = true;

  StreamSubscription<bool>? subscription;

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    subscription ??= controller(context).player.stream.playing.listen((event) {
      setState(() => playing = event);
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: controller(context).player.playOrPause,
      child: Icon(
        playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
        color: Colors.white,
        size: MediaQuery.of(context).size.width * 0.06,
      ),
    );
  }
}

// BUTTON: SKIP NEXT

/// Material design skip next button.
class ForwardButton extends StatelessWidget {
  const ForwardButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!_videoConfig.showFastPlaybackButtons) return Container();

    return Container(
      margin: const EdgeInsets.only(left: 30),
      child: CupertinoButton(
        onPressed: controller(context).player.next,
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
class ReplayButton extends StatelessWidget {
  const ReplayButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!_videoConfig.showFastPlaybackButtons) return Container();

    return Container(
      margin: const EdgeInsets.only(right: 30),
      child: CupertinoButton(
        onPressed: controller(context).player.previous,
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
    if (!_videoConfig.showFullScreenButton) return Container();

    return IconButton(
      onPressed: () => toggleFullscreen(context),
      icon: icon ??
          (isFullscreen(context)
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
    return Text(
      duration.label(reference: duration),
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
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: 400), () {
      widget.onSubmitted.call(value);
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
        splashColor: const Color(0x44767676),
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
                '${value.inSeconds} segundos',
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
    timer?.cancel();
    timer = Timer(const Duration(milliseconds: 400), () {
      widget.onSubmitted.call(value);
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
        splashColor: const Color(0x44767676),
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
