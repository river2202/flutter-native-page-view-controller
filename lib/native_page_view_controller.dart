import 'dart:async';

import 'package:flutter/services.dart';

class NativePageViewController {
  static const MethodChannel _channel =
      const MethodChannel('native_page_view_controller');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
