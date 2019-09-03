import 'dart:async';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

typedef ContentLoader<T> = T Function(int pageIndex);
typedef PageWidgetBuilder = Widget Function(int index, ContentLoader contentLoader, NativeCallback close, NativeCallback next, NativeCallback previous);
typedef NativeCallback = void Function();

enum NativePageViewControllerTransitionStyle {
  none,
  slideUp,
}

class NativePageViewController {
  static const String pageRouteName = "flutter_page_route";
  static const String channelName = "native_page_view_controller";

  static ContentLoader contentLoader;

  static MethodChannel _buildChannel() {
    MethodChannel channel = MethodChannel(channelName);
    channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'load':
          return contentLoader(call.arguments);
        default:
          throw MissingPluginException();
      }
    });
    return channel;
  }

  static MethodChannel _channel = _buildChannel();

  static void show(
      int pageCount,
      ContentLoader loader,
      {
        NativePageViewControllerTransitionStyle transitionStyle = NativePageViewControllerTransitionStyle.none,
        bool disableNativeTap = true,
        Rect pageRect
      }) async {
    contentLoader = loader;
    await _channel.invokeMethod('show', [pageCount, pageRouteName, transitionStyle.index, disableNativeTap, pageRect?.left, pageRect?.top, pageRect?.width, pageRect?.height]);
  }

  static void hide() async {
    await _channel.invokeMethod('hide');
  }

  static void next() async {
    await _channel.invokeMethod('next');
  }

  static void previous() async {
    await _channel.invokeMethod('previous');
  }

  static Future<T> load<T>(int pageIndex) async {
    return _channel.invokeMethod<T>('load', pageIndex);
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

  static Widget getInitialWidget(PageWidgetBuilder pageBuilder) {
    int pageIndex = NativePageViewController.getPageIndex(window.defaultRouteName);

    if (null != pageIndex) {
      return pageBuilder(
        pageIndex, 
        NativePageViewController.load,
        NativePageViewController.hide, 
        NativePageViewController.next, 
        NativePageViewController.previous
        );
    } else {
      return null;
    }
  }
}
