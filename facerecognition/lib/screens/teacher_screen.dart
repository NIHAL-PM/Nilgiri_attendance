import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../app/theme.dart';
import '../models/user.dart';
import '../models/event.dart';
import '../services/attendance_service.dart';
import '../widgets/gradient_button.dart';
import '../widgets/glassmorphic_card.dart';

class TeacherScreen extends StatefulWidget {
  final User user;
  const TeacherScreen({super.key, required this.user});

  @override
  State<TeacherScreen> createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
  int _tabIndex = 0;

  // Create Event Form Controllers
  final _titleCtrl = TextEditingController(text: 'Mobile App Development Lecture');
  final _venueCtrl = TextEditingController(text: 'Lab 3, Nilgiri Block B');
  final _targetClassCtrl = TextEditingController(text: 'CS-2026');
  final _latCtrl = TextEditingController(text: '11.0168');
  final _lonCtrl = TextEditingController(text: '76.9558');
  final _radiusCtrl = TextEditingController(text: '50.0');

  bool _isCreating = false;
  bool _isExporting = false;

  List<Map<String, dynamic>> _rosterReport = [
    {
      'student_name': 'Alex Vance',
      'student_email': 'alex.vance@nilgiri.edu',
      'event_title': 'Annual Tech Symposium 2026',
      'similarity': 0.892,
      'distance': '12.4m',
      'status': 'Present',
      'timestamp': '10:14 AM',
    },
    {
      'student_name': 'Sara Connor',
      'student_email': 'sara.c@nilgiri.edu',
      'event_title': 'Annual Tech Symposium 2026',
      'similarity': 0.915,
      'distance': '8.2m',
      'status': 'Present',
      'timestamp': '10:18 AM',
    },
    {
      'student_name': 'David Miller',
      'student_email': 'david.m@nilgiri.edu',
      'event_title': 'Annual Tech Symposium 2026',
      'similarity': 0.640,
      'distance': '14.0m',
      'status': 'Failed (Low Sim)',
      'timestamp': '10:22 AM',
    },
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _venueCtrl.dispose();
    _targetClassCtrl.dispose();
    _latCtrl.dispose();
    _lonCtrl.dispose();
    _radiusCtrl.dispose();
    super.dispose();
  }

  void _createNewEvent() async {
    setState(() => _isCreating = true);
    await Future.delayed(const Duration(milliseconds: 600)); // Simulate API call
    if (!mounted) return;
    setState(() => _isCreating = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Event "${_titleCtrl.text}" created & activated for class ${_targetClassCtrl.text}!'),
        backgroundColor: AppTheme.green,
      ),
    );

    setState(() => _tabIndex = 0);
  }

  void _exportCsvReport() async {
    setState(() => _isExporting = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _isExporting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('CSV Spreadsheet Report generated: PulseAttend_Report_evt_001.csv'),
        backgroundColor: AppTheme.cyan,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      appBar: AppBar(
        title: const Text('👨‍🏫 Teacher Portal'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.cyan.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.cyan.withValues(alpha: 0.4)),
            ),
            child: Center(
              child: Text(
                'Class: ${widget.user.className ?? "CS-2026"}',
                style: const TextStyle(color: AppTheme.cyan, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Tab Navigation Bar
            Container(
              margin: const EdgeInsets.all(AppTheme.spaceLg),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.bgSurface,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  _tabItem(0, 'Class Events', Icons.event),
                  _tabItem(1, 'Create Event', Icons.add_circle_outline),
                  _tabItem(2, 'Roster Report', Icons.people_outline),
                ],
              ),
            ),

            // Tab Views
            Expanded(
              child: IndexedStack(
                index: _tabIndex,
                children: [
                  _buildClassEventsTab(),
                  _buildCreateEventTab(),
                  _buildRosterReportTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabItem(int index, String label, IconData icon) {
    final selected = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? AppTheme.cyan.withValues(alpha: 0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: selected ? Border.all(color: AppTheme.cyan) : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: selected ? AppTheme.cyan : AppTheme.textMuted, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? AppTheme.cyan : AppTheme.textSub,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClassEventsTab() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
      children: [
        const Text('Active Class Sessions', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GlassmorphicCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Annual Tech Symposium 2026', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppTheme.green.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                    child: const Text('ACTIVE NOW', style: TextStyle(color: AppTheme.green, fontSize: 10, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
              const SizedBox(height: 6),
              const Text('Main Auditorium • Target: CS-2026', style: TextStyle(color: AppTheme.textSub, fontSize: 13)),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Check-in Count: 14 Students', style: TextStyle(color: AppTheme.cyan, fontSize: 12, fontWeight: FontWeight.w600)),
                  Text('Geofence: 50m Radius', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCreateEventTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Create New Class Event', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _inputField(_titleCtrl, 'Event Title', Icons.title),
          const SizedBox(height: 12),
          _inputField(_venueCtrl, 'Venue / Classroom Location', Icons.location_on_outlined),
          const SizedBox(height: 12),
          _inputField(_targetClassCtrl, 'Target Class Cohort', Icons.groups_outlined),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _inputField(_latCtrl, 'Venue Latitude', Icons.map_outlined)),
              const SizedBox(width: 10),
              Expanded(child: _inputField(_lonCtrl, 'Venue Longitude', Icons.map_outlined)),
            ],
          ),
          const SizedBox(height: 12),
          _inputField(_radiusCtrl, 'Geofence Radius (Meters)', Icons.radar_outlined),
          const SizedBox(height: 24),
          GradientButton(
            label: 'Create & Activate Event',
            icon: Icons.check_circle_outline,
            isLoading: _isCreating,
            onTap: _createNewEvent,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildRosterReportTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Student Roster', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.cyan.withValues(alpha: 0.2),
                  foregroundColor: AppTheme.cyan,
                  elevation: 0,
                  side: const BorderSide(color: AppTheme.cyan),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: _isExporting
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.cyan))
                    : const Icon(Icons.download, size: 16),
                label: const Text('Export CSV', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                onPressed: _isExporting ? null : _exportCsvReport,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
            itemCount: _rosterReport.length,
            itemBuilder: (context, i) {
              final item = _rosterReport[i];
              final isPresent = item['status'] == 'Present';
              final color = isPresent ? AppTheme.green : AppTheme.red;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(AppTheme.spaceMd),
                decoration: BoxDecoration(
                  color: AppTheme.bgSurface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: color.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: color.withValues(alpha: 0.15),
                      child: Icon(isPresent ? Icons.check : Icons.close, color: color, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['student_name'], style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                          Text(item['student_email'], style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Sim: ${(item['similarity'] * 100).toInt()}%', style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
                        Text('GPS: ${item['distance']}', style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _inputField(TextEditingController controller, String label, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.border),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
          prefixIcon: Icon(icon, color: AppTheme.textMuted, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}
