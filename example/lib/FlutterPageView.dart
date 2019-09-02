import 'package:flutter/material.dart';
import 'package:native_page_view_controller/native_page_view_controller.dart';

typedef CloseCallback = void Function(BuildContext);
typedef LoadContent<T> = Future<T> Function(int);

class FlutterPageView extends StatelessWidget {

  _close(BuildContext context) {
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }

  Future<String> _loadContent(int pageIndex) async {
    return "Page Content $pageIndex";
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      children: <Widget>[
        SimplyPageView(0, _close, _loadContent),
        SimplyPageView(1, _close, _loadContent),
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

class SimplyPageView extends StatefulWidget {

static Widget builder(int index, ContentLoader contentLoader, NativeCallback close, NativeCallback next, NativeCallback previous) {
  return MaterialApp (
        home: SimplyPageView(index, (context) => NativePageViewController.hide(), NativePageViewController.load));
}

  final CloseCallback close;
  final LoadContent<String> load;
  final int index;

  SimplyPageView(this.index, this.close, this.load);

  @override
  _SimplyPageViewState createState() => _SimplyPageViewState();
}

class _SimplyPageViewState extends State<SimplyPageView> {

  String _pageContent;

  @override
  void initState() {
    super.initState();
    _pageContent = "Loading ...";

    widget.load(widget.index).then((content) {
      print("Page${widget.index} Loaded!");
      _pageContent = content;
      setState(() {});
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Flutter page ${widget.index}')),
      body: Center(child: Text(_pageContent)),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            widget.close(context);
          },
          tooltip: 'close',
          child: const Icon(Icons.close),
        ),
    );
  }
}