import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:math' as math;

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const PulseAttendApp());
}

class PulseAttendApp extends StatelessWidget {
  const PulseAttendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PulseAttend',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF090A0F),
        primaryColor: const Color(0xFF00F2FE),
        fontFamily: 'Inter', // Assuming standard sans-serif fallback
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: Color(0xFF8E95A5)),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background animated floating nodes
          AnimatedBuilder(
            animation: _floatController,
            builder: (context, child) {
              return Stack(
                children: [
                  _buildFloatingNode(top: 150 + (_floatController.value * 20), left: 50, color: const Color(0xFF00FF87), icon: Icons.fingerprint),
                  _buildFloatingNode(top: 250 - (_floatController.value * 15), left: 280, color: const Color(0xFF4FACFE), icon: Icons.person_outline),
                  _buildFloatingNode(top: 400 + (_floatController.value * 10), left: 80, color: const Color(0xFFFF0844), icon: Icons.camera_alt_outlined),
                ],
              );
            },
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    'PulseAttend',
                    style: TextStyle(fontSize: 42, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Verify identity with zero friction.\nSecure event check-ins powered by client-side neural biometrics.',
                    style: TextStyle(fontSize: 16, color: Color(0xFF8E95A5), height: 1.5),
                  ),
                  const SizedBox(height: 36),
                  
                  // Login Button
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const DashboardScreen()),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: const Color(0xFF00F2FE).withValues(alpha: 0.5), width: 1.5),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF141722), Color(0xFF090A0F)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00F2FE).withValues(alpha: 0.2),
                            blurRadius: 15,
                            spreadRadius: 2,
                          )
                        ]
                      ),
                      child: const Center(
                        child: Text(
                          'Log In with Credentials',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  
                  // One-time Face Registration Shortcut
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.white.withValues(alpha: 0.05),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      child: const Center(
                        child: Text(
                          'Register Face Baseline (First Time)',
                          style: TextStyle(color: Color(0xFF00F2FE), fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'Need help?',
                      style: TextStyle(color: Color(0xFF8E95A5), fontSize: 14, decoration: TextDecoration.underline),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingNode({required double top, required double left, required Color color, required IconData icon}) {
    return Positioned(
      top: top,
      left: left,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 15, spreadRadius: 5)
          ]
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  int _stepIndex = 0;
  final List<String> _prompts = [
    'Center your face in the oval',
    'Blink both eyes now',
    'Hold still... Extracting features'
  ];
  Color _ellipseColor = const Color(0xFFFEE140);

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addListener(() {
        setState(() {
          if (_progressController.value > 0.33 && _stepIndex == 0) {
            _stepIndex = 1;
            _ellipseColor = const Color(0xFF00F2FE);
          } else if (_progressController.value > 0.66 && _stepIndex == 1) {
            _stepIndex = 2;
            _ellipseColor = const Color(0xFF00FF87);
          }
        });
      });
    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090A0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Face Registration', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF00F2FE).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF00F2FE).withValues(alpha: 0.4)),
            ),
            child: const Center(
              child: Text('Step 1 of 2', style: TextStyle(color: Color(0xFF00F2FE), fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Dynamic Dynamic Liveness Banner
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF141722),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _ellipseColor.withValues(alpha: 0.5)),
                  boxShadow: [BoxShadow(color: _ellipseColor.withValues(alpha: 0.2), blurRadius: 10)]
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.face, color: _ellipseColor, size: 20),
                    const SizedBox(width: 10),
                    Text(_prompts[_stepIndex], style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const Spacer(),

              // Oval Camera Frame Viewport
              Center(
                child: Container(
                  width: 260,
                  height: 350,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.elliptical(130, 175)),
                    border: Border.all(color: _ellipseColor, width: 3),
                    gradient: const RadialGradient(
                      colors: [Color(0xFF2A2D3E), Colors.black],
                      radius: 1.0,
                    ),
                    boxShadow: [BoxShadow(color: _ellipseColor.withValues(alpha: 0.3), blurRadius: 25)],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(Icons.person, color: Color(0xFF8E95A5), size: 140),
                      Positioned(
                        bottom: 20,
                        child: AnimatedBuilder(
                          animation: _progressController,
                          builder: (context, child) {
                            return Text(
                              '${(_progressController.value * 100).toInt()}%',
                              style: TextStyle(color: _ellipseColor, fontSize: 20, fontWeight: FontWeight.bold),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const Spacer(),

              // Submit Baseline Button
              GestureDetector(
                onTap: _progressController.isCompleted
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Biometric Baseline Saved Successfully!'),
                            backgroundColor: Color(0xFF00FF87),
                          ),
                        );
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const DashboardScreen()));
                      }
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: _progressController.isCompleted ? const Color(0xFF00FF87) : const Color(0xFF141722),
                    boxShadow: _progressController.isCompleted
                        ? [const BoxShadow(color: Color(0xFF00FF87), blurRadius: 15)]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      'Register Baseline Biometrics',
                      style: TextStyle(
                        color: _progressController.isCompleted ? Colors.black : const Color(0xFF8E95A5),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
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
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const GeofenceScreen()));
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
                                boxShadow: [BoxShadow(color: Color(0xFF00F2FE), blurRadius: 10)]
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('HAPPENING NOW', style: TextStyle(color: Color(0xFF00F2FE), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text('Annual Tech Symposium 2026', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text('Main Auditorium, Block C\n10:00 AM - 01:00 PM', style: TextStyle(color: Color(0xFF8E95A5), fontSize: 14, height: 1.5)),
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
                              child: Text('Mark Attendance Now', style: TextStyle(color: Color(0xFF00F2FE), fontWeight: FontWeight.bold)),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Upcoming Events Horizontal Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
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
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
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

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with TickerProviderStateMixin {
  late AnimationController _scannerController;
  late AnimationController _progressController;
  int _progressPercentage = 0;
  bool _simulateSuccess = true; // Toggle for testing success vs failure modal

  @override
  void initState() {
    super.initState();
    _scannerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward().then((_) {
        if (_simulateSuccess) {
          _showVerificationResult();
        } else {
          _showFailureResult();
        }
      });

    _progressController.addListener(() {
      setState(() {
        _progressPercentage = (_progressController.value * 100).toInt();
      });
    });
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _showVerificationResult() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      isDismissible: false,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF141722).withValues(alpha: 0.8),
                border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF00FF87).withValues(alpha: 0.1),
                      boxShadow: [BoxShadow(color: const Color(0xFF00FF87).withValues(alpha: 0.3), blurRadius: 20)],
                    ),
                    child: const Icon(Icons.check_circle, color: Color(0xFF00FF87), size: 50),
                  ),
                  const SizedBox(height: 24),
                  const Text('Attendance Recorded!', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text('Alex Vance (ID: #9021)\nCosine Similarity = 0.892\n10:14:02 AM | Sep 13, 2026', 
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF8E95A5), fontSize: 14, height: 1.5)
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Close modal
                      Navigator.pop(context); // Go back to dashboard
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Center(
                        child: Text('Return to Dashboard', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFailureResult() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      isDismissible: false,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF141722).withValues(alpha: 0.9),
                border: Border(top: BorderSide(color: const Color(0xFFFF0844).withValues(alpha: 0.3))),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFF0844).withValues(alpha: 0.1),
                      boxShadow: [BoxShadow(color: const Color(0xFFFF0844).withValues(alpha: 0.3), blurRadius: 20)],
                    ),
                    child: const Icon(Icons.cancel, color: Color(0xFFFF0844), size: 50),
                  ),
                  const SizedBox(height: 24),
                  const Text('Verification Unsuccessful', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text(
                    'Biometric similarity threshold not met (0.68 < 0.75).\nPlease ensure proper lighting and remove heavy face coverings.', 
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF8E95A5), fontSize: 14, height: 1.5)
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            _progressController.reset();
                            _progressController.forward();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF0844).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: const Color(0xFFFF0844)),
                            ),
                            child: const Center(
                              child: Text('Retry Scan', style: TextStyle(color: Color(0xFFFF0844), fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Center(
                              child: Text('Cancel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Simulated Camera Background
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0xFF2A2D3E), Colors.black],
                radius: 1.2,
                center: Alignment.center,
              )
            ),
          ),
          
          // Face Mesh and Radar Lines Painter
          AnimatedBuilder(
            animation: _scannerController,
            builder: (context, child) {
              return CustomPaint(
                painter: FaceScannerPainter(scanValue: _scannerController.value),
                size: Size.infinite,
              );
            },
          ),
          
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text('Verification', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                
                // Simulation outcome switcher
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _simulateSuccess = !_simulateSuccess;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: (_simulateSuccess ? const Color(0xFF00FF87) : const Color(0xFFFF0844)).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _simulateSuccess ? 'Sim: Pass' : 'Sim: Fail',
                      style: TextStyle(color: _simulateSuccess ? const Color(0xFF00FF87) : const Color(0xFFFF0844), fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            ),
          ),
          
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: CustomPaint(
                painter: CircularProgressPainter(progress: _progressController.value),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: Center(
                    child: Text(
                      '$_progressPercentage%',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

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
                      // Grid Map Lines
                      CustomPaint(
                        painter: MapGridPainter(),
                        size: Size.infinite,
                      ),
                      
                      // 50m Radius Geofence Circle
                      Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF00F2FE).withValues(alpha: 0.1),
                          border: Border.all(color: const Color(0xFF00F2FE), width: 2),
                          boxShadow: [BoxShadow(color: const Color(0xFF00F2FE).withValues(alpha: 0.2), blurRadius: 20)],
                        ),
                      ),
                      
                      // User Location Dot
                      AnimatedAlign(
                        duration: const Duration(milliseconds: 500),
                        alignment: _isInsideZone ? Alignment.center : const Alignment(0.7, 0.7),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isInsideZone ? const Color(0xFF00FF87) : const Color(0xFFFF0844),
                            boxShadow: [BoxShadow(color: _isInsideZone ? const Color(0xFF00FF87) : const Color(0xFFFF0844), blurRadius: 10)],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Distance & Zone Information Card
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

              // Toggle Zone Simulation CTA & Proceed Button
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
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ScannerScreen()));
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
              )
            ],
          ),
        ),
      ),
    );
  }
}

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

  Widget _buildFloatingNode({required double top, required double left, required Color color, required IconData icon}) {
    return Positioned(
      top: top,
      left: left,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 15, spreadRadius: 5)
          ]
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}

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
              // Header
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Alex Vance', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('Identity Verified • 14 Events', style: TextStyle(color: Color(0xFF00FF87), fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const Icon(Icons.notifications_outlined, color: Colors.white),
                ],
              ),
              const SizedBox(height: 40),
              
              const Text('Active Event', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
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
                                boxShadow: [BoxShadow(color: Color(0xFF00F2FE), blurRadius: 10)]
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('HAPPENING NOW', style: TextStyle(color: Color(0xFF00F2FE), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text('Annual Tech Symposium 2026', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        const Text('Main Auditorium, Block C\n10:00 AM - 01:00 PM', style: TextStyle(color: Color(0xFF8E95A5), fontSize: 14, height: 1.5)),
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
                              child: Text('Mark Attendance Now', style: TextStyle(color: Color(0xFF00F2FE), fontWeight: FontWeight.bold)),
                            ),
                          ),
                        )
                      ],
                    ),
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

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with TickerProviderStateMixin {
  late AnimationController _scannerController;
  late AnimationController _progressController;
  int _progressPercentage = 0;

  @override
  void initState() {
    super.initState();
    // Radar line sweeping down
    _scannerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Percentage loading up to 100%
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward().then((_) => _showVerificationResult());

    _progressController.addListener(() {
      setState(() {
        _progressPercentage = (_progressController.value * 100).toInt();
      });
    });
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _showVerificationResult() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      isDismissible: false,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF141722).withValues(alpha: 0.8),
                border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF00FF87).withValues(alpha: 0.1),
                      boxShadow: [BoxShadow(color: const Color(0xFF00FF87).withValues(alpha: 0.3), blurRadius: 20)],
                    ),
                    child: const Icon(Icons.check_circle, color: Color(0xFF00FF87), size: 50),
                  ),
                  const SizedBox(height: 24),
                  const Text('Attendance Recorded!', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Text('Alex Vance (ID: #9021)\nCosine Similarity = 0.892\n10:14:02 AM | Sep 13, 2026', 
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF8E95A5), fontSize: 14, height: 1.5)
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Close modal
                      Navigator.pop(context); // Go back to dashboard
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Center(
                        child: Text('Return to Dashboard', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Simulated Camera Background (Dark Vignette Gradient for mock)
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0xFF2A2D3E), Colors.black],
                radius: 1.2,
                center: Alignment.center,
              )
            ),
          ),
          
          // Custom Painter for Face Mesh, Bounding Box, and Radar
          AnimatedBuilder(
            animation: _scannerController,
            builder: (context, child) {
              return CustomPaint(
                painter: FaceScannerPainter(scanValue: _scannerController.value),
                size: Size.infinite,
              );
            },
          ),
          
          const Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Verification',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: 1.0),
              ),
            ),
          ),
          
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: CustomPaint(
                painter: CircularProgressPainter(progress: _progressController.value),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: Center(
                    child: Text(
                      '$_progressPercentage%',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class FaceScannerPainter extends CustomPainter {
  final double scanValue;

  FaceScannerPainter({required this.scanValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 - 50);
    final rectWidth = size.width * 0.7;
    final rectHeight = size.height * 0.45;
    final rect = Rect.fromCenter(center: center, width: rectWidth, height: rectHeight);

    // 1. Draw Corner Brackets (Target Face Boundary)
    final bracketPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final double length = 30.0;
    
    // Top Left
    canvas.drawLine(rect.topLeft, rect.topLeft + Offset(length, 0), bracketPaint);
    canvas.drawLine(rect.topLeft, rect.topLeft + Offset(0, length), bracketPaint);
    // Top Right
    canvas.drawLine(rect.topRight, rect.topRight + Offset(-length, 0), bracketPaint);
    canvas.drawLine(rect.topRight, rect.topRight + Offset(0, length), bracketPaint);
    // Bottom Left
    canvas.drawLine(rect.bottomLeft, rect.bottomLeft + Offset(length, 0), bracketPaint);
    canvas.drawLine(rect.bottomLeft, rect.bottomLeft + Offset(0, -length), bracketPaint);
    // Bottom Right
    canvas.drawLine(rect.bottomRight, rect.bottomRight + Offset(-length, 0), bracketPaint);
    canvas.drawLine(rect.bottomRight, rect.bottomRight + Offset(0, -length), bracketPaint);

    // 2. Mock Facial Landmarks inside the box
    final nodePaint = Paint()..color = Colors.white..style = PaintingStyle.fill;
    final linePaint = Paint()..color = Colors.white.withValues(alpha: 0.3)..style = PaintingStyle.stroke..strokeWidth = 1.0;
    
    final nodes = [
      center + const Offset(-40, -30), // Left Eye
      center + const Offset(40, -30),  // Right Eye
      center + const Offset(0, 20),    // Nose
      center + const Offset(-30, 60),  // Left Mouth
      center + const Offset(30, 60),   // Right Mouth
      center + const Offset(0, 100),   // Chin
    ];

    // Connect some nodes
    canvas.drawLine(nodes[0], nodes[2], linePaint);
    canvas.drawLine(nodes[1], nodes[2], linePaint);
    canvas.drawLine(nodes[2], nodes[3], linePaint);
    canvas.drawLine(nodes[2], nodes[4], linePaint);
    canvas.drawLine(nodes[3], nodes[5], linePaint);
    canvas.drawLine(nodes[4], nodes[5], linePaint);
    canvas.drawLine(nodes[3], nodes[4], linePaint);

    for (var node in nodes) {
      canvas.drawCircle(node, 4.0, nodePaint);
      canvas.drawCircle(node, 10.0, Paint()..color = Colors.white.withValues(alpha: 0.2)..style = PaintingStyle.fill);
    }

    // 3. Sweeping Radar Line
    final scanY = rect.top + (rect.height * scanValue);
    
    final radarPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFF00F2FE).withValues(alpha: 0.0),
          const Color(0xFF00F2FE),
          const Color(0xFFFF0844),
          const Color(0xFFFEE140),
          const Color(0xFFFEE140).withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
      ).createShader(Rect.fromLTWH(rect.left, scanY, rectWidth, 4))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
      
    canvas.drawLine(Offset(rect.left - 20, scanY), Offset(rect.right + 20, scanY), radarPaint);
    
    // Add glowing shadow behind the line
    canvas.drawLine(Offset(rect.left, scanY), Offset(rect.right, scanY), Paint()
      ..color = const Color(0xFF00F2FE).withValues(alpha: 0.5)
      ..strokeWidth = 10.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
    );
  }

  @override
  bool shouldRepaint(covariant FaceScannerPainter oldDelegate) {
    return oldDelegate.scanValue != scanValue;
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;

  CircularProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background Dark Circle
    final bgPaint = Paint()
      ..color = const Color(0xFF141722).withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Track Ring
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress Gradient Ring
    final progressPaint = Paint()
      ..shader = const SweepGradient(
        colors: [Color(0xFF00F2FE), Color(0xFF00FF87)],
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4.0;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}