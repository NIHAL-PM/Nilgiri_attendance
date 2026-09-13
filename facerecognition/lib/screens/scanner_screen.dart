import 'dart:ui';
import 'package:flutter/material.dart';
import 'painters.dart';

/// The biometric face-scan verification screen.
/// Animates a radar sweep over a face-mesh overlay and shows a
/// success or failure modal bottom sheet on completion.
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with TickerProviderStateMixin {
  late AnimationController _scannerController;
  late AnimationController _progressController;
  int _progressPercentage = 0;

  /// Toggle between simulating a pass or fail outcome.
  bool _simulateSuccess = true;

  @override
  void initState() {
    super.initState();

    // Radar line sweeping animation
    _scannerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Progress counter that drives the percentage text
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
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF00FF87).withValues(alpha: 0.3), blurRadius: 20),
                      ],
                    ),
                    child: const Icon(Icons.check_circle, color: Color(0xFF00FF87), size: 50),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Attendance Recorded!',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Alex Vance (ID: #9021)\nCosine Similarity = 0.892\n10:14:02 AM | Sep 13, 2026',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF8E95A5), fontSize: 14, height: 1.5),
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
                        child: Text(
                          'Return to Dashboard',
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
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
                      boxShadow: [
                        BoxShadow(color: const Color(0xFFFF0844).withValues(alpha: 0.3), blurRadius: 20),
                      ],
                    ),
                    child: const Icon(Icons.cancel, color: Color(0xFFFF0844), size: 50),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Verification Unsuccessful',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Biometric similarity threshold not met (0.68 < 0.75).\nPlease ensure proper lighting and remove heavy face coverings.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF8E95A5), fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            _progressController.reset();
                            _progressController.forward().then((_) {
                              if (_simulateSuccess) {
                                _showVerificationResult();
                              } else {
                                _showFailureResult();
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF0844).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: const Color(0xFFFF0844)),
                            ),
                            child: const Center(
                              child: Text(
                                'Retry Scan',
                                style: TextStyle(color: Color(0xFFFF0844), fontWeight: FontWeight.bold),
                              ),
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
                              child: Text(
                                'Cancel',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Simulated camera background (dark vignette gradient)
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0xFF2A2D3E), Colors.black],
                radius: 1.2,
                center: Alignment.center,
              ),
            ),
          ),

          // Face mesh, bounding box, and radar sweep
          AnimatedBuilder(
            animation: _scannerController,
            builder: (context, child) {
              return CustomPaint(
                painter: FaceScannerPainter(scanValue: _scannerController.value),
                size: Size.infinite,
              );
            },
          ),

          // Top bar: back button, title, and simulation toggle
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
                const Text(
                  'Verification',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                ),

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
                      color: (_simulateSuccess ? const Color(0xFF00FF87) : const Color(0xFFFF0844))
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _simulateSuccess ? 'Sim: Pass' : 'Sim: Fail',
                      style: TextStyle(
                        color: _simulateSuccess ? const Color(0xFF00FF87) : const Color(0xFFFF0844),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Circular progress indicator at bottom
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
          ),
        ],
      ),
    );
  }
}
