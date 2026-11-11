import 'package:flutter/material.dart';

class CustomWidgetText extends StatelessWidget {
  final String? text;
  final double? size;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  const CustomWidgetText({
    super.key,
    this.text,
    this.size,
    this.fontWeight,
    this.color,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text ?? '',
      textAlign: textAlign,
      style: TextStyle(fontSize: size, fontWeight: fontWeight, color: color),
    );
  }
}
