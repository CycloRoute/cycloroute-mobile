import 'package:flutter/material.dart';
import 'package:cyclerisk/core/theme/app_colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final double elevation;
  final BorderRadius borderRadius;

  const AppCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.elevation = 0,
    BorderRadius? borderRadius,
  }) : borderRadius =
           borderRadius ?? const BorderRadius.all(Radius.circular(12)),
       super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardBackground,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
