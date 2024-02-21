import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class Utility {
  static bool _isTV = false;

  static bool isMobile() {
    return Platform.isAndroid || Platform.isIOS;
  }

  static bool isDesktop() {
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
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
}
