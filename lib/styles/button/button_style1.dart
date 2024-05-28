import 'package:flutter/material.dart';

ButtonStyle ButtonStyle1() {
    return ButtonStyle(
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      backgroundColor: WidgetStateProperty.all<Color>(Colors.red),
      padding: WidgetStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.symmetric(horizontal: 3)),
    );
  }