import 'package:flutter/material.dart';

import '../properties/menu_props.dart';

Future<T?> showCustomMenu<T>({
  required BuildContext context,
  required MenuProps menuModeProps,
  required RelativeRect position,
  required Widget child,
  BoxConstraints constraints = const BoxConstraints(),
}) {
  final NavigatorState navigator = Navigator.of(context);
  return navigator.push(
    _PopupMenuRoute<T>(
      context: context,
      position: position,
      child: child,
      menuModeProps: menuModeProps,
      constraints: constraints,
      capturedThemes: InheritedTheme.capture(
        from: context,
        to: navigator.context,
      ),
    ),
  );
}

// Positioning of the menu on the screen.
class _PopupMenuRouteLayout extends SingleChildLayoutDelegate {
  // Rectangle of underlying button, relative to the overlay's dimensions.
  final RelativeRect position;
  final BuildContext context;

  final BoxConstraints popupConstraints;

  _PopupMenuRouteLayout(
    this.context,
    this.position, {
    this.popupConstraints = const BoxConstraints(),
  });

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final parentRenderBox = context.findRenderObject() as RenderBox;
    final mediaQuery = MediaQuery.of(context);
    final keyBoardHeight = mediaQuery.viewInsets.bottom;
    final totalSafeArea = mediaQuery.padding.top + mediaQuery.padding.bottom;
    final maxHeight = constraints.maxHeight - keyBoardHeight - totalSafeArea;
    final buttonWidth =
        parentRenderBox.size.width - position.right - position.left;
    final hasExplicitWidth = popupConstraints.minWidth.isFinite &&
        popupConstraints.minWidth > 0;
    final effectiveWidth =
        hasExplicitWidth ? popupConstraints.minWidth : buttonWidth;
    return hasExplicitWidth
        ? BoxConstraints.tightFor(width: effectiveWidth)
            .copyWith(maxHeight: maxHeight)
        : BoxConstraints.loose(Size(effectiveWidth, maxHeight));
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final keyBoardHeight = MediaQuery.of(context).viewInsets.bottom;

    final x = position.left.clamp(0.0, size.width - childSize.width);

    double y = position.top;
    if (y + childSize.height > size.height - keyBoardHeight) {
      y = size.height - childSize.height - keyBoardHeight;
    }

    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_PopupMenuRouteLayout oldDelegate) {
    return position != oldDelegate.position ||
        popupConstraints != oldDelegate.popupConstraints;
  }
}

class _PopupMenuRoute<T> extends PopupRoute<T> {
  final MenuProps menuModeProps;
  final BuildContext context;
  final RelativeRect position;
  final Widget child;
  final CapturedThemes capturedThemes;
  final BoxConstraints constraints;

  _PopupMenuRoute({
    required this.context,
    required this.menuModeProps,
    required this.position,
    required this.capturedThemes,
    required this.child,
    this.constraints = const BoxConstraints(),
  });

  @override
  Duration get transitionDuration => menuModeProps.animationDuration;

  @override
  bool get barrierDismissible => menuModeProps.barrierDismissible;

  @override
  Color? get barrierColor => menuModeProps.barrierColor;

  @override
  String? get barrierLabel => menuModeProps.barrierLabel;

  @override
  Animation<double>? get animation =>
      menuModeProps.animation ?? super.animation;

  @override
  Curve get barrierCurve => menuModeProps.barrierCurve ?? super.barrierCurve;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    final PopupMenuThemeData popupMenuTheme = PopupMenuTheme.of(context);
    final menu = Material(
      shape: menuModeProps.shape ?? popupMenuTheme.shape,
      color: menuModeProps.backgroundColor ?? popupMenuTheme.color,
      type: MaterialType.card,
      elevation: menuModeProps.elevation ?? popupMenuTheme.elevation ?? 8.0,
      clipBehavior: menuModeProps.clipBehavior,
      borderRadius: menuModeProps.borderRadius,
      animationDuration: menuModeProps.animationDuration,
      shadowColor: menuModeProps.shadowColor,
      textStyle: menuModeProps.textStyle ?? popupMenuTheme.textStyle,
      borderOnForeground: menuModeProps.borderOnForeground,
      child: child,
    );

    return CustomSingleChildLayout(
      delegate: _PopupMenuRouteLayout(context, position, popupConstraints: constraints),
      child: capturedThemes.wrap(menu),
    );
  }
}
