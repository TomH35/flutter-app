import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Prevedie timestamp (ms) na text, predvolene vo formáte yyyy-MM-dd.
String getFormattedDateTime(num dt, [String pattern = 'yyyy-MM-dd']) =>
    DateFormat(pattern).format(DateTime.fromMillisecondsSinceEpoch(dt.toInt()));

// Krátka správa v dolnej časti obrazovky (SnackBar).
void showMessage(BuildContext context, String msg) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(msg)));
}
