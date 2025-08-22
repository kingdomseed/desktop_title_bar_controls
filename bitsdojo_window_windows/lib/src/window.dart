import 'dart:ffi' hide Size;
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

import './win32_plus.dart';
import './native_api.dart' as native;
import 'package:bitsdojo_window_platform_interface/bitsdojo_window_platform_interface.dart';
import './window_util.dart';
import './window_interface.dart';

var isInsideDoWhenWindowReady = false;

bool isValidHandle(int? handle, String operation) {
  if (handle == null) {
    debugPrint("Could not $operation - handle is null");
    return false;
  }
  return true;
}

Rect getScreenRectForWindow(int handle) {
  int monitor = MonitorFromWindow(handle, MONITOR_DEFAULTTONEAREST);
  final monitorInfo = calloc<MONITORINFO>()..ref.cbSize = sizeOf<MONITORINFO>();
  final result = GetMonitorInfo(monitor, monitorInfo);
  if (result == TRUE) {
    return Rect.fromLTRB(
        monitorInfo.ref.rcWork.left.toDouble(),
        monitorInfo.ref.rcWork.top.toDouble(),
        monitorInfo.ref.rcWork.right.toDouble(),
        monitorInfo.ref.rcWork.bottom.toDouble());
  }
  return Rect.zero;
}

class WinWindow extends WinDesktopWindow {
  static final dpiAware = native.isDPIAware();
  @override
  int? handle;
  Size? _minSize;
  Size? _maxSize;
  // We use this for reporting size inside doWhenWindowReady
  // as GetWindowRect might not work reliably before window is shown on screen
  Size? _sizeSetFromDart;
  Alignment? _alignment;

  @override
  void setWindowCutOnMaximize(int value) {
    native.setWindowCutOnMaximize(value);
  }

  WinWindow() {
    _alignment = Alignment.center;
  }

  @override
  Rect get rect {
    if (!isValidHandle(handle, "get rectangle")) return Rect.zero;
    final winRect = calloc<RECT>();
    GetWindowRect(handle!, winRect);
    Rect result = winRect.ref.toRect;
    calloc.free(winRect);
    return result;
  }

  @override
  set rect(Rect newRect) {
    if (!isValidHandle(handle, "set rectangle")) return;
    setWindowPos(handle!, 0, newRect.left.toInt(), newRect.top.toInt(),
        newRect.width.toInt(), newRect.height.toInt(), 0);
  }

  @override
  Size get size {
    final winRect = rect;
    final gotSize = getLogicalSize(Size(winRect.width, winRect.height));
    return gotSize;
  }

  Size get sizeOnScreen {
    if (isInsideDoWhenWindowReady == true) {
      if (_sizeSetFromDart != null) {
        final sizeOnScreen = getSizeOnScreen(_sizeSetFromDart!);
        return sizeOnScreen;
      }
    }
    final winRect = rect;
    return Size(winRect.width, winRect.height);
  }

  double systemMetric(int metric, {int dpiToUse = 0}) {
    final windowDpi = dpiToUse != 0 ? dpiToUse : dpi;
    double result = dpiAware
        ? GetSystemMetricsForDpi(metric, windowDpi).toDouble()
        : GetSystemMetrics(metric).toDouble();
    return result;
  }

  @override
  double get borderSize {
    return systemMetric(SM_CXBORDER);
  }

  int get dpi {
    if (!dpiAware || !isValidHandle(handle, "get dpi")) return 96;
    return GetDpiForWindow(handle!);
  }

  @override
  double get scaleFactor {
    double result = dpi / 96.0;
    return result;
  }

  @override
  double get titleBarHeight {
    double scaleFactor = this.scaleFactor;
    int dpiToUse = dpi;
    double cyCaption = systemMetric(SM_CYCAPTION, dpiToUse: dpiToUse);
    cyCaption = (cyCaption / scaleFactor);
    double cySizeFrame = systemMetric(SM_CYSIZEFRAME, dpiToUse: dpiToUse);
    cySizeFrame = (cySizeFrame / scaleFactor);
    double cxPaddedBorder = systemMetric(SM_CXPADDEDBORDER, dpiToUse: dpiToUse);
    cxPaddedBorder = (cxPaddedBorder / scaleFactor).ceilToDouble();
    double result = cySizeFrame + cyCaption + cxPaddedBorder;
    return result;
  }

  @override
  Size get titleBarButtonSize {
    double height = titleBarHeight - borderSize;
    double scaleFactor = this.scaleFactor;
    double cyCaption = systemMetric(SM_CYCAPTION);
    cyCaption /= scaleFactor;
    double width = cyCaption * 2;
    return Size(width, height);
  }

  Size getSizeOnScreen(Size inSize) {
    double scaleFactor = this.scaleFactor;
    double newWidth = inSize.width * scaleFactor;
    double newHeight = inSize.height * scaleFactor;
    return Size(newWidth, newHeight);
  }

  Size getLogicalSize(Size inSize) {
    double scaleFactor = this.scaleFactor;
    double newWidth = inSize.width / scaleFactor;
    double newHeight = inSize.height / scaleFactor;
    return Size(newWidth, newHeight);
  }

