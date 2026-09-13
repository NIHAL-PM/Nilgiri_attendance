import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/app_models.dart';
import '../services/api_service.dart';
import 'attendance_camera_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  final ApiService apiService;
  final UserModel user;

  const DashboardScreen({
    super.key,
    required this.apiService,
    required this.user,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<EventModel> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    setState(() => _isLoading = true);
    try {
      final events = await widget.apiService.getActiveEvents();
      setState(() => _events = events);
    } catch (e) {
      // Fallback display if network issue
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      appBar: AppBar(
        backgroundColor: const Color(0xFF131A2A),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.user.fullName,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              'ID: ${widget.user.studentId} • Verified Biometric',
              style: const TextStyle(color: Color(0xFF05FFA1), fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            onPressed: () async {
              final navigator = Navigator.of(context);
              await widget.apiService.logout();
              if (!mounted) return;
              navigator.pushReplacement(
                MaterialPageRoute(
                    builder: (_) => LoginScreen(apiService: widget.apiService)),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF00F2FE)))
          : RefreshIndicator(
              onRefresh: _fetchEvents,
              color: const Color(0xFF00F2FE),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Biometric Protection Status Banner
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A2639), Color(0xFF131A2A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color:
                              const Color(0xFF00F2FE).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF05FFA1).withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.shield_outlined,
                              color: Color(0xFF05FFA1)),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'On-Device Verification Active',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'MobileFaceNet 512-dim vector matching enabled. Zero photo uploads.',
                                style: TextStyle(
                                    color: Colors.white60, fontSize: 11.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  const Text(
                    'ACTIVE & UPCOMING SESSIONS',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 14),

                  if (_events.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      alignment: Alignment.center,
                      child: const Text('No active events currently available.',
                          style: TextStyle(color: Colors.white54)),
                    )
                  else
                    ..._events.map((evt) => _buildEventCard(evt)),
                ],
              ),
            ),
    );
  }

  Widget _buildEventCard(EventModel event) {
    final dateFormat = DateFormat('hh:mm a, dd MMM');
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF131A2A),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00F2FE).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  event.code,
                  style: const TextStyle(
                      color: Color(0xFF00F2FE),
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ),
              if (event.isGeofenced)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.location_on,
                          color: Colors.orangeAccent, size: 12),
                      SizedBox(width: 4),
                      Text('GPS Geofenced',
                          style: TextStyle(
                              color: Colors.orangeAccent,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            event.name,
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            event.description ?? '',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.place_outlined, color: Colors.white54, size: 16),
              const SizedBox(width: 6),
              Text(event.locationName,
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(width: 16),
              const Icon(Icons.access_time, color: Colors.white54, size: 16),
              const SizedBox(width: 6),
              Text(dateFormat.format(event.startTime),
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00F2FE),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AttendanceCameraScreen(
                      apiService: widget.apiService,
                      event: event,
                      user: widget.user,
                    ),
                  ),
                );
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_outlined,
                      color: Color(0xFF0B0F19), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Mark Attendance (Face Scan)',
                    style: TextStyle(
                        color: Color(0xFF0B0F19),
                        fontWeight: FontWeight.w700,
                        fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
