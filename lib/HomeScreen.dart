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

  @override
  Widget build(BuildContext context) {
    print(_connectionStatus);
    return Scaffold(
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
                    initialUrl: 'https://jiji.ng',
                    javascriptMode: JavascriptMode.unrestricted,
                    onPageFinished: (finish) {
                      setState(() {
                        isLoading = false;
                      });
                    },
                  ),
                  // WebviewScaffold(url: 'https://jiji.ng',withJavascript: true,),
                  isLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : Stack(),
                ],
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

  void reloadWebView() {
    setState(() {
      isLoading = true;
    });
    _webViewController?.reload();
  }
}

// class MyConnectivity {
//   MyConnectivity._internal();

//   static final MyConnectivity _instance = MyConnectivity._internal();

//   static MyConnectivity get instance => _instance;

//   Connectivity connectivity = Connectivity();

//   StreamController controller = StreamController.broadcast();

//   Stream get myStream => controller.stream;

//   void initialise() async {
//     ConnectivityResult result = await connectivity.checkConnectivity();
//     _checkStatus(result);
//     connectivity.onConnectivityChanged.listen((result) {
//       _checkStatus(result);
//     });
//   }

//   void _checkStatus(ConnectivityResult result) async {
//     bool isOnline = false;
//     try {
//       final result = await InternetAddress.lookup('example.com');
//       if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
//         isOnline = true;
//       } else
//         isOnline = false;
//     } on SocketException catch (_) {
//       isOnline = false;
//     }
//     controller.sink.add({result: isOnline});
//   }

//   void disposeStream() => controller.close();
// }

class InternetError extends StatelessWidget {
  Future<void> funtion;

  InternetError(this.funtion);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Errors('Internet Error'),
          CupertinoButton.filled(
            onPressed: () {
              funtion;
            },
            child: Text('Retry'),
          )
        ],
      ),
    );
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
