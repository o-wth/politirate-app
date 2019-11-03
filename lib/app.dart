import 'package:flutter/material.dart';
import 'theme/style.dart';
import 'views/search_page.dart';

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: buildTheme(),
      home: SearchPage(),
      debugShowCheckedModeBanner: false
    );
  }
}
