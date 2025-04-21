import 'package:ani_video_player/utils/keys.dart';
import 'package:ani_video_player/utils/utility.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VideoButton extends StatefulWidget {
  final IconData? iconData;
  final String? label;
  final Function() onPressed;
  final Function(bool value)? onFocusChange;
  final Function()? onPressBack;
  final Color color;
  final bool enable;

  const VideoButton({
    super.key,
    this.iconData,
    this.label,
    required this.onPressed,
    this.onFocusChange,
    this.onPressBack,
    this.color = Colors.white,
    this.enable = true,
  });

  @override
  State<VideoButton> createState() => _VideoButtonState();
}

class _VideoButtonState extends State<VideoButton> {
  bool _focus = false;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    double iconSize = height * (Utility.isMobile() ? 0.056 : 0.04);
    double titleSize = height * (Utility.isMobile() ? 0.035 : 0.025);

    if (iconSize > 35) {
      iconSize = 35;
    }

    if (titleSize > 20) {
      titleSize = 20;
    }

    return GestureDetector(
      onTap: () {
        if (widget.enable) widget.onPressed();
      },
      child: widget.enable
          ? MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Focus(
                onFocusChange: (value) {
                  if (widget.onFocusChange != null) {
                    widget.onFocusChange!(value);
                  }

                  setState(() => _focus = value);
                },
                onKeyEvent: (node, event) {
                  final key = event.logicalKey.keyLabel;
                  if (key == Keys.keyBack && widget.onPressBack != null) {
                    if (event is KeyUpEvent) widget.onPressBack!();

                    return KeyEventResult.handled;
                  }

                  if (event is! KeyUpEvent) return KeyEventResult.ignored;

                  if (key == Keys.keyEnter || key == Keys.keyCenter) {
                    if (widget.enable) widget.onPressed();
                  }

                  return KeyEventResult.ignored;
                },
                child: Stack(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 90),
                      padding: EdgeInsets.only(
                        top: widget.iconData == null ? 7 : 4,
                        bottom: widget.iconData == null ? 7 : 4,
                        left: widget.iconData == null ? 7 : 4,
                        right: widget.label != null && _focus ? 7 : 4,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          width: 1,
                          color: _focus ? Colors.white : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          if (widget.iconData != null)
                            Icon(
                              widget.iconData,
                              size: iconSize,
                              color: widget.color,
                            ),
                          if (widget.iconData != null && widget.label != null)
                            const SizedBox(width: 6),
                          if (widget.iconData == null || _focus)
                            Text(
                              widget.label ?? "",
                              style: TextStyle(
                                fontSize: titleSize,
                                color: widget.color,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Row(
              children: [
                if (widget.iconData != null)
                  Icon(
                    widget.iconData,
                    size: iconSize,
                    color: Colors.grey.withValues(alpha: 0.5),
                  ),
                if (widget.iconData == null || widget.label != null)
                  Text(
                    widget.label!,
                    style: TextStyle(
                      color: Colors.grey.withValues(alpha: 0.5),
                      fontSize: titleSize,
                    ),
                  )
              ],
            ),
    );
  }
}
