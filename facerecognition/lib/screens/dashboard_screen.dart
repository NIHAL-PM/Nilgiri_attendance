import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import '../app/theme.dart';
import '../models/user.dart';
import '../models/event.dart';
import '../models/attendance_record.dart';
import '../services/attendance_service.dart';
import '../widgets/stat_card.dart';
import '../widgets/event_card.dart';
import 'scanner_screen.dart';
import 'geofence_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _navIndex = 0;
  final _user = User.demo;
  List<AttendanceRecord>? _history;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final records = await AttendanceService.instance.getHistory(_user.id);
    if (!mounted) return;
    setState(() {
      _history = records;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _DashboardHome(
        user: _user,
        history: _history,
        loading: _loading,
        onMarkAttendance: _goToScanner,
      ),
      const EventsScreen(),
      HistoryScreen(records: _history ?? []),
      ProfileScreen(user: _user),
    ];

    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: pages[_navIndex],
      bottomNavigationBar: _BottomNav(
        current: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }

  void _goToScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GeofenceScreen()),
    );
  }
}

// ---------------------------------------------------------------------------
// Dashboard Home Tab
// ---------------------------------------------------------------------------

class _DashboardHome extends StatelessWidget {
  final User user;
  final List<AttendanceRecord>? history;
  final bool loading;
  final VoidCallback onMarkAttendance;

  const _DashboardHome({
    required this.user,
    required this.history,
    required this.loading,
    required this.onMarkAttendance,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Header
        SliverToBoxAdapter(child: _Header(user: user).animate().fadeIn()),

        // Stats row
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
          sliver: SliverToBoxAdapter(
            child: _StatsRow(user: user)
                .animate(delay: 100.ms)
                .fadeIn()
                .slideY(begin: 0.15),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spaceLg)),

        // Active Event
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionHeader(title: 'Active Event'),
                const SizedBox(height: AppTheme.spaceMd),
                HeroEventCard(
                  event: AttendanceEvent.demoActive,
                  onMarkAttendance: onMarkAttendance,
                ),
              ],
            ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.15),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spaceXl)),

        // Upcoming Events
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
                child: _SectionHeader(title: 'Upcoming Events', action: 'See All'),
              ),
              const SizedBox(height: AppTheme.spaceMd),
              SizedBox(
                height: 148,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
                  itemCount: AttendanceEvent.demoUpcoming.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) =>
                      UpcomingEventCard(event: AttendanceEvent.demoUpcoming[i]),
                ),
              ),
            ],
          ).animate(delay: 300.ms).fadeIn(),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: AppTheme.spaceXl)),

        // Recent Attendance
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionHeader(title: 'Recent Attendance', action: 'All'),
                const SizedBox(height: AppTheme.spaceMd),
                loading
                    ? _ShimmerList()
                    : Column(
                        children: (history ?? [])
                            .take(3)
                            .map((r) => _HistoryTile(record: r))
                            .toList(),
                      ),
              ],
            ).animate(delay: 400.ms).fadeIn(),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Header
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  final User user;
  const _Header({required this.user});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: AppTheme.spaceLg,
        right: AppTheme.spaceLg,
        bottom: AppTheme.spaceLg,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.bgSurface.withValues(alpha: 0.8), Colors.transparent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          // Avatar with verified ring
          Stack(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.cyanGradient,
                  boxShadow: [BoxShadow(
                      color: AppTheme.cyan.withValues(alpha: 0.4), blurRadius: 12)],
                ),
                padding: const EdgeInsets.all(2.5),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(user.avatarUrl),
                ),
              ),
              if (user.isVerified)
                Positioned(
                  right: 0, bottom: 0,
                  child: Container(
                    width: 18, height: 18,
                    decoration: BoxDecoration(
                      color: AppTheme.green, shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.bgDeep, width: 2),
                    ),
                    child: const Icon(Icons.check, color: Colors.black, size: 10),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$greeting,', style: const TextStyle(
                    color: AppTheme.textSub, fontSize: 13)),
                Text(user.name, style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // Notification bell
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: AppTheme.bgSurface,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.border),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.notifications_outlined,
                    color: AppTheme.textPrimary, size: 22),
                Positioned(
                  top: 8, right: 8,
                  child: Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(
                        color: AppTheme.red, shape: BoxShape.circle),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stats Row
// ---------------------------------------------------------------------------

class _StatsRow extends StatelessWidget {
  final User user;
  const _StatsRow({required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: StatCard(
          value: '${user.totalEvents}',
          label: 'Total Events',
          icon: Icons.event_outlined,
          color: AppTheme.cyan,
          small: true,
        )),
        const SizedBox(width: 10),
        Expanded(child: StatCard(
          value: '${user.presentCount}',
          label: 'Present',
          icon: Icons.check_circle_outline,
          color: AppTheme.green,
          small: true,
        )),
        const SizedBox(width: 10),
        Expanded(child: StatCard(
          value: '${user.absentCount}',
          label: 'Absent',
          icon: Icons.cancel_outlined,
          color: AppTheme.red,
          small: true,
        )),
        const SizedBox(width: 10),
        Expanded(child: StatCard(
          value: '${user.currentStreak}d',
          label: 'Streak',
          icon: Icons.local_fire_department_outlined,
          color: AppTheme.gold,
          small: true,
        )),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// History tile
// ---------------------------------------------------------------------------

class _HistoryTile extends StatelessWidget {
  final AttendanceRecord record;
  const _HistoryTile({required this.record});

  @override
  Widget build(BuildContext context) {
    final color = record.isPresent ? AppTheme.green : AppTheme.red;
    final fmt = DateFormat('MMM d, yyyy • hh:mm a');
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              record.isPresent ? Icons.check_circle_outline : Icons.cancel_outlined,
              color: color, size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.eventTitle, style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(fmt.format(record.timestamp), style: const TextStyle(
                    color: AppTheme.textMuted, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: Text(
              '${(record.similarityScore * 100).toInt()}%',
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shimmer placeholder
// ---------------------------------------------------------------------------

class _ShimmerList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.bgSurface,
      highlightColor: AppTheme.bgCard,
      child: Column(
        children: List.generate(3, (_) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          height: 68,
          decoration: BoxDecoration(
            color: AppTheme.bgSurface,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
        )),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Events placeholder screen (Tab 2)
// ---------------------------------------------------------------------------

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(AppTheme.spaceLg),
            sliver: SliverToBoxAdapter(
              child: Text('Events', style: Theme.of(context).textTheme.headlineLarge),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) {
                  final e = AttendanceEvent.demoUpcoming[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    child: UpcomingEventCard(event: e),
                  );
                },
                childCount: AttendanceEvent.demoUpcoming.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  const _SectionHeader({required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        if (action != null)
          Text(action!, style: const TextStyle(
              color: AppTheme.cyan, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom navigation
// ---------------------------------------------------------------------------

class _BottomNav extends StatelessWidget {
  final int current;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        border: Border(top: BorderSide(color: AppTheme.border, width: 1)),
      ),
      child: SafeArea(
        child: BottomNavigationBar(
          currentIndex: current,
          onTap: onTap,
          backgroundColor: Colors.transparent,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_outlined),
              activeIcon: Icon(Icons.event),
              label: 'Events',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
