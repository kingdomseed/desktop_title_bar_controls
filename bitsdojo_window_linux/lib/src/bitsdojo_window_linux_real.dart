library bitsdojo_window_linux;

import 'package:bitsdojo_window_linux/src/native_api.dart' as native;
import 'package:bitsdojo_window_platform_interface/bitsdojo_window_platform_interface.dart';
import './window.dart';
import './app_window.dart';
import 'package:flutter/widgets.dart';

T? _ambiguate<T>(T? value) => value;

class BitsdojoWindowLinux extends BitsdojoWindowPlatform {
  BitsdojoWindowLinux() : super();

  @override
  void doWhenWindowReady(VoidCallback callback) {
    _ambiguate(WidgetsBinding.instance)!
        .waitUntilFirstFrameRasterized
        .then((value) {
      // Attempt to ensure the native window handle is ready once the first
      // frame is rasterized. If still not ready, caller ops will no-op safely.
      // Prefer readiness probe to avoid touching the singleton early.
      if (native.isAppWindowReady() != 0) {
        final app = GtkAppWindow();
        if (app.handle == null || app.handle == 0) {
          final h = native.getAppWindowHandle();
          if (h != 0) {
            app.handle = h;
          }
        }
      }
      isInsideDoWhenWindowReady = true;
      callback();
      isInsideDoWhenWindowReady = false;
    });
  }

  @override
  DesktopWindow get appWindow {
    return GtkAppWindow();
  }
}
