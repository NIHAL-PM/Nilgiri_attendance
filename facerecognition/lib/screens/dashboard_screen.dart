import 'dart:ui';
import 'package:flutter/material.dart';
import 'scanner_screen.dart';
import 'painters.dart';

/// The main dashboard shown after successful login or face registration.
/// Displays the active event hero card, upcoming events, and attendance history.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Profile Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF00FF87), width: 2),
                          image: const DecorationImage(
                            image: NetworkImage('https://i.pravatar.cc/150?img=33'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Alex Vance', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('Identity Verified • 14 Events', style: TextStyle(color: Color(0xFF00FF87), fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.location_on_outlined, color: Color(0xFF00F2FE)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const GeofenceScreen()),
                          );
                        },
                      ),
                      const Icon(Icons.notifications_outlined, color: Colors.white),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              const Text('Active Event', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              // Active Event Hero Glassmorphic Card
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141722).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF00F2FE),
                                boxShadow: [BoxShadow(color: Color(0xFF00F2FE), blurRadius: 10)],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'HAPPENING NOW',
                              style: TextStyle(color: Color(0xFF00F2FE), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text('Annual Tech Symposium 2026', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text(
                          'Main Auditorium, Block C\n10:00 AM - 01:00 PM',
                          style: TextStyle(color: Color(0xFF8E95A5), fontSize: 14, height: 1.5),
                        ),
                        const SizedBox(height: 24),

                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const ScannerScreen()));
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00F2FE).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFF00F2FE)),
                            ),
                            child: const Center(
                              child: Text(
                                'Mark Attendance Now',
                                style: TextStyle(color: Color(0xFF00F2FE), fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Upcoming Events Horizontal Section
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Upcoming Events', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('See All', style: TextStyle(color: Color(0xFF8E95A5), fontSize: 14)),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 140,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildUpcomingCard('AI & Neural Net Workshop', 'Tomorrow • 02:00 PM', 'Lab 4, Innovation Wing'),
                    const SizedBox(width: 16),
                    _buildUpcomingCard('Cybersecurity Hackathon', 'Sep 18 • 09:00 AM', 'Central Seminar Hall'),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Attendance History Section
              const Text('Attendance History', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildHistoryTile('DevOps & Cloud Masterclass', 'Sep 10, 2026 • 11:30 AM', 'Cosine Similarity: 0.91'),
              _buildHistoryTile('Orientation & Kickoff 2026', 'Sep 02, 2026 • 09:00 AM', 'Cosine Similarity: 0.88'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingCard(String title, String time, String location) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF141722),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(time, style: const TextStyle(color: Color(0xFF00F2FE), fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(location, style: const TextStyle(color: Color(0xFF8E95A5), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildHistoryTile(String title, String timestamp, String score) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141722).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00FF87).withValues(alpha: 0.1),
                ),
                child: const Icon(Icons.check_circle_outline, color: Color(0xFF00FF87), size: 22),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(timestamp, style: const TextStyle(color: Color(0xFF8E95A5), fontSize: 12)),
                ],
              ),
            ],
          ),
          Text(score, style: const TextStyle(color: Color(0xFF00FF87), fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

/// Shows the geofence proximity map and allows the user to proceed
/// to the scanner only when inside the event zone.
class GeofenceScreen extends StatefulWidget {
  const GeofenceScreen({super.key});

  @override
  State<GeofenceScreen> createState() => _GeofenceScreenState();
}

class _GeofenceScreenState extends State<GeofenceScreen> {
  bool _isInsideZone = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090A0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('📍 Geofence Check', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Simulated Vector Map
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF141722),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Grid map lines
                      CustomPaint(
                        painter: MapGridPainter(),
                        size: Size.infinite,
                      ),

                      // 50m radius geofence circle
                      Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF00F2FE).withValues(alpha: 0.1),
                          border: Border.all(color: const Color(0xFF00F2FE), width: 2),
                          boxShadow: [
                            BoxShadow(color: const Color(0xFF00F2FE).withValues(alpha: 0.2), blurRadius: 20),
                          ],
                        ),
                      ),

                      // User location dot
                      AnimatedAlign(
                        duration: const Duration(milliseconds: 500),
                        alignment: _isInsideZone ? Alignment.center : const Alignment(0.7, 0.7),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isInsideZone ? const Color(0xFF00FF87) : const Color(0xFFFF0844),
                            boxShadow: [
                              BoxShadow(
                                color: _isInsideZone ? const Color(0xFF00FF87) : const Color(0xFFFF0844),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Distance & zone information card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF141722),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isInsideZone ? Icons.verified_user_outlined : Icons.gpp_bad_outlined,
                      color: _isInsideZone ? const Color(0xFF00FF87) : const Color(0xFFFF0844),
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isInsideZone ? 'Inside Zone (12m away)' : 'Outside Zone (120m away)',
                            style: TextStyle(
                              color: _isInsideZone ? const Color(0xFF00FF87) : const Color(0xFFFF0844),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isInsideZone
                                ? 'You are within the 50m radius of Main Auditorium.'
                                : 'Move closer to the event venue to unlock check-in.',
                            style: const TextStyle(color: Color(0xFF8E95A5), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Toggle zone simulation + proceed button
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isInsideZone = !_isInsideZone;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: const Icon(Icons.swap_horiz, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: _isInsideZone
                          ? () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const ScannerScreen()),
                              );
                            }
                          : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: _isInsideZone ? const Color(0xFF00F2FE) : const Color(0xFF141722),
                        ),
                        child: Center(
                          child: Text(
                            'Proceed to Camera Scan',
                            style: TextStyle(
                              color: _isInsideZone ? Colors.black : const Color(0xFF8E95A5),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Draws a subtle grid over the geofence map background.
class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1.0;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
