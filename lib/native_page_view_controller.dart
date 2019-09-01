import 'dart:async';

import 'package:flutter/services.dart';

class NativePageViewController {
  static const String pageRouteName = "flutter_page_route";
  static const String channelName = "native_page_view_controller";

  static const MethodChannel _channel =
      const MethodChannel(channelName);

  static void show(int pageCount, {bool disableNativeTap = true}) async {
    await _channel.invokeMethod('show', [pageCount, pageRouteName, disableNativeTap]);
  }

  static void hide() async {
    await _channel.invokeMethod('hide');
  }

  static int getPageIndex(String routeString) {

    var match = RegExp(pageRouteName + r"(?:\?(\d+))?").matchAsPrefix(routeString);

    if (null != match) {
      if (match.groupCount>0) {
        try {
          return int.parse(match.group(1));
        } catch (e) {
          return 0;
        }
      }
    }

    return null;
  }
}
