import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/dashboard_screen.dart';
import 'screens/scanner_screen.dart';

export 'screens/dashboard_screen.dart';
export 'screens/scanner_screen.dart';
export 'screens/painters.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const PulseAttendApp());
}

// ---------------------------------------------------------------------------
// App Root
// ---------------------------------------------------------------------------

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
        fontFamily: 'Inter',
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: Color(0xFF8E95A5)),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

// ---------------------------------------------------------------------------
// Login Screen
// ---------------------------------------------------------------------------

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
          // Animated floating biometric nodes in the background
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

                  // Primary login button
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
                          ),
                        ],
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

                  // Face registration shortcut (first-time setup)
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
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingNode({
    required double top,
    required double left,
    required Color color,
    required IconData icon,
  }) {
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
            BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 15, spreadRadius: 5),
          ],
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Registration Screen
// ---------------------------------------------------------------------------

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
    'Hold still... Extracting features',
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
        title: const Text(
          'Face Registration',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
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
              child: Text(
                'Step 1 of 2',
                style: TextStyle(color: Color(0xFF00F2FE), fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Dynamic liveness instruction banner
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF141722),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _ellipseColor.withValues(alpha: 0.5)),
                  boxShadow: [BoxShadow(color: _ellipseColor.withValues(alpha: 0.2), blurRadius: 10)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.face, color: _ellipseColor, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      _prompts[_stepIndex],
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Oval camera frame viewport
              Center(
                child: Container(
                  width: 260,
                  height: 350,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.elliptical(130, 175)),
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
                              style: TextStyle(
                                color: _ellipseColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),

              // Submit baseline button — activates once the progress animation completes
              GestureDetector(
                onTap: _progressController.isCompleted
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Biometric Baseline Saved Successfully!'),
                            backgroundColor: Color(0xFF00FF87),
                          ),
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const DashboardScreen()),
                        );
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}