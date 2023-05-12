import 'package:flutter/material.dart';

class IconUnderTextButton {
  static Widget build(
      {required Icon icon,
      required Text text,
      required VoidCallback onPressed}) {
    return TextButton(
        onPressed: onPressed,
        child: Column(
          children: [icon, text],
        ));
  }
}
