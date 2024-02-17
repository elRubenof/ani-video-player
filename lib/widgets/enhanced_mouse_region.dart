import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:win32/win32.dart';
import 'package:win32/win32.dart' as win32;
import 'dart:ffi';
import 'package:ffi/ffi.dart';

class EnhancedMouseRegion extends StatefulWidget {
  final Function(PointerEnterEvent)? onEnter;
  final Function(PointerExitEvent)? onExit;
  final Function(PointerHoverEvent)? onHover;
  final MouseCursor cursor;
  final bool opaque;
  final HitTestBehavior? hitTestBehavior;
  final Widget? child;

  const EnhancedMouseRegion({
    super.key,
    this.onEnter,
    this.onExit,
    this.onHover,
    this.cursor = MouseCursor.defer,
    this.opaque = true,
    this.hitTestBehavior,
    this.child,
  });

  @override
  State<EnhancedMouseRegion> createState() => _EnhancedMouseRegionState();
}

class _EnhancedMouseRegionState extends State<EnhancedMouseRegion> {
  MouseCursor? lastCursor;

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows && lastCursor != widget.cursor) {
      Timer(const Duration(milliseconds: 100), () {
        Pointer<POINT> point = malloc();
        win32.GetCursorPos(point);
        win32.SetCursorPos(point.ref.x, point.ref.y);
        free(point);
      });
    }
    lastCursor = widget.cursor;

    return MouseRegion(
      onEnter: widget.onEnter,
      onExit: widget.onExit,
      onHover: widget.onHover,
      cursor: widget.cursor,
      opaque: widget.opaque,
      hitTestBehavior: widget.hitTestBehavior,
      child: widget.child,
    );
  }
}
