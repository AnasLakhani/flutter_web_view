import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trizen/HomeScreen.dart';
import 'package:trizen/WebViewPage.dart';
import 'package:trizen/WikipediaExplorer.dart';
import 'package:trizen/constants.dart';
import 'package:trizen/splashscreen.dart';

import 'HomeScreen.dart';
import 'constants.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Jiji app",
      darkTheme: ThemeData.dark(),
      // theme:  ThemeData.dark(),
      theme: ThemeData(
          primaryColor: Colors.orange,
          accentColor: Colors.orange,
          appBarTheme: AppBarTheme(color: Colors.orange)),
      routes: <String, WidgetBuilder>{
        SPLASH_SCREEN: (_) => SplashScreen(),
        HOMEPAGE: (_) => HomeScreen(),
      },
      initialRoute: SPLASH_SCREEN,
    );
  }
}
