import 'dart:async';
import 'package:flutter/services.dart';

class BitsdojoWindowMacOS {
  static const MethodChannel _channel = MethodChannel('bitsdojo/window');

  static Future<void> maximizeOrRestoreWindow(int window) async {
    await _channel.invokeMethod('maximizeOrRestoreWindow', {
      'window': window,
    });
  }

  static Future<int?> getAppWindow() async {
    int? appWindow;
    await _channel.invokeMethod('getAppWindow').then((value) {
      appWindow = value;
    });
    return appWindow;
  }
}
