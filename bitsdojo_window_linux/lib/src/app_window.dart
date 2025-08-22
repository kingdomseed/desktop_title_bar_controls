library bitsdojo_window_linux;

import './native_api.dart' as native;
import './window.dart';

const notInitializedMessage = """
 bitsdojo_window is not initalized.
 """;

class BitsDojoNotInitializedException implements Exception {
  String errMsg() => notInitializedMessage;
}

class GtkAppWindow extends GtkWindow {
  GtkAppWindow._() {
    final h = native.getAppWindowHandle();
    if (h != 0) {
      super.handle = h;
    } else {
      // Defer initialization; handle will be set once ready.
      super.handle = null;
    }
  }

  static final GtkAppWindow _instance = GtkAppWindow._();

  factory GtkAppWindow() {
    return _instance;
  }
}
