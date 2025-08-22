// ignore_for_file: constant_identifier_names
library bitsdojo_window_macos;

import 'dart:ffi';
import 'dart:ui';
import 'package:ffi/ffi.dart';
import './native_struct.dart';

final DynamicLibrary _appExecutable = DynamicLibrary.executable();

const BDW_SUCCESS = 1;

// Native function types

// First line - native function type definition
// Second line - dart function type definition
// Third line - dart function type instance

// getAppWindow
typedef TGetAppWindow = IntPtr Function();
typedef DGetAppWindow = int Function();
final DGetAppWindow getAppWindow = _publicAPI.ref.getAppWindow.asFunction();

// setWindowCanBeShown
typedef TSetWindowCanBeShown = Void Function(Int8 value);
typedef DSetWindowCanBeShown = void Function(int value);
final DSetWindowCanBeShown _setWindowCanBeShown =
    _publicAPI.ref.setWindowCanBeShown.asFunction();
void setWindowCanBeShown(bool value) => _setWindowCanBeShown(value ? 1 : 0);

// setInsideDoWhenWindowReady
typedef TSetInsideDoWhenWindowReady = Void Function(Int8 value);
typedef DSetInsideDoWhenWindowReady = void Function(int value);
final DSetInsideDoWhenWindowReady _setInsideDoWhenWindowReady =
    _publicAPI.ref.setInsideDoWhenWindowReady.asFunction();
void setInsideDoWhenWindowReady(bool value) =>
    _setInsideDoWhenWindowReady(value ? 1 : 0);

// showWindow
typedef TShowWindow = Void Function(IntPtr window);
typedef DShowWindow = void Function(int window);
final DShowWindow showWindow = _publicAPI.ref.showWindow.asFunction();

// hideWindow
typedef THideWindow = Void Function(IntPtr window);
typedef DHideWindow = void Function(int window);
final DShowWindow hideWindow = _publicAPI.ref.hideWindow.asFunction();

// moveWindow
typedef TMoveWindow = Void Function(IntPtr window);
typedef DMoveWindow = void Function(int window);
final DMoveWindow moveWindow = _publicAPI.ref.moveWindow.asFunction();

// setSize
typedef TSetSize = Void Function(IntPtr window, Int32 first, Int32 second);
typedef DSetSize = void Function(int window, int first, int second);
final DSetSize setSize = _publicAPI.ref.setSize.asFunction();

// setMinSize
typedef TSetMinSize = Void Function(IntPtr window, Int32 first, Int32 second);
typedef DSetMinSize = void Function(int window, int first, int second);
final DSetMinSize setMinSize = _publicAPI.ref.setMinSize.asFunction();

// setMaxSize
typedef TSetMaxSize = Void Function(IntPtr window, Int32 first, Int32 second);
typedef DSetMaxSize = void Function(int window, int first, int second);
final DSetMinSize setMaxSize = _publicAPI.ref.setMaxSize.asFunction();

// getScreenInfoForWindow
typedef TGetScreenInfoForWindow = Int8 Function(
    IntPtr window, Pointer<BDWScreenInfo> screenInfo);
typedef DGetScreenInfoForWindow = int Function(
    int window, Pointer<BDWScreenInfo> screenInfo);
final DGetScreenInfoForWindow _getScreenInfoForWindow =
    _publicAPI.ref.getScreenInfoForWindow.asFunction();

bool getScreenInfoNative(int window, Pointer<BDWScreenInfo> screenInfo) {
  int result = _getScreenInfoForWindow(window, screenInfo);
  return result == BDW_SUCCESS ? true : false;
}

// setPositionForWindow
typedef TSetPositionForWindow = Int8 Function(
    IntPtr window, Pointer<BDWOffset> rect);
typedef DSetPositionForWindow = int Function(
    int window, Pointer<BDWOffset> rect);
final DSetPositionForWindow setPositionForWindowNative =
    _publicAPI.ref.setPositionForWindow.asFunction();

bool setPositionForWindow(int window, Offset offset) {
  final Pointer<BDWOffset> offsetPointer = newBDWOffset();
  offsetPointer.ref
    ..x = offset.dx
    ..y = offset.dy;
  int result = setPositionForWindowNative(window, offsetPointer);
  return result == BDW_SUCCESS ? true : false;
}

// setRectForWindow
typedef TSetRectForWindow = Int8 Function(IntPtr window, Pointer<BDWRect> rect);
typedef DSetRectForWindow = int Function(int window, Pointer<BDWRect> rect);
final DSetRectForWindow setRectForWindowNative =
    _publicAPI.ref.setRectForWindow.asFunction();

// getRectForWindow
typedef TGetRectForWindow = Int8 Function(IntPtr window, Pointer<BDWRect> rect);
typedef DGetRectForWindow = int Function(int window, Pointer<BDWRect> rect);
final DGetRectForWindow getRectForWindowNative =
    _publicAPI.ref.getRectForWindow.asFunction();

// isWindowVisibleπ
typedef TIsWindowVisible = Int8 Function(IntPtr window);
typedef DIsWindowVisible = int Function(int window);
final DIsWindowVisible _isWindowVisible =
    _publicAPI.ref.isWindowVisible.asFunction();
