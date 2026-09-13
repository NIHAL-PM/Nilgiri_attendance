import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../models/user.dart';
import '../widgets/stat_card.dart';
import '../widgets/painters.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'registration_screen.dart';

class ProfileScreen extends StatefulWidget {
  final User user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _biometricsEnabled = true;
  bool _notificationsEnabled = true;
  bool _locationTracking = true;

  @override
  Widget build(BuildContext context) {
    final u = widget.user;

    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Top Profile Header Card
            SliverPadding(
              padding: const EdgeInsets.all(AppTheme.spaceLg),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppTheme.cyanGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.cyan.withValues(alpha: 0.35),
                                blurRadius: 20,
                              )
                            ],
                          ),
                          padding: const EdgeInsets.all(3),
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(u.avatarUrl),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(u.name,
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 4),
                    Text(u.email,
                        style: const TextStyle(
                            color: AppTheme.textSub, fontSize: 13)),
                    const SizedBox(height: 10),

                    // Verified Badge Chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.green.withValues(alpha: 0.12),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusFull),
                        border: Border.all(
                            color: AppTheme.green.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified,
                              color: AppTheme.green, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            u.isVerified
                                ? 'Neural Biometrics Verified'
                                : 'Baseline Needed',
                            style: const TextStyle(
                              color: AppTheme.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Performance Bar Chart Section
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
              sliver: SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(AppTheme.spaceLg),
                  decoration: BoxDecoration(
                    color: AppTheme.bgSurface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Last 7 Days Activity',
                              style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold)),
                          Text(
                              'Rate: ${(u.attendanceRate * 100).toInt()}%',
                              style: const TextStyle(
                                  color: AppTheme.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const SizedBox(
                        height: 70,
                        width: double.infinity,
                        child: CustomPaint(
                          painter: WeeklyBarPainter(
                              days: [true, true, true, false, true, true, true]),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Mon',
                              style: TextStyle(
                                  color: AppTheme.textMuted, fontSize: 11)),
                          Text('Tue',
                              style: TextStyle(
                                  color: AppTheme.textMuted, fontSize: 11)),
                          Text('Wed',
                              style: TextStyle(
                                  color: AppTheme.textMuted, fontSize: 11)),
                          Text('Thu',
                              style: TextStyle(
                                  color: AppTheme.textMuted, fontSize: 11)),
                          Text('Fri',
                              style: TextStyle(
                                  color: AppTheme.textMuted, fontSize: 11)),
                          Text('Sat',
                              style: TextStyle(
                                  color: AppTheme.textMuted, fontSize: 11)),
                          Text('Sun',
                              style: TextStyle(
                                  color: AppTheme.textMuted, fontSize: 11)),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spaceLg)),

            // Stats Metrics Row
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        value: '${(u.accuracyScore * 100).toStringAsFixed(1)}%',
                        label: 'Match Accuracy',
                        icon: Icons.psychology_outlined,
                        color: AppTheme.cyan,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        value: '${u.currentStreak} Days',
                        label: 'Best Streak',
                        icon: Icons.local_fire_department_outlined,
                        color: AppTheme.gold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spaceLg)),

            // Settings & Actions Section
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
              sliver: SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.bgSurface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.face, color: AppTheme.cyan),
                        title: const Text('Re-register Biometric Baseline',
                            style: TextStyle(
                                color: AppTheme.textPrimary, fontSize: 14)),
                        trailing: const Icon(Icons.arrow_forward_ios,
                            color: AppTheme.textMuted, size: 14),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const RegistrationScreen()),
                          );
                        },
                      ),
                      const Divider(height: 1, color: AppTheme.border),
                      SwitchListTile(
                        activeColor: AppTheme.cyan,
                        secondary: const Icon(Icons.fingerprint,
                            color: AppTheme.green),
                        title: const Text('Require Biometrics on Launch',
                            style: TextStyle(
                                color: AppTheme.textPrimary, fontSize: 14)),
                        value: _biometricsEnabled,
                        onChanged: (v) =>
                            setState(() => _biometricsEnabled = v),
                      ),
                      const Divider(height: 1, color: AppTheme.border),
                      SwitchListTile(
                        activeColor: AppTheme.cyan,
                        secondary: const Icon(Icons.notifications_outlined,
                            color: AppTheme.gold),
                        title: const Text('Event Reminders & Alerts',
                            style: TextStyle(
                                color: AppTheme.textPrimary, fontSize: 14)),
                        value: _notificationsEnabled,
                        onChanged: (v) =>
                            setState(() => _notificationsEnabled = v),
                      ),
                      const Divider(height: 1, color: AppTheme.border),
                      SwitchListTile(
                        activeColor: AppTheme.cyan,
                        secondary: const Icon(Icons.location_on_outlined,
                            color: AppTheme.blue),
                        title: const Text('Automated Geofence Checks',
                            style: TextStyle(
                                color: AppTheme.textPrimary, fontSize: 14)),
                        value: _locationTracking,
                        onChanged: (v) =>
                            setState(() => _locationTracking = v),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spaceLg)),

            // Logout Button
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
              sliver: SliverToBoxAdapter(
                child: GestureDetector(
                  onTap: () async {
                    await AuthService.instance.logout();
                    if (!mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (_) => false,
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      border: Border.all(
                          color: AppTheme.red.withValues(alpha: 0.4)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, color: AppTheme.red, size: 18),
                        SizedBox(width: 8),
                        Text('Sign Out',
                            style: TextStyle(
                                color: AppTheme.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 60)),
          ],
        ),
      ),
    );
  }
}
