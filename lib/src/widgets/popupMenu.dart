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
    //keyBoardHeight is height of keyboard if showing
    double keyBoardHeight = MediaQuery.of(context).viewInsets.bottom;
    double safeAreaTop = MediaQuery.of(context).padding.top;
    double safeAreaBottom = MediaQuery.of(context).padding.bottom;
    double totalSafeArea = safeAreaTop + safeAreaBottom;
    double maxHeight = constraints.minHeight - keyBoardHeight - totalSafeArea;
    final double buttonWidth =
        parentRenderBox.size.width - position.right - position.left;
    final double? explicitWidth = popupConstraints.minWidth.isFinite &&
            popupConstraints.minWidth > 0
        ? popupConstraints.minWidth
        : null;
    final double effectiveWidth = explicitWidth ?? buttonWidth;
    if (explicitWidth != null) {
      return BoxConstraints(
        minWidth: effectiveWidth,
        maxWidth: effectiveWidth,
        maxHeight: maxHeight,
      );
    }
    return BoxConstraints.loose(Size(effectiveWidth, maxHeight));
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    // size: The size of the overlay.
    // childSize: The size of the menu, when fully open, as determined by
    // getConstraintsForChild.

    //keyBoardHeight is height of keyboard if showing
    double keyBoardHeight = MediaQuery.of(context).viewInsets.bottom;

    double x = position.left;
    // Clamp to prevent going off the right edge of the screen.
    if (x + childSize.width > size.width) {
      x = size.width - childSize.width;
    }
    if (x < 0) x = 0;

    // Find the ideal vertical position.
    double y = position.top;
    // check if we are in the bottom
    if (y + childSize.height > size.height - keyBoardHeight) {
      y = size.height - childSize.height - keyBoardHeight;
    }

    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_PopupMenuRouteLayout oldDelegate) {
    return true;
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
