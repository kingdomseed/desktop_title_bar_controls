library bitsdojo_window_macos;

import './window.dart';
import './native_api.dart';
import 'package:flutter/foundation.dart';

class MacAppWindow extends MacOSWindow {
  MacAppWindow._() {
    super.handle = getAppWindow();
    if (handle == null) {
      debugPrint("Could not get Flutter window");
    }
  }

  static final MacAppWindow _instance = MacAppWindow._();

  factory MacAppWindow() {
    return _instance;
  }
}
