import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() 
{
  runApp(MyApp());
}

class MyApp extends StatelessWidget 
{
  @override
  Widget build(BuildContext context) 
  {
    return MaterialApp(
      title: 'Title of the App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Title of the App'),
    );
  }
}

class MyHomePage extends StatefulWidget 
{
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

WebViewController controllerGlobal;

final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

Future<bool> _exitApp(BuildContext context) async 
{
  if (await controllerGlobal.canGoBack()) 
  {
    print("onwill goback");
    controllerGlobal.goBack();
  } 
  else 
  {
    _scaffoldKey.currentState.showSnackBar(const SnackBar(content: Text("You're at homepage.",
      ),
     ),
    );
    return Future.value(false);
  }
}

class _MyHomePageState extends State<MyHomePage> 
{

  Completer<WebViewController> _controller = Completer<WebViewController>();

  num position = 1;
  
  doneLoading(String A) 
  {
    setState(() 
    {
      position = 0;
    });
  }
 
  startLoading(String A)
  {
    setState(() 
    {
      position = 1;
    });
  }

  @override
  void initState() 
  {
    super.initState();
  }

  @override
  Widget build(BuildContext context) 
  {
    return WillPopScope(
        onWillPop: () => _exitApp(context),
        child: Scaffold(
        key:  _scaffoldKey,
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.title),
          actions: <Widget>
          [
            NavigationControls(_controller.future),
          ],
        ),
        body: IndexedStack(
            index: position,
            children: <Widget>
            [
              WebView(
                initialUrl: 'url goes here.',
                javascriptMode: JavascriptMode.unrestricted,
                onPageFinished: doneLoading,
                onPageStarted: startLoading,
                initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
                onWebViewCreated: (WebViewController webViewController) 
                {
                  _controller.complete(webViewController);
                },
              ),
              Container(
                color: Colors.white,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),  
          ]
        )
      ),
    );
  }
}

class NavigationControls extends StatelessWidget 
{
  const NavigationControls(this._webViewControllerFuture): assert(_webViewControllerFuture != null);

  final Future<WebViewController> _webViewControllerFuture;

  @override
  Widget build(BuildContext context) 
  {

    return FutureBuilder<WebViewController>(

      future: _webViewControllerFuture,

      builder:(BuildContext context, AsyncSnapshot<WebViewController> snapshot) 
      {

        final bool webViewReady = snapshot.connectionState == ConnectionState.done;

        final WebViewController controller = snapshot.data;

        controllerGlobal = controller;

        return Row(
          
          children: <Widget>
          [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: !webViewReady ? null: () async 
              {
                if (await controller.canGoBack()) 
                {
                  controller.goBack();
                } 
                else 
                {
                  Scaffold.of(context).showSnackBar(const SnackBar(content: Text("You're at homepage."
                     ),
                    ),
                  );
                  return;
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: !webViewReady
              ? null: () async 
              {
                if (await controller.canGoForward()) 
                {
                  controller.goForward();
                } 
                else 
                {
                  _scaffoldKey.currentState.showSnackBar(const SnackBar(content: Text("Cannot go Forward"
                      ),
                    ),
                  );
                  return;
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.replay),
              onPressed: !webViewReady? null : () 
              {
                controller.reload();
              },
            ),
          ],
        );
      },
    );
  }
}