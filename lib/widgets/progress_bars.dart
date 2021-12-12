import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnimatedLinearProgressBar extends StatefulWidget {
  final double value;
  final double height;
  final Color fillColor;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double outerCornerRadius;
  final double? innerCornerRadius;
  final String displayText;
  final TextStyle? textStyle;

  const AnimatedLinearProgressBar({
    Key? key,
    this.value = 0.5,
    this.height = 50,
    this.fillColor = Colors.black26,
    this.backgroundColor = Colors.transparent,
    this.borderColor = Colors.black,
    this.borderWidth = 1.5,
    this.outerCornerRadius = 10,
    this.innerCornerRadius,
    this.displayText = "",
    this.textStyle,
  }) : super(key: key);

  @override
  State<AnimatedLinearProgressBar> createState() => _AnimatedLinearProgressBarState();
}

class _AnimatedLinearProgressBarState extends State<AnimatedLinearProgressBar> with
    SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late CurvedAnimation _curvedAnimation;
  late Tween<double> valueTween;

  @override
  void initState() {
    super.initState();

    valueTween = Tween<double>(
      begin: widget.value,
      end: widget.value,
    );

    _controller = AnimationController(
      value: widget.value,
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _controller.forward();

    _curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _curvedAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curvedAnimation,
      child: SizedBox(
        height: widget.height,
        child: Center(
          child: Text(
            widget.displayText,
            style: widget.textStyle ?? TextStyle(
              fontSize: widget.height * 0.5,
              color: widget.borderColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      builder: (context, child) {
        return CustomPaint(
          child: child,
          painter: AnimatedLinearProgressBarPainter(
            percentage: valueTween.evaluate(_curvedAnimation),
            height: widget.height,
            color: widget.fillColor,
            backgroundColor: widget.backgroundColor,
            outerCornerRadius: widget.outerCornerRadius,
            innerCornerRadius: (widget.innerCornerRadius != null) ? widget.innerCornerRadius : null,
            paintingStyle: PaintingStyle.fill,
          ),
          foregroundPainter: AnimatedLinearProgressBarPainter(
            height: widget.height,
            color: widget.borderColor,
            backgroundColor: widget.backgroundColor,
            borderWidth: widget.borderWidth,
            outerCornerRadius: widget.outerCornerRadius,
            paintingStyle: PaintingStyle.stroke,
          ),
        );
      },
    );
  }

  @override
  void didUpdateWidget(AnimatedLinearProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    _curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.duration = Duration(milliseconds: (500).toInt());

    if (widget.value != oldWidget.value) {
      valueTween = Tween<double>(
        begin: oldWidget.value,
        end: widget.value,
      );

      _controller
        ..value = 0
        ..forward();
    }
  }
}

class AnimatedLinearProgressBarPainter extends CustomPainter {
  final double? percentage;
  final double height;
  final Color color;
  final Color? backgroundColor;
  final PaintingStyle paintingStyle;
  final double? borderWidth;
  final double outerCornerRadius;
  final double? innerCornerRadius;

  AnimatedLinearProgressBarPainter({
    this.percentage,
    required this.height,
    required this.color,
    this.backgroundColor,
    required this.paintingStyle,
    this.borderWidth,
    required this.outerCornerRadius,
    this.innerCornerRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = borderWidth ?? 0
      ..strokeCap = StrokeCap.round
      ..style = paintingStyle;
    final double width = (percentage != null) ? (size.width * percentage!) : size.width;
    final Radius rightRadius = (innerCornerRadius != null) ? Radius.circular(innerCornerRadius!) : Radius.circular(outerCornerRadius);

    final clipRect = RRect.fromLTRBR(0, 0, size.width, size.height, Radius.circular(outerCornerRadius));
    final bar = RRect.fromLTRBAndCorners(0, 0, width, height,
      topLeft: Radius.circular(outerCornerRadius),
      topRight: rightRadius,
      bottomLeft: Radius.circular(outerCornerRadius),
      bottomRight: rightRadius,
    );

    if (backgroundColor != null && backgroundColor != Colors.transparent) {
      final backgroundPaint = Paint()
        ..color = backgroundColor ?? Colors.transparent
        ..style = PaintingStyle.fill;
      canvas.drawRRect(bar, backgroundPaint);
    }
    if (percentage != null) {
      canvas.clipRRect(clipRect);
    }
    canvas.drawRRect(bar, paint);
    // canvas.drawRRect(fullBar, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    final old = (oldDelegate as _AnimatedRectProgressBarPainter);
    return old.percentage != percentage;
  }
}

// ========================================================================= //

class AnimatedRectProgressBar extends StatefulWidget {
  //Required properties
  final double value;
  final Color fillColor;

  //Optional properties -- Defaults
  final Radius outerCornerRadius; //Radius.zero
  final Radius innerCornerRadius; //Radius.zero
  final Curve animationCurve; //Curves.easeInOut
  final Duration animationDuration; //Duration(milliseconds: 500)
  final AxisDirection fillDirection; //AxisDirection.right

  //Nullable properties -- Behavior if null
  final double? height; //Will assume height of container
  final double? width; //Will assume width of container
  final Color? backgroundColor; //Will skip painting the background
  final Color? borderColor; //Will skip painting the border
  final double? borderWidth; //Will skip painting the border
  final String? displayText; //Will skip painting any child
  final TextStyle? textStyle; //Will default to parent TextStyle
  final double? initialValue; //Will not animate the first value

  const AnimatedRectProgressBar({
    Key? key,
    required this.value,
    required this.fillColor,
    this.outerCornerRadius = Radius.zero,
    this.innerCornerRadius = Radius.zero,
    this.animationCurve = Curves.easeInOut,
    this.animationDuration = const Duration(milliseconds: 500),
    this.fillDirection = AxisDirection.right,
    this.height,
    this.width,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.displayText,
    this.textStyle,
    this.initialValue,
  }) : super(key: key);

  @override
  State<AnimatedRectProgressBar> createState() => _AnimatedRectProgressBarState();
}

class _AnimatedRectProgressBarState extends State<AnimatedRectProgressBar> with
    SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late CurvedAnimation _curvedAnimation;
  late Tween<double> _valueTween;

  @override
  void initState() {
    super.initState();

    _valueTween = Tween<double>(
      begin: widget.initialValue ?? widget.value,
      end: widget.value,
    );

    _controller = AnimationController(
      value: widget.value,
      duration: widget.animationDuration,
      vsync: this,
    );
    _controller.forward();

    _curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _curvedAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget? displayTextWidget = (widget.displayText != null) ? Center(
      child: Text(
        widget.displayText!,
        style: widget.textStyle,
      )
    ) : null;

    final CustomPainter? strokePainter = (widget.borderColor == null || widget.borderWidth == null) ? null : _AnimatedRectProgressBarPainter(
      color: widget.borderColor!,
      cornerRadius: widget.outerCornerRadius,
      paintingStyle: PaintingStyle.stroke,
      height: widget.height,
      width: widget.width,
      borderWidth: widget.borderWidth,
    );

    return AnimatedBuilder(
      animation: _curvedAnimation,
      child: SizedBox(
        height: widget.height,
        width: widget.width,
        child: displayTextWidget,
      ),
      builder: (context, child) {
        return CustomPaint(
          child: child,
          painter: _AnimatedRectProgressBarPainter(
            percentage: _valueTween.evaluate(_curvedAnimation),
            color: widget.fillColor,
            cornerRadius: widget.innerCornerRadius,
            paintingStyle: PaintingStyle.fill,
            fillDirection: widget.fillDirection,
            height: widget.height,
            width: widget.width,
            clipCornerRadius: widget.outerCornerRadius,
            backgroundColor: widget.backgroundColor,
            borderWidth: widget.borderWidth,
          ),
          foregroundPainter: strokePainter,
        );
      },
    );
  }

  @override
  void didUpdateWidget(AnimatedRectProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    _curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.duration = Duration(milliseconds: (500).toInt());

    if (widget.value != oldWidget.value) {
      _valueTween = Tween<double>(
        begin: oldWidget.value,
        end: widget.value,
      );

      _controller
        ..value = 0
        ..forward();
    }
  }
}

class _AnimatedRectProgressBarPainter extends CustomPainter {
  //Required properties
  final Color color;
  final Radius cornerRadius;
  final PaintingStyle paintingStyle;

  //Nullable properties -- Behavior if null
  final double? percentage;
  final double? height; //Will default to paint size.height property
  final double? width; //Will default to paint size.width property
  final Radius? clipCornerRadius; //Will default to Radius.zero
  final Color? backgroundColor; //Will skip painting the background
  final double? borderWidth; //Will skip painting border
  final AxisDirection? fillDirection;

  _AnimatedRectProgressBarPainter({
    required this.color,
    required this.cornerRadius,
    required this.paintingStyle,
    this.percentage,
    this.height,
    this.width,
    this.clipCornerRadius,
    this.backgroundColor,
    this.borderWidth,
    this.fillDirection,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = paintingStyle
      ..color = color
      ..strokeWidth = borderWidth ?? 0
      ..strokeCap = StrokeCap.round;

    final RRect clipRect = RRect.fromLTRBR(0, 0, width ?? size.width, height ?? size.height, clipCornerRadius ?? Radius.zero);

    if (backgroundColor != null || backgroundColor != Colors.transparent) {
      final backgroundPaint = Paint()
        ..color = backgroundColor!
        ..style = PaintingStyle.fill;
      canvas.drawRRect(clipRect, backgroundPaint);
    }
    if (paintingStyle == PaintingStyle.fill) {
      canvas.clipRRect(clipRect);
    }

    final RRect paintBar;
    if (percentage != null) {
      switch (fillDirection) {
        case AxisDirection.up:
          paintBar = RRect.fromLTRBAndCorners(0, clipRect.height - (clipRect.height * percentage!), clipRect.width, clipRect.height,
            bottomRight: Radius.zero,
            bottomLeft: Radius.zero,
            topLeft: cornerRadius,
            topRight: cornerRadius,
          );
          break;
        case AxisDirection.down:
          paintBar = RRect.fromLTRBAndCorners(0, 0, clipRect.width, clipRect.height * percentage!,
            topRight: Radius.zero,
            topLeft: Radius.zero,
            bottomLeft: cornerRadius,
            bottomRight: cornerRadius,
          );
          break;
        case AxisDirection.left:
          paintBar = RRect.fromLTRBAndCorners(clipRect.width - (clipRect.width * percentage!), 0, clipRect.width, clipRect.height,
            topRight: Radius.zero,
            bottomRight: Radius.zero,
            topLeft: cornerRadius,
            bottomLeft: cornerRadius,
          );
          break;
        default:
          paintBar = RRect.fromLTRBAndCorners(0, 0, clipRect.width * percentage!, clipRect.height,
            topLeft: Radius.zero,
            bottomLeft: Radius.zero,
            bottomRight: cornerRadius,
            topRight: cornerRadius,
          );
          break;
      }

      canvas.drawRRect(paintBar, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    final old = (oldDelegate as _AnimatedRectProgressBarPainter);
    return old.percentage != percentage;
  }
}