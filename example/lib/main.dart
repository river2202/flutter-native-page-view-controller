import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:native_page_view_controller/native_page_view_controller.dart';

import 'FlutterPageView.dart';

void main() => runApp(NativePageViewController.getInitialWidget(SimplyPageView.builder) ?? MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  String _platformVersion = 'Hello world!';

  @override
  void initState() {
    super.initState();
  }

  Future<void> _launchNativePageView() async {
    NativePageViewController.show(5, (pageIndex) {
      return "Page Content --- $pageIndex";
    }, pageRect: _MyAppState.getPageRect());
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


  static Size getScreenSize() {
    final Size size = window.physicalSize;
    final devicePixelRatio = window.devicePixelRatio;
    final double screenWidth = size.width / devicePixelRatio;
    final double screenHeight = size.height / devicePixelRatio;

    return Size(screenWidth, screenHeight);
  }


  static Size getTargetSize() {
    final Size screenSize = getScreenSize();
    final double targetRatio = 2048.0 / 2836.0;

    if (screenSize.aspectRatio < targetRatio) {
      return Size(screenSize.width, screenSize.height*targetRatio);
    } else {
      return Size(screenSize.width/targetRatio, screenSize.height);
    }
  }

  static Rect getPageRect() {
    final Size screenSize = getScreenSize();
    final Size targetSize = getTargetSize();

    print("screenSize=$screenSize, targetSize=$targetSize");
    final rect = Rect.fromLTWH(
        (screenSize.width - targetSize.width)/2,
        (screenSize.height - targetSize.height)/2,
        targetSize.width,
        targetSize.height
    );

    print("pageRect=$rect");

    return rect;

  }
}
