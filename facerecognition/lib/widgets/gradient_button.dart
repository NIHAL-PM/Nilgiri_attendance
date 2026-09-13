import 'package:flutter/material.dart';
import '../app/theme.dart';

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final IconData? icon;
  final LinearGradient? gradient;
  final Color? solidColor;
  final Color? textColor;
  final double height;

  const GradientButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.icon,
    this.gradient,
    this.solidColor,
    this.textColor,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          gradient: onTap != null ? (gradient ?? AppTheme.cyanGradient) : null,
          color: onTap == null ? AppTheme.bgCard : solidColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          boxShadow: onTap != null
              ? [BoxShadow(
                  color: AppTheme.cyan.withValues(alpha: 0.3),
                  blurRadius: 20, spreadRadius: 0, offset: const Offset(0, 4))]
              : [],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white))
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[Icon(icon, color: textColor ?? Colors.black, size: 20), const SizedBox(width: 8)],
                    Text(label, style: TextStyle(
                      color: onTap != null ? (textColor ?? Colors.black) : AppTheme.textMuted,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    )),
                  ],
                ),
        ),
      ),
    );
  }
}

class OutlineButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color borderColor;
  final Color textColor;
  final IconData? icon;
  final double height;

  const OutlineButton({
    super.key,
    required this.label,
    this.onTap,
    this.borderColor = AppTheme.cyan,
    this.textColor = AppTheme.cyan,
    this.icon,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(color: borderColor, width: 1.5),
          color: borderColor.withValues(alpha: 0.08),
        ),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, color: textColor, size: 20), const SizedBox(width: 8)],
              Text(label, style: TextStyle(
                color: textColor, fontSize: 15, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
