import 'package:flutter/material.dart'
    show
        runApp,
        Widget,
        BuildContext,
        MaterialApp,
        StatelessWidget,
        ThemeData,
        Colors;

import 'search_page.dart' show SearchPage;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(final BuildContext context) => MaterialApp(
        title: 'Kodeversitas',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.lightBlue,
          fontFamily: 'Nunito',
        ),
        home: SearchPage(),
        initialRoute: SearchPage.tag,
      );
}
