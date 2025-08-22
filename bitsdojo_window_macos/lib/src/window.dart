import 'package:bitsdojo_window_platform_interface/bitsdojo_window_platform_interface.dart';
import 'package:flutter/material.dart';
import './window_util.dart';
import './native_api.dart';

bool isValidHandle(int? handle, String operation) {
  if (handle == null) {
    debugPrint("Could not $operation - handle is null");
    return false;
  }
  return true;
}

class MacOSWindow extends DesktopWindow {
  @override
  int? handle;
  Size? _minSize;
  Size? _maxSize;
  Alignment? _alignment;
  bool _setTitleOnNextShow = false;
  String? _titleToSet;

  MacOSWindow() {
    _alignment = Alignment.center;
    _setTitleOnNextShow = false;
  }

  @override
  Size get size {
    final winRect = rect;
    return Size(winRect.right - winRect.left, winRect.bottom - winRect.top);
  }

  @override
  Rect get rect {
    if (!isValidHandle(handle, "get rectangle")) return Rect.zero;
    return getRectForWindow(handle!);
  }

  @override
  double get scaleFactor {
    //TODO: implement
    return 1;
  }

  @override
  set rect(Rect newRect) {
    if (!isValidHandle(handle, "set rectangle")) return;
    var widthToSet = ((_minSize != null) && (newRect.width < _minSize!.width))
        ? _minSize!.width
        : newRect.width;
    var heightToSet =
        ((_minSize != null) && (newRect.height < _minSize!.height))
            ? _minSize!.height
            : newRect.height;
    final rectToSet =
        Rect.fromLTWH(newRect.left, newRect.top, widthToSet, heightToSet);
    setRectForWindow(handle!, rectToSet);
  }

  @override
  Offset get position {
    final winRect = rect;
    return Offset(winRect.left, winRect.top);
  }

  @override
  set position(Offset newPosition) {
    if (!isValidHandle(handle, "set position")) return;
    setPositionForWindow(handle!, newPosition);
  }

  @override
  Alignment? get alignment => _alignment;
  @override
  set alignment(Alignment? newAlignment) {
    _alignment = newAlignment;
    if (_alignment != null) {
      if (!isValidHandle(handle, "set alignment")) return;
      final screenInfo = getScreenInfoForWindow(handle!);
      if (screenInfo.workingRect == null) {
        debugPrint("Can't set alignment - don't have a workingRect");
        return;
      }
      final windowRect =
          getRectOnScreen(size, _alignment!, screenInfo.workingRect!);
      final menuBarHeight = screenInfo.workingRect!.top;
      // We need to subtract menuBarHeight because .position uses
      // setFrameTopLeftPoint internally and that needs an offset
      // relative to the start of the working rectangle (after the menu bar)
      final positionToSet = windowRect.topLeft.translate(0, -menuBarHeight);
      position = positionToSet;
    }
  }

  @override
  set minSize(Size? newSize) {
    if (!isValidHandle(handle, "set minSize")) return;
    _minSize = newSize;
    if (newSize == null) {
      //TODO - add handling for setting minSize to null
      return;
    }
    setMinSize(handle!, _minSize!.width.toInt(), _minSize!.height.toInt());
  }

  @override
  set maxSize(Size? newSize) {
    if (!isValidHandle(handle, "set maxSize")) return;
    _maxSize = newSize;
    if (newSize == null) {
      //TODO - add handling for setting maxSize to null
      return;
    }
    setMaxSize(handle!, _maxSize!.width.toInt(), _maxSize!.height.toInt());
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
    if (_alignment == null) {
      setSize(handle!, sizeToSet.width.toInt(), sizeToSet.height.toInt());
    } else {
      final screenInfo = getScreenInfoForWindow(handle!);
      if (screenInfo.workingRect == null) {
        debugPrint("Can't set size - don't have a workingRect");
        return;
      }
      rect =
          getRectOnScreen(sizeToSet, _alignment!, screenInfo.workingRect!);
    }
  }

  @override
  Size get titleBarButtonSize {
    if (!isValidHandle(handle, "get titleBarButtonSize")) return Size.zero;
    throw UnimplementedError(
        'titleBarButtonSize getter has not been implemented.');
  }

  @override
  double get titleBarHeight {
    if (!isValidHandle(handle, "get titleBarHeight")) return 0;
    return getTitleBarHeight(handle!);
  }

  @override
  set title(String newTitle) {
    if (!isValidHandle(handle, "set title")) return;
    // Save title internally because window might be hidden
    // so title won't be set. Will set it on next show()
    if (isVisible == false) {
      _setTitleOnNextShow = true;
      _titleToSet = newTitle;
    }
    setWindowTitle(handle!, newTitle);
  }

  @override
  double get borderSize {
    //borderSize is zero on macOS
    return 0;
  }

  @override
  @Deprecated("use isVisible instead")
  bool get visible {
    return isVisible;
  }

  @override
  bool get isVisible {
    if (!isValidHandle(handle, "get isVisible")) return false;
    return isWindowVisible(handle!);
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
  void show() {
    if (!isValidHandle(handle, "show")) return;
    showWindow(handle!);
    if (_setTitleOnNextShow) {
      _setTitleOnNextShow = false;
      if (_titleToSet != null) {
        setWindowTitle(handle!, _titleToSet!);
      }
    }
  }

  @override
  void hide() {
    if (!isValidHandle(handle, "hide")) return;
    hideWindow(handle!);
  }

  @override
  void close() {
    if (!isValidHandle(handle, "close")) return;
    closeWindow(handle!);
  }

  @override
  void minimize() {
    if (!isValidHandle(handle, "minimize")) return;
    minimizeWindow(handle!);
  }

  @override
  void maximize() {
    if (!isValidHandle(handle, "maximize")) return;
    maximizeWindow(handle!);
  }

  @override
  void restore() {
    if (isMaximized) {
      maximizeOrRestore();
    }
  }

  @override
  bool get isMaximized {
    if (!isValidHandle(handle, "get isMaximized")) return false;
    return isWindowMaximized(handle!);
  }

  @override
  void startDragging() {
    if (!isValidHandle(handle, "start dragging")) return;
    moveWindow(handle!);
  }

  @override
  void maximizeOrRestore() {
    if (!isValidHandle(handle, "maximizeOrRestore")) return;
    maximizeOrRestoreWindow(handle!);
  }
  
  @override
  set topmost(bool topmost) {
    // TODO: implement topmost
  }
}
