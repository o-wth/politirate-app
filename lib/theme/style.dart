import 'package:flutter/material.dart';

const cSurface = const Color(0xFFf5f5f5);
const cBackground = const Color(0xffeeeeee);
const cText = const Color(0xff616161);
const cTextBold = const Color(0xff424242);
const cAccent = const Color(0xffd1c4e9);
const cGood = const Color(0xFFa5d6a7);
const cError = const Color(0xFFE57373);
const cOkay = const Color(0xffffab91);

const cardShadow = const BoxShadow(
    color: Color(0x2c000000),
    offset: Offset(0.0, 3.0),
    blurRadius: 12.0
);

abstract class ThemeText {
  static const TextStyle pageTitle =
      TextStyle(fontSize: 52, fontWeight: FontWeight.w900, letterSpacing: -1);
  static const TextStyle buttonText =
      TextStyle(fontSize: 18, fontWeight: FontWeight.w500, letterSpacing: -1);
  static const TextStyle medTitle =
    TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -1);
  static const TextStyle nameText =
    TextStyle(fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: -1);
  static const TextStyle lastName =
    TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1);
  static const TextStyle subTitle =
    TextStyle(fontSize: 18, fontWeight: FontWeight.w500, letterSpacing: -1);
}

class NoOverScrollBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

ThemeData buildTheme() {
  ThemeData base = ThemeData.light();
  var brightness = Brightness.light;
  return base.copyWith(
    accentColor: cAccent,
    primaryColor: cAccent,
    cursorColor: cAccent,
    scaffoldBackgroundColor: cSurface,
    cardColor: cBackground,
    textSelectionColor: cAccent,
    errorColor: cError,
    buttonTheme: base.buttonTheme
        .copyWith(textTheme: ButtonTextTheme.primary, buttonColor: cText),
    appBarTheme: base.appBarTheme.copyWith(
        brightness: brightness, color: Colors.transparent, elevation: 0.0),
    iconTheme: base.iconTheme.copyWith(color: cText),
    primaryIconTheme: base.primaryIconTheme.copyWith(color: cTextBold),
    textTheme: _buildTextTheme(base.textTheme),
    accentTextTheme: _buildTextTheme(base.accentTextTheme),
    primaryTextTheme: _buildTextTheme(base.primaryTextTheme),
  );
}

TextTheme _buildTextTheme(TextTheme base) {
  return base.apply(
      fontFamily: "Circular", displayColor: cText, bodyColor: cText);
}
