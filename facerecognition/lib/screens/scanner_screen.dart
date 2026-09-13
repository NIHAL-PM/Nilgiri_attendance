import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../app/theme.dart';
import '../widgets/painters.dart';
import '../services/biometric_service.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _hasCameraPermission = false;
  late AnimationController _scannerCtrl;
  late AnimationController _progressCtrl;
  int _progressPercentage = 0;
  bool _simulateSuccess = true;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _initScanner();
  }

  Future<void> _initScanner() async {
    _scannerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _progressCtrl.addListener(() {
      setState(() {
        _progressPercentage = (_progressCtrl.value * 100).toInt();
      });
    });

    await _initCamera();
    _startScanProcess();
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      setState(() => _hasCameraPermission = true);
      try {
        final cameras = await availableCameras();
        if (cameras.isNotEmpty) {
          // Prefer front camera for face recognition
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
        debugPrint('Camera init error: $e');
      }
    }
  }

  void _startScanProcess() {
    _progressCtrl.reset();
    _progressCtrl.forward().then((_) async {
      if (!mounted) return;
      setState(() => _isVerifying = true);
      final score = await BiometricService.instance.compareFaces();
      if (!mounted) return;
      setState(() => _isVerifying = false);

      if (_simulateSuccess && score >= 0.75) {
        _showSuccessModal(score);
      } else {
        _showFailureModal(score < 0.75 ? score : 0.64);
      }
    });
  }

  @override
  void dispose() {
    _scannerCtrl.dispose();
    _progressCtrl.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  void _showSuccessModal(double score) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      isDismissible: false,
      builder: (context) {
        return ClipRRect(
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(30)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.bgSurface.withValues(alpha: 0.9),
                border: Border(
                  top: BorderSide(color: AppTheme.green.withValues(alpha: 0.3)),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.green.withValues(alpha: 0.12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.green.withValues(alpha: 0.3),
                          blurRadius: 20,
                        )
                      ],
                    ),
                    child: const Icon(Icons.check_circle,
                        color: AppTheme.green, size: 48),
                  ),
                  const SizedBox(height: 20),
                  const Text('Attendance Recorded!',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(
                    'Alex Vance (ID: #9021)\nSimilarity Score = ${score.toStringAsFixed(3)}\n10:14:02 AM | Sep 13, 2026',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: AppTheme.textSub, fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 28),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: AppTheme.greenGradient,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Center(
                        child: Text('Return to Dashboard',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFailureModal(double score) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      isDismissible: false,
      builder: (context) {
        return ClipRRect(
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(30)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppTheme.bgSurface.withValues(alpha: 0.9),
                border: Border(
                  top: BorderSide(color: AppTheme.red.withValues(alpha: 0.3)),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.red.withValues(alpha: 0.12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.red.withValues(alpha: 0.3),
                          blurRadius: 20,
                        )
                      ],
                    ),
                    child: const Icon(Icons.cancel,
                        color: AppTheme.red, size: 48),
                  ),
                  const SizedBox(height: 20),
                  const Text('Verification Unsuccessful',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(
                    'Biometric similarity score (${score.toStringAsFixed(2)}) below threshold (0.75).\nPlease ensure proper lighting and remove coverings.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: AppTheme.textSub, fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            _startScanProcess();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: AppTheme.red.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: AppTheme.red),
                            ),
                            child: const Center(
                              child: Text('Retry Scan',
                                  style: TextStyle(
                                      color: AppTheme.red,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Center(
                              child: Text('Cancel',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Live Camera Preview or simulated dark gradient fallback
          if (_isCameraInitialized &&
              _cameraController != null &&
              _cameraController!.value.isInitialized)
            SizedBox.expand(
              child: CameraPreview(_cameraController!),
            )
          else
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [Color(0xFF2A2D3E), Colors.black],
                  radius: 1.2,
                  center: Alignment.center,
                ),
              ),
              child: const Center(
                child: Icon(Icons.person, color: AppTheme.textMuted, size: 140),
              ),
            ),

          // Face Mesh & Radar Sweeper Overlay
          AnimatedBuilder(
            animation: _scannerCtrl,
            builder: (context, child) {
              return CustomPaint(
                painter: FaceScannerPainter(
                  scanValue: _scannerCtrl.value,
                  accentColor: _simulateSuccess ? AppTheme.cyan : AppTheme.red,
                ),
                size: Size.infinite,
              );
            },
          ),

          // Top Header Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text('Face Verification',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600)),

                // Simulation Outcome Toggle
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _simulateSuccess = !_simulateSuccess;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: (_simulateSuccess ? AppTheme.green : AppTheme.red)
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            _simulateSuccess ? AppTheme.green : AppTheme.red,
                      ),
                    ),
                    child: Text(
                      _simulateSuccess ? 'Sim: Pass' : 'Sim: Fail',
                      style: TextStyle(
                        color:
                            _simulateSuccess ? AppTheme.green : AppTheme.red,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Progress Indicator
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isVerifying)
                  const Text('Extracting facial embedding...',
                      style: TextStyle(
                          color: AppTheme.cyan,
                          fontSize: 13,
                          fontWeight: FontWeight.w600))
                else
                  Text(
                    _progressPercentage < 100
                        ? 'Analyzing face structure...'
                        : 'Verification complete',
                    style: const TextStyle(color: AppTheme.textSub, fontSize: 13),
                  ),
                const SizedBox(height: 14),
                CustomPaint(
                  painter: CircularProgressPainter(
                    progress: _progressCtrl.value,
                    color: _simulateSuccess ? AppTheme.cyan : AppTheme.red,
                  ),
                  child: SizedBox(
                    width: 80,
                    height: 80,
                    child: Center(
                      child: Text(
                        '$_progressPercentage%',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
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
