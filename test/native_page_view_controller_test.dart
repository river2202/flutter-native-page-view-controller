import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:native_page_view_controller/native_page_view_controller.dart';

void main() {
  const MethodChannel channel = MethodChannel('native_page_view_controller');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await NativePageViewController.platformVersion, '42');
  });
}
