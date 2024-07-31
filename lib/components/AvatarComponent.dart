import 'package:flutter/material.dart';
import 'package:naftinv/constante.dart';

class Avatarcomponent extends StatelessWidget {
  final double height;
  final Color color;
  final Color backgroundColor;
  final String text;
  Avatarcomponent(
      {required this.height,
      required this.backgroundColor,
      required this.color,
      required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(height * 0.1),
      alignment: Alignment.center,
      decoration: BoxDecoration(shape: BoxShape.circle, color: backgroundColor),
      child: Text(
        text,
        style: defaultTextStyle(
            color: color, fontSize: height * 0.2, fontWeight: FontWeight.w500),
      ),
    );
  }
}
