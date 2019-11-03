import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:politirate/theme/style.dart';

class DataCard extends StatelessWidget {
  final child;
  DataCard({@required this.child}) : assert(child != null);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: cSurface,
          boxShadow: [cardShadow]),
      child: child,
    );
  }
}
