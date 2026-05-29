import 'package:flutter/widgets.dart';
import 'package:flutter_animate/flutter_animate.dart';

extension FadeInUpX on Widget {
  Widget fadeInUp({
    Duration duration = const Duration(milliseconds: 280),
    Duration delay = Duration.zero,
    double offsetY = 12,
  }) {
    return animate(delay: delay)
        .fadeIn(duration: duration, curve: Curves.easeOutCubic)
        .moveY(
          begin: offsetY,
          end: 0,
          duration: duration,
          curve: Curves.easeOutCubic,
        );
  }
}
