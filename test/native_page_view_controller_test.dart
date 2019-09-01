import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_page_view_controller/native_page_view_controller.dart';

void main() {
  const MethodChannel channel = MethodChannel(NativePageViewController.channelName);

  String methodCallString;

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      methodCallString = methodCall.toString();
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('show 2 pages', () async {
    NativePageViewController.show(2, (pageIndex) { return "Page content $pageIndex"; } );
    expect(methodCallString, 'MethodCall(show, [2, flutter_page_route, true])');
  });

  test('hide', () async {
    NativePageViewController.hide();
    expect(methodCallString, 'MethodCall(hide, null)');
  });

  test('parse initialRouterName', () {
    const String pageRoutName = NativePageViewController.pageRouteName;

    var data = [
      ["/", null],
      ["/aaaa", null],
      ["/bbbbb", null],
      ["/bbbbb/$pageRoutName", null],
      ["/bbbbb/$pageRoutName?1", null],
      ["$pageRoutName", 0],
      ["$pageRoutName?1", 1],
      ["$pageRoutName?2", 2],
      ["$pageRoutName?3", 3],
    ];

    data.forEach((items) {
      var routeString = items[0];
      var expectPageIndex = items[1];

      int pageIndex = NativePageViewController.getPageIndex(routeString);

      print("$routeString expect $expectPageIndex, get: $pageIndex");
      expect(pageIndex, expectPageIndex);
    });
  });
}
