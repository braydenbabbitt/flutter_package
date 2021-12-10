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

    if (backgroundColor != null || backgroundColor != Colors.transparent) {
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
    final old = (oldDelegate as AnimatedLinearProgressBarPainter);
    return old.percentage != percentage;
  }
}