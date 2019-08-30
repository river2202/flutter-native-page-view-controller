import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:native_page_view_controller/native_page_view_controller.dart';

import 'FlutterPageView.dart';
import 'dart:ui';

void main() => runApp(_widgetForRoute(window.defaultRouteName));

_GetSimplyPageView(int index) => MaterialApp(
        home: SimplyPageView(index, (context) => NativePageViewController.close()));

Widget _widgetForRoute(String route) {
  print(route);
  switch (route) {
    case 'page1':
      return _GetSimplyPageView(1);
    case 'page2':
      return _GetSimplyPageView(2);
    case 'page3':
      return _GetSimplyPageView(3);
    default:
      return MyApp();
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // final MethodChannel _methodChannel =
  //     MethodChannel('samples.flutter.io/platform_view');

  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await NativePageViewController.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> _launchNativePageView() async {
    // await _methodChannel.invokeMethod('switchView');
    NativePageViewController.show("Page", 2);
    setState(() {});
  }

  void _launchFlutterPageView(BuildContext context) {
    Navigator.push(context, new MaterialPageRoute(builder: (context) {
      return FlutterPageView();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: const Text('Plugin example app'),
            ),
            body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Center(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                          Text('Running on: $_platformVersion\n'),
                          Padding(
                            padding: const EdgeInsets.all(18.0),
                            child:  Builder(builder: (context) => 
                            RaisedButton(
                                child: const Text('Flutter PageView'),
                                onPressed: () {
                                  _launchFlutterPageView(context);
                                  Navigator.push(context,
                                      new MaterialPageRoute(builder: (context) {
                                    return FlutterPageView();
                                  }));
                                })),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: RaisedButton(
                                child: Text('Native PageViewController'),
                                onPressed: _launchNativePageView),
                          ),
                        ])),
                  )
                ])));
  
  }
}
