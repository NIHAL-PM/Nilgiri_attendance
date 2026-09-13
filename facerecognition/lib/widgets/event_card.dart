import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../app/theme.dart';
import '../models/event.dart';

class HeroEventCard extends StatelessWidget {
  final AttendanceEvent event;
  final VoidCallback? onMarkAttendance;

  const HeroEventCard({
    super.key,
    required this.event,
    this.onMarkAttendance,
  });

  @override
  Widget build(BuildContext context) {
    final timeFmt = DateFormat('hh:mm a');
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spaceLg),
          decoration: BoxDecoration(
            color: AppTheme.bgSurface.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10, height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.cyan,
                      boxShadow: [BoxShadow(color: AppTheme.cyan.withValues(alpha: 0.6), blurRadius: 8, spreadRadius: 2)],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('HAPPENING NOW', style: TextStyle(
                    color: AppTheme.cyan, fontSize: 11,
                    fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                ],
              ),
              const SizedBox(height: 14),
              Text(event.title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: AppTheme.textSub, size: 14),
                  const SizedBox(width: 4),
                  Text(event.venue, style: const TextStyle(color: AppTheme.textSub, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.schedule_outlined, color: AppTheme.textSub, size: 14),
                  const SizedBox(width: 4),
                  Text('${timeFmt.format(event.startTime)} – ${timeFmt.format(event.endTime)}',
                      style: const TextStyle(color: AppTheme.textSub, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: onMarkAttendance,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: AppTheme.cyanGradient,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    boxShadow: [BoxShadow(color: AppTheme.cyan.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0,4))],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.face_retouching_natural, color: Colors.black, size: 20),
                      SizedBox(width: 8),
                      Text('Mark Attendance Now', style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UpcomingEventCard extends StatelessWidget {
  final AttendanceEvent event;
  const UpcomingEventCard({super.key, required this.event});

  Color get _accentColor {
    switch (event.imageTag) {
      case 'green': return AppTheme.green;
      case 'red':   return AppTheme.red;
      case 'gold':  return AppTheme.gold;
      default:      return AppTheme.cyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('MMM d • hh:mm a');
    return Container(
      width: 230,
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: _accentColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: _accentColor),
          ),
          const SizedBox(height: 10),
          Text(event.title, style: const TextStyle(
            color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
            maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Text(dateFmt.format(event.startTime), style: TextStyle(
            color: _accentColor, fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(event.venue, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
            maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
