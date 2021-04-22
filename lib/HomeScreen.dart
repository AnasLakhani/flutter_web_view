import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:connectivity/connectivity.dart';

final _key = GlobalKey<HomeScreenState>();

class HomeScreen extends StatefulWidget {
  @override
  HomeScreenState createState() => new HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  bool isLoading = true;
  WebViewController _webViewController;

  String _connectionStatus = 'Unknown';
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  // Map _source = {ConnectivityResult.none: false};
  // MyConnectivity _connectivity = MyConnectivity.instance;

  // @override
  // void initState() {
  //   super.initState();
  //   initConnectivity();
  //   _connectivitySubscription =
  //       _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  // _connectivity.initialise();
  // _connectivity.myStream.listen((source) {
  // setState(() => _source = source);
  // }
  // }

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    ConnectivityResult result = ConnectivityResult.none;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  _onBackPressed(context) {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to exit an App'),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: new GestureDetector(
                  onTap: () => Navigator.of(context).pop(false),
                  child: Text("NO"),
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: new GestureDetector(
                  onTap: () => SystemNavigator.pop(),
                  child: Text("YES"),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    print(_connectionStatus);
    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
navigate(context, _webViewController,goBack: true);
        // print(_webViewController.canGoBack() == true ? "Anas" : "False");
        // _webViewController.goBack();
        return;
        // ignore: unrelated_type_equality_checks
        if (_webViewController.canGoBack() == true) {
          _webViewController.goBack();
        } else {
          _onBackPressed(context);
        }
      },
      child: Scaffold(
        floatingActionButton: Visibility(
          visible: _connectionStatus != 'ConnectivityResult.none',
          child: FloatingActionButton(
            child: Icon(Icons.refresh),
            onPressed: () {
              reloadWebView();
            },
          ),
        ),
        body: _connectionStatus == 'ConnectivityResult.none'
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Errors('Internet Error'),
                    Container(
                      height: 20,
                    ),
                    CupertinoButton.filled(
                      onPressed: () {
                        initConnectivity();
                        // _webViewController.reload();
                      },
                      child: Text('Retry'),
                    )
                  ],
                ),
              )
            : Container(
                margin: const EdgeInsets.only(
                  top: 20,
                ),
                child: Stack(
                  children: <Widget>[
                    WebView(
                      onWebViewCreated: (controller) {
                        _webViewController = controller;
                      },
                      key: _key,
                      initialUrl:
                          'https://amazon.com',
                      javascriptMode: JavascriptMode.unrestricted,
                      onProgress: (p) {
                        setState(() {
                          isLoading = !(p == 100);
                        });
                        print("Progress is " + p.toString());
                      },
                    ),
                    isLoading
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : Stack(),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.none:
        setState(() => _connectionStatus = result.toString());
        break;
      default:
        setState(() => _connectionStatus = 'Failed to get connectivity.');
        break;
    }
  }

  navigate(BuildContext context, WebViewController controller,
      {bool goBack: false}) async {
    bool canNavigate =
    goBack ? await controller.canGoBack() : await controller.canGoForward();
    if (canNavigate) {
      goBack ? controller.goBack() : controller.goForward();
    } else {
      _onBackPressed(context);
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //       content: Text("No ${goBack ? 'back' : 'forward'} history item")),
      // );
    }
  }

  void reloadWebView() {
    setState(() {
      isLoading = true;
    });
    _webViewController?.reload();
  }
}

class Errors extends StatelessWidget {
  String msg;

  Errors(this.msg);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Text(
      msg,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
    ));
  }
}