bool isWindowVisible(int window) =>
    _isWindowVisible(window) == 1 ? true : false;

// isWindowMaximized
typedef TIsWindowMaximized = Int8 Function(IntPtr window);
typedef DIsWindowMaximized = int Function(int window);
final DIsWindowMaximized _isWindowMaximized =
    _publicAPI.ref.isWindowMaximized.asFunction();
bool isWindowMaximized(int window) =>
    _isWindowMaximized(window) == 1 ? true : false;

// maximizeWindow
typedef TMaximizeOrRestoreWindow = Void Function(IntPtr window);
typedef DMaximizeOrRestoreWindow = void Function(int window);
final DMaximizeOrRestoreWindow maximizeOrRestoreWindow =
    _publicAPI.ref.maximizeOrRestoreWindow.asFunction();

// maximizeWindow
typedef TMaximizeWindow = Void Function(IntPtr window);
typedef DMaximizeWindow = void Function(int window);
final DMaximizeWindow maximizeWindow =
    _publicAPI.ref.maximizeWindow.asFunction();

// maximizeWindow
typedef TMinimizeWindow = Void Function(IntPtr window);
typedef DMinimizeWindow = void Function(int window);
final DMinimizeWindow minimizeWindow =
    _publicAPI.ref.minimizeWindow.asFunction();

// closeWindow
typedef TCloseWindow = Void Function(IntPtr window);
typedef DCloseWindow = void Function(int window);
final DMinimizeWindow closeWindow = _publicAPI.ref.closeWindow.asFunction();

// setWindowTitle
typedef TSetWindowTitle = Void Function(IntPtr window, Pointer<Utf8> title);
typedef DSetWindowTitle = void Function(int window, Pointer<Utf8> title);
final DSetWindowTitle _setWindowTitle =
    _publicAPI.ref.setWindowTitle.asFunction();

void setWindowTitle(int window, String title) {
  final title0 = title.toNativeUtf8();
  _setWindowTitle(window, title0);
  calloc.free(title0);
}

// getTitleBarHeight
typedef TGetTitleBarHeight = Double Function(IntPtr window);
typedef DGetTitleBarHeight = double Function(int window);
final DGetTitleBarHeight getTitleBarHeight =
    _publicAPI.ref.getTitleBarHeight.asFunction();

// setTopmost
typedef Void TSetTopmost(IntPtr window, Int32 topmost);
typedef DSetTopmost = void Function(int window, int topmost);
final DSetTopmost setTopmost = _publicAPI.ref.setTopmost.asFunction();

class BDWPublicAPI extends Struct {
  external Pointer<NativeFunction<TGetAppWindow>> getAppWindow;
  external Pointer<NativeFunction<TSetWindowCanBeShown>> setWindowCanBeShown;
  external Pointer<NativeFunction<TSetInsideDoWhenWindowReady>>
      setInsideDoWhenWindowReady;
  external Pointer<NativeFunction<TShowWindow>> showWindow;
  external Pointer<NativeFunction<THideWindow>> hideWindow;
  external Pointer<NativeFunction<TMoveWindow>> moveWindow;
  external Pointer<NativeFunction<TSetSize>> setSize;
  external Pointer<NativeFunction<TSetMinSize>> setMinSize;
  external Pointer<NativeFunction<TSetMaxSize>> setMaxSize;
  external Pointer<NativeFunction<TGetScreenInfoForWindow>>
      getScreenInfoForWindow;
  external Pointer<NativeFunction<TSetPositionForWindow>> setPositionForWindow;
  external Pointer<NativeFunction<TSetRectForWindow>> setRectForWindow;
  external Pointer<NativeFunction<TGetRectForWindow>> getRectForWindow;
  external Pointer<NativeFunction<TIsWindowMaximized>> isWindowVisible;
  external Pointer<NativeFunction<TIsWindowMaximized>> isWindowMaximized;
  external Pointer<NativeFunction<TMaximizeWindow>> maximizeOrRestoreWindow;
  external Pointer<NativeFunction<TMaximizeWindow>> maximizeWindow;
  external Pointer<NativeFunction<TMaximizeWindow>> minimizeWindow;
  external Pointer<NativeFunction<TCloseWindow>> closeWindow;
  external Pointer<NativeFunction<TSetWindowTitle>> setWindowTitle;
  external Pointer<NativeFunction<TGetTitleBarHeight>> getTitleBarHeight;
  external Pointer<NativeFunction<TSetTopmost>> setTopmost;
}

class BDWAPI extends Struct {
  external Pointer<BDWPublicAPI> publicAPI;
}

typedef TBitsdojoWindowAPI = Pointer<BDWAPI> Function();

final TBitsdojoWindowAPI bitsdojoWindowAPI = _appExecutable
    .lookup<NativeFunction<TBitsdojoWindowAPI>>("bitsdojo_window_api")
    .asFunction();

final Pointer<BDWPublicAPI> _publicAPI = bitsdojoWindowAPI().ref.publicAPI;
