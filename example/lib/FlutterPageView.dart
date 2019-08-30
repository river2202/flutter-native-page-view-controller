import 'package:flutter/material.dart';

typedef CloseCallback = void Function(BuildContext);

class FlutterPageView extends StatelessWidget {

  _close(BuildContext context) {
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      children: <Widget>[
        SimplyPageView(0, _close),
        SimplyPageView(1, _close),
        Container(
          color: Colors.deepPurple,
        ),
        Container(
          color: Colors.pink,
        ),
      ],
    );
  }
}

class SimplyPageView extends StatelessWidget {

  final CloseCallback close;
  final int index;

  SimplyPageView(this.index, this.close);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter page $index')),
      body: Center(child: Text("Page $index")),
      floatingActionButton: FloatingActionButton(
          onPressed: () => close(context),
          tooltip: 'close',
          child: const Icon(Icons.close),
        ),
    );
  }
}