  @override
  Alignment? get alignment => _alignment;

  /// How the window should be aligned on screen
  @override
  set alignment(Alignment? newAlignment) {
    final sizeOnScreen = this.sizeOnScreen;
    _alignment = newAlignment;
    if (_alignment != null) {
      if (!isValidHandle(handle, "set alignment")) return;
      final screenRect = getScreenRectForWindow(handle!);
      final rectOnScreen =
          getRectOnScreen(sizeOnScreen, _alignment!, screenRect);
      rect = rectOnScreen;
    }
  }

  @override
  set minSize(Size? newSize) {
    _minSize = newSize;
    if (newSize == null) {
      //TODO - add handling for setting minSize to null
      return;
    }
    native.setMinSize(_minSize!.width.toInt(), _minSize!.height.toInt());
  }

  @override
  set maxSize(Size? newSize) {
    _maxSize = newSize;
    if (newSize == null) {
      //TODO - add handling for setting maxSize to null
      return;
    }
    native.setMaxSize(_maxSize!.width.toInt(), _maxSize!.height.toInt());
  }

  @override
  set size(Size newSize) {
    if (!isValidHandle(handle, "set size")) return;

    var width = newSize.width;

    if (_minSize != null) {
      if (newSize.width < _minSize!.width) width = _minSize!.width;
    }

    if (_maxSize != null) {
      if (newSize.width > _maxSize!.width) width = _maxSize!.width;
    }

    var height = newSize.height;

    if (_minSize != null) {
      if (newSize.height < _minSize!.height) height = _minSize!.height;
    }

    if (_maxSize != null) {
      if (newSize.height > _maxSize!.height) height = _maxSize!.height;
    }

    Size sizeToSet = Size(width, height);
    _sizeSetFromDart = sizeToSet;
    if (_alignment == null) {
      SetWindowPos(handle!, 0, 0, 0, sizeToSet.width.toInt(),
          sizeToSet.height.toInt(), SWP_NOMOVE);
    } else {
      final sizeOnScreen = getSizeOnScreen((sizeToSet));
      final screenRect = getScreenRectForWindow(handle!);
      rect = getRectOnScreen(sizeOnScreen, _alignment!, screenRect);
    }
  }

  @override
  bool get isMaximized {
    if (!isValidHandle(handle, "get isMaximized")) return false;
    return (IsZoomed(handle!) == 1);
  }

  @override
  @Deprecated("use isVisible instead")
  bool get visible {
    return isVisible;
  }

  @override
  bool get isVisible {
    return (IsWindowVisible(handle!) == 1);
  }

  @override
  Offset get position {
    final winRect = rect;
    return Offset(winRect.left, winRect.top);
  }

  @override
  set position(Offset newPosition) {
    if (!isValidHandle(handle, "set position")) return;
    SetWindowPos(handle!, 0, newPosition.dx.toInt(), newPosition.dy.toInt(), 0,
        0, SWP_NOSIZE);
  }

  @override
  void show() {
    if (!isValidHandle(handle, "show")) return;
    setWindowPos(
        handle!, 0, 0, 0, 0, 0, SWP_NOSIZE | SWP_NOMOVE | SWP_SHOWWINDOW);
    forceChildRefresh(handle!);
  }

  @override
  void hide() {
    if (!isValidHandle(handle, "hide")) return;
    SetWindowPos(
        handle!, 0, 0, 0, 0, 0, SWP_NOSIZE | SWP_NOMOVE | SWP_HIDEWINDOW);
  }

  @override
  @Deprecated("use show()/hide() instead")
  set visible(bool isVisible) {
    if (isVisible) {
      show();
    } else {
      hide();
    }
  }

  @override
  void close() {
    if (!isValidHandle(handle, "close")) return;
    PostMessage(handle!, WM_SYSCOMMAND, SC_CLOSE, 0);
  }

  @override
  void maximize() {
    if (!isValidHandle(handle, "maximize")) return;
    PostMessage(handle!, WM_SYSCOMMAND, SC_MAXIMIZE, 0);
  }

  @override
  void minimize() {
    if (!isValidHandle(handle, "minimize")) return;

    PostMessage(handle!, WM_SYSCOMMAND, SC_MINIMIZE, 0);
  }

  @override
  void restore() {
    if (!isValidHandle(handle, "restore")) return;
    PostMessage(handle!, WM_SYSCOMMAND, SC_RESTORE, 0);
  }

  @override
  void maximizeOrRestore() {
    if (!isValidHandle(handle, "maximizeOrRestore")) return;
    if (IsZoomed(handle!) == 1) {
      restore();
    } else {
      maximize();
    }
  }

  @override
  set title(String newTitle) {
    if (!isValidHandle(handle, "set title")) return;
    setWindowText(handle!, newTitle);
  }

  @override
  void startDragging() {
    BitsdojoWindowPlatform.instance.dragAppWindow();
  }

  @override
  set topmost(bool topmost) {
    // TODO: implement topmost
  }
}
