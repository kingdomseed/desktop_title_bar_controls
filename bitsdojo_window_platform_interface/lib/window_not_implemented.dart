import './window.dart';
import 'package:flutter/rendering.dart';

class NotImplementedWindow extends DesktopWindow {
  @override
  int get handle {
    throw UnimplementedError('handle getter has not been implemented');
  }

  @override
  set size(Size newSize) {
    throw UnimplementedError('size setter has not been implemented');
  }

  @override
  Size get size {
    throw UnimplementedError('size getter has not been implemented.');
  }

  @override
  Rect get rect {
    throw UnimplementedError('rect getter has not been implemented.');
  }

  @override
  set rect(Rect newRect) {
    throw UnimplementedError('rect setter has not been implemented.');
  }

  @override
  Offset get position {
    throw UnimplementedError('position getter has not been implemented.');
  }

  @override
  set position(Offset newPosition) {
    throw UnimplementedError('position setter has not been implemented.');
  }

  @override
  set minSize(Size? newSize) {
    throw UnimplementedError('minSize setter has not been implemented.');
  }

  @override
  set maxSize(Size? newSize) {
    throw UnimplementedError('maxSize setter has not been implemented.');
  }

  @override
  Alignment get alignment {
    throw UnimplementedError('alignment getter has not been implemented.');
  }

  @override
  set alignment(Alignment? newAlignment) {
    throw UnimplementedError('alignment setter has not been implemented.');
  }

  @override
  set title(String newTitle) {
    throw UnimplementedError('title setter has not been implemented.');
  }

  @override
  void show() {
    throw UnimplementedError('show() has not been implemented.');
  }

  @override
  void hide() {
    throw UnimplementedError('hide() has not been implemented.');
  }

  @override
  @Deprecated("use isVisible instead")
  bool get visible {
    return isVisible;
  }

  @override
  bool get isVisible {
    throw UnimplementedError('isVisible has not been implemented.');
  }

  @override
  @Deprecated("use show()/hide() instead")
  set visible(bool isVisible) {
    throw UnimplementedError('visible setter has not been implemented.');
  }

  @override
  Size get titleBarButtonSize {
    throw UnimplementedError(
        'titleBarButtonSize getter has not been implemented.');
  }

  @override
  double get titleBarHeight {
    throw UnimplementedError('titleBarHeight getter has not been implemented.');
  }

  @override
  double get borderSize {
    throw UnimplementedError('borderSize getter has not been implemented.');
  }

  @override
  void close() {
    throw UnimplementedError('close() has not been implemented.');
  }

  @override
  void minimize() {
    throw UnimplementedError('minimize() has not been implemented.');
  }

  @override
  void maximize() {
    throw UnimplementedError('maximize() has not been implemented.');
  }

  @override
  void maximizeOrRestore() {
    throw UnimplementedError('maximizeOrRestore has not been implemented.');
  }

  @override
  void restore() {
    throw UnimplementedError('restore has not been implemented.');
  }

  @override
  void startDragging() {
    throw UnimplementedError('startDragging has not been implemented.');
  }

  @override
  bool get isMaximized {
    throw UnimplementedError('isMaximized getter has not been implemented.');
  }

  @override
  double get scaleFactor {
    throw UnimplementedError('scaleFactor setter has not been implemented');
  }
}
