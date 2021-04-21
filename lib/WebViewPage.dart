import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

final webViewKey = GlobalKey<WebViewContainerState>();

class WebViewPage extends StatefulWidget {
  @override
  WebViewPageState createState() => WebViewPageState();
}

class WebViewPageState extends State<WebViewPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [

              Container(margin: const EdgeInsets.only(top: 20),child: WebViewContainer(key: webViewKey)),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.refresh),
          onPressed: () {
            webViewKey.currentState?.reloadWebView();
          },
          ),
      ),
    );
  }
}

class WebViewContainer extends StatefulWidget {


  WebViewContainer({Key key}) : super(key: key);

  @override
  WebViewContainerState createState() => WebViewContainerState();
}

class WebViewContainerState extends State<WebViewContainer> {

  bool isLoading = true;

  WebViewController _webViewController;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebView(
          onWebViewCreated: (controller) {
            _webViewController = controller;
          },
          javascriptMode: JavascriptMode.unrestricted,
          onPageFinished: (finish) {
            setState(() {
              isLoading = false;
            });
          },
          initialUrl: "https://jiji.ng",
        ),
        isLoading ? Center(child: CircularProgressIndicator(),) : Stack(),
      ],
    );
  }

  void reloadWebView() {
    _webViewController?.reload();
  }
}