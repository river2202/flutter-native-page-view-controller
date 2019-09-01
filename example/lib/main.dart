import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:native_page_view_controller/native_page_view_controller.dart';

import 'FlutterPageView.dart';
import 'dart:ui';

void main() => runApp(_widgetForRoute(window.defaultRouteName));

Widget _getSimplyPageView(int index) => MaterialApp (
        home: SimplyPageView(index, (context) => NativePageViewController.hide(), NativePageViewController.load));

Widget _widgetForRoute(String routeString) {
  int pageIndex = NativePageViewController.getPageIndex(routeString);

  if (null != pageIndex) {
    return _getSimplyPageView(pageIndex);
  } else {
    return MyApp();
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
  }

  Future<void> _launchNativePageView() async {
    NativePageViewController.show(5, (pageIndex) {
      return "Page Content --- $pageIndex";
    });
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
