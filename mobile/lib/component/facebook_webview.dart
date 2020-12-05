import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

// Opens ErrandShare link to Facebook login and returns a token credential.
class FacebookWebView extends StatefulWidget {
  final String selectedUrl;

  FacebookWebView({this.selectedUrl});

  @override
  _FacebookWebViewState createState() => _FacebookWebViewState();
}

class _FacebookWebViewState extends State<FacebookWebView> {
  final flutterWebviewPlugin = FlutterWebviewPlugin();

  @override
  void initState() {
    super.initState();

    flutterWebviewPlugin.onUrlChanged.listen((String url) {
      if (url.contains('#access_token')) {
        succeed(url);
      }

      if (url.contains(
          'https://www.facebook.com/connect/login_success.html?error=access_denied&error_code=200&error_description=Permissions+error&error_reason=user_denied')) {
        denied();
      }
    });
  }

  void denied() {
    Navigator.pop(context);
  }

  void succeed(String url) {
    var params = url.split('access_token=');

    var endparam = params[1].split('&');

    Navigator.pop(context, endparam[0]);
  }

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
        url: widget.selectedUrl,
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(66, 103, 178, 1),
          title: Text('Facebook login'),
        )
      );
  }
}
