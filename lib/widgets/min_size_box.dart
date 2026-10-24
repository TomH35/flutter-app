import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Lays out [child] at least at [minSize] and clips whatever does not fit.
/// Prevents overflow errors when a window is resized to almost nothing
/// (e.g. a browser window while opening DevTools).
class MinSizeBox extends StatelessWidget {
  const MinSizeBox({
    super.key,
    this.minSize = const Size(320, 300),
    required this.child,
  });

  final Size minSize;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= minSize.width &&
            constraints.maxHeight >= minSize.height) {
          return child;
        }

        final width = math.max(constraints.maxWidth, minSize.width);
        final height = math.max(constraints.maxHeight, minSize.height);

        return ClipRect(
          child: OverflowBox(
            alignment: Alignment.topLeft,
            minWidth: width,
            maxWidth: width,
            minHeight: height,
            maxHeight: height,
            child: child,
          ),
        );
      },
    );
  }
}
