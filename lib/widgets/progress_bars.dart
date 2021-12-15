import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// AnimatedRectProgressBar V1.0
// version ideas:
//   V2.0 Add gradient dependent on percentage fill
class AnimatedRectProgressBar extends StatefulWidget {
  //Required properties
  final double value;
  final Color fillColor;

  //Optional properties -- Defaults
  final Radius outerCornerRadius; //Radius.zero
  final Radius innerCornerRadius; //Radius.zero
  final Color backgroundColor; //Colors.transparent
  final Curve animationCurve; //Curves.easeInOut
  final Duration animationDuration; //Duration(milliseconds: 500)
  final AxisDirection fillDirection; //AxisDirection.right

  //Nullable properties -- Behavior if null
  final double? height; //Will assume height of container
  final double? width; //Will assume width of container
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
    this.backgroundColor = Colors.transparent,
    this.animationCurve = Curves.easeInOut,
    this.animationDuration = const Duration(milliseconds: 500),
    this.fillDirection = AxisDirection.right,
    this.height,
    this.width,
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
    return SizedBox(
        height: widget.height,
        width: widget.width,
        child: AnimatedBuilder(
          animation: _curvedAnimation,
          child: (widget.displayText != null) ? Center(
            heightFactor: widget.height,
            widthFactor: widget.width,
            child: Text(
              widget.displayText!,
              style: widget.textStyle,
            ),
          ) : null,
          builder: (context, child) {
            return CustomPaint(
              child: child,
              painter: _AnimatedRectProgressBarPainter(
                percentage: _valueTween.evaluate(_curvedAnimation),
                color: widget.fillColor,
                cornerRadius: widget.innerCornerRadius,
                paintingStyle: PaintingStyle.fill,
                backgroundColor: widget.backgroundColor,
                fillDirection: widget.fillDirection,
                height: widget.height,
                width: widget.width,
                clipCornerRadius: widget.outerCornerRadius,
                borderWidth: widget.borderWidth,
              ),
              foregroundPainter: (widget.borderColor == null || widget.borderWidth == null) ? null : _AnimatedRectProgressBarPainter(
                color: widget.borderColor!,
                cornerRadius: widget.outerCornerRadius,
                paintingStyle: PaintingStyle.stroke,
                height: widget.height,
                width: widget.width,
                borderWidth: widget.borderWidth,
              ),
            );
          },
        )
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

  //Optional properties -- Default value
  final Color backgroundColor; //Colors.transparent

  //Nullable properties -- Behavior if null
  final double? percentage;
  final double? height; //Will default to paint size.height property
  final double? width; //Will default to paint size.width property
  final Radius? clipCornerRadius; //Will default to Radius.zero
  final double? borderWidth; //Will skip painting border
  final AxisDirection? fillDirection;

  _AnimatedRectProgressBarPainter({
    required this.color,
    required this.cornerRadius,
    required this.paintingStyle,
    this.backgroundColor = Colors.transparent,
    this.percentage,
    this.height,
    this.width,
    this.clipCornerRadius,
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

    final temp = backgroundColor;
    if (temp != Colors.transparent) {
      final backgroundPaint = Paint()
        ..color = temp
        ..style = PaintingStyle.fill;
      canvas.drawRRect(clipRect, backgroundPaint);
    }

    final RRect paintBar;
    if (paintingStyle == PaintingStyle.fill) {
      canvas.clipRRect(clipRect);
      switch (fillDirection) {
        case AxisDirection.up:
          paintBar = RRect.fromLTRBAndCorners(0, clipRect.height - (clipRect.height * (percentage ?? 0)), clipRect.width, clipRect.height,
            bottomRight: Radius.zero,
            bottomLeft: Radius.zero,
            topLeft: cornerRadius,
            topRight: cornerRadius,
          );
          break;
        case AxisDirection.down:
          paintBar = RRect.fromLTRBAndCorners(0, 0, clipRect.width, clipRect.height * (percentage ?? 0),
            topRight: Radius.zero,
            topLeft: Radius.zero,
            bottomLeft: cornerRadius,
            bottomRight: cornerRadius,
          );
          break;
        case AxisDirection.left:
          paintBar = RRect.fromLTRBAndCorners(clipRect.width - (clipRect.width * (percentage ?? 0)), 0, clipRect.width, clipRect.height,
            topRight: Radius.zero,
            bottomRight: Radius.zero,
            topLeft: cornerRadius,
            bottomLeft: cornerRadius,
          );
          break;
        default:
          paintBar = RRect.fromLTRBAndCorners(0, 0, clipRect.width * (percentage ?? 0), clipRect.height,
            topLeft: Radius.zero,
            bottomLeft: Radius.zero,
            bottomRight: cornerRadius,
            topRight: cornerRadius,
          );
          break;
      }
    } else {
      paintBar = RRect.fromLTRBR(0, 0, width ?? size.width, height ?? size.height, cornerRadius);
    }

    canvas.drawRRect(paintBar, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    final old = (oldDelegate as _AnimatedRectProgressBarPainter);
    return old.percentage != percentage;
  }
}