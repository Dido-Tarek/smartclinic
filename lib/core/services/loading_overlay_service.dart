import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:smartclinic/core/helper/app_navigator_key.dart';
import 'package:smartclinic/core/widgets/smart_clinic_loader.dart';

class LoadingOverlayService {
  static OverlayEntry? _overlayEntry;
  static int _activeRequests = 0;

  static void show() {
    _activeRequests++;
    if (_overlayEntry != null) return;

    final overlayState = appNavigatorKey.currentState?.overlay;
    if (overlayState == null) return;

    _overlayEntry = OverlayEntry(
      builder: (_) => Material(
        color: Colors.transparent,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            color: const Color.fromRGBO(0, 0, 0, 0.45),
            child: const SmartClinicLoader(),
          ),
        ),
      ),
    );

    overlayState.insert(_overlayEntry!);
  }

  static void hide() {
    if (_activeRequests > 0) _activeRequests--;
    if (_activeRequests > 0) return;
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
