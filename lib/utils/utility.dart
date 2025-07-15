import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class Utility {
  static bool _isTV = false;

  static bool isMobile() {
    return !_isTV && (Platform.isAndroid || Platform.isIOS);
  }

  static bool isTV() {
    return _isTV;
  }

  static Future<void> checkTV() async {
    if (Platform.isAndroid) {
      final info = await DeviceInfoPlugin().androidInfo;
      if (info.systemFeatures.contains('android.software.leanback_only')) {
        _isTV = true;
      }
    }
  }

  static Duration clampDuration(Duration duration, Duration min, Duration max) {
    if (duration < min) return min;

    if (duration > max) return max;

    return duration;
  }

  static String labelDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  static List<String> parseHttpHeaders(Map httpHeaders) {
    return httpHeaders.entries
        .map((e) =>
            "--http-${e.key.toLowerCase().replaceAll(' ', '-')}=${e.value.toLowerCase()}")
        .toList();
  }
}
