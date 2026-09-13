import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../app/theme.dart';
import '../widgets/gradient_button.dart';
import 'dashboard_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  int _stepIndex = 0;

  final List<String> _prompts = [
    'Center your face in the oval frame',
    'Blink both eyes to verify liveness',
    'Hold still... Extracting biometric features',
  ];

  Color _ellipseColor = AppTheme.gold;

  @override
  void initState() {
    super.initState();
    _initRegistration();
  }

  Future<void> _initRegistration() async {
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(() {
        setState(() {
          if (_progressController.value > 0.33 && _stepIndex == 0) {
            _stepIndex = 1;
            _ellipseColor = AppTheme.cyan;
          } else if (_progressController.value > 0.66 && _stepIndex == 1) {
            _stepIndex = 2;
            _ellipseColor = AppTheme.green;
          }
        });
      });

    await _initCamera();
    _progressController.forward();
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      try {
        final cameras = await availableCameras();
        if (cameras.isNotEmpty) {
          final frontCam = cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.front,
            orElse: () => cameras.first,
          );
          _cameraController = CameraController(
            frontCam,
            ResolutionPreset.medium,
            enableAudio: false,
          );
          await _cameraController!.initialize();
          if (mounted) {
            setState(() => _isCameraInitialized = true);
          }
        }
      } catch (e) {
        debugPrint('Registration camera error: $e');
      }
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Face Registration'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.cyan.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.cyan.withValues(alpha: 0.4)),
            ),
            child: Center(
              child: Text(
                'Step ${_stepIndex + 1} of 3',
                style: const TextStyle(
                    color: AppTheme.cyan,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Dynamic Liveness Instruction Banner
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.bgSurface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: _ellipseColor.withValues(alpha: 0.5)),
                  boxShadow: [
                    BoxShadow(
                        color: _ellipseColor.withValues(alpha: 0.2),
                        blurRadius: 12)
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.face, color: _ellipseColor, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _prompts[_stepIndex],
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Oval Camera Frame Viewport
              Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 270,
                  height: 360,
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.all(Radius.elliptical(135, 180)),
                    border: Border.all(color: _ellipseColor, width: 3.5),
                    boxShadow: [
                      BoxShadow(
                          color: _ellipseColor.withValues(alpha: 0.3),
                          blurRadius: 30)
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius:
                        const BorderRadius.all(Radius.elliptical(135, 180)),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (_isCameraInitialized &&
                            _cameraController != null &&
                            _cameraController!.value.isInitialized)
                          SizedBox.expand(child: CameraPreview(_cameraController!))
                        else
                          Container(
                            color: AppTheme.bgCard,
                            child: const Icon(Icons.person,
                                color: AppTheme.textMuted, size: 140),
                          ),

                        // Progress percentage overlay
                        Positioned(
                          bottom: 24,
                          child: AnimatedBuilder(
                            animation: _progressController,
                            builder: (context, child) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${(_progressController.value * 100).toInt()}%',
                                  style: TextStyle(
                                      color: _ellipseColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(),

              // Save Baseline CTA
              AnimatedBuilder(
                animation: _progressController,
                builder: (context, child) {
                  final isDone = _progressController.isCompleted;
                  return GradientButton(
                    label: isDone
                        ? 'Save Biometric Baseline'
                        : 'Processing Biometrics...',
                    gradient: isDone ? AppTheme.greenGradient : null,
                    textColor: isDone ? Colors.black : AppTheme.textMuted,
                    icon: isDone ? Icons.check_circle_outline : Icons.sync,
                    onTap: isDone
                        ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Biometric Baseline Enrolled Successfully!'),
                                backgroundColor: AppTheme.green,
                              ),
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const DashboardScreen()),
                            );
                          }
                        : null,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
