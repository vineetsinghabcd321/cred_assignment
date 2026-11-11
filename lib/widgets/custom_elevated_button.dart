import 'package:flutter/material.dart';

Widget customElevatedButton({
  final String? text,
  final VoidCallback? onPressed,
}) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
    decoration: BoxDecoration(
      color: Colors.blue,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(width: 2, color: Colors.black),
    ),
    child: ElevatedButton(onPressed: onPressed, child: Text(text ?? " ")),
  );
}
