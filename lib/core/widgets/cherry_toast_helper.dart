import 'package:cherry_toast/cherry_toast.dart';
import 'package:flutter/material.dart';

class CherryToastHelper {
  CherryToastHelper._();

  static void success(BuildContext context, String message, {String? title}) {
    CherryToast.success(
      title: Text(title ?? ''),
      description: Text(message),
    ).show(context);
  }

  static void error(BuildContext context, String message, {String? title}) {
    CherryToast.error(
      title: Text(title ?? 'Error'),
      description: Text(message),
    ).show(context);
  }

  static void info(BuildContext context, String message, {String? title}) {
    CherryToast.info(
      title: Text(title ?? ''),
      description: Text(message),
    ).show(context);
  }

  static void warning(BuildContext context, String message, {String? title}) {
    CherryToast.warning(
      title: Text(title ?? 'Warning'),
      description: Text(message),
    ).show(context);
  }
}
