import 'package:flutter/material.dart';
import '../app/theme.dart';

class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final bool small;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(small ? AppTheme.spaceMd : AppTheme.spaceLg),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: small ? 32 : 40,
            height: small ? 32 : 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Icon(icon, color: color, size: small ? 18 : 22),
          ),
          SizedBox(height: small ? 8 : 12),
          Text(value, style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: small ? 20 : 26,
            fontWeight: FontWeight.bold,
          )),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(
            color: AppTheme.textSub, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
