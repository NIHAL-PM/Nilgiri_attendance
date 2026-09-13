import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../services/location_service.dart';
import '../widgets/painters.dart';
import '../widgets/gradient_button.dart';
import 'scanner_screen.dart';

class GeofenceScreen extends StatefulWidget {
  const GeofenceScreen({super.key});

  @override
  State<GeofenceScreen> createState() => _GeofenceScreenState();
}

class _GeofenceScreenState extends State<GeofenceScreen> {
  bool _isInsideZone = true;
  double _calculatedDistance = 12.0;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    _checkLocation();
  }

  Future<void> _checkLocation() async {
    setState(() => _isLocating = true);
    final distance = await LocationService.instance.distanceFromEvent();
    if (!mounted) return;
    setState(() {
      _isLocating = false;
      if (distance != null) {
        _calculatedDistance = distance;
        _isInsideZone = LocationService.instance.isInsideZone(distance);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      appBar: AppBar(
        title: const Text('📍 Location Verification'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.cyan),
            onPressed: _checkLocation,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Simulated Vector Map Viewport
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.bgSurface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Grid Map Lines
                      const CustomPaint(
                        painter: MapGridPainter(),
                        size: Size.infinite,
                      ),

                      // 50m Radius Geofence Circle
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (_isInsideZone ? AppTheme.cyan : AppTheme.red)
                              .withValues(alpha: 0.08),
                          border: Border.all(
                              color:
                                  _isInsideZone ? AppTheme.cyan : AppTheme.red,
                              width: 2),
                          boxShadow: [
                            BoxShadow(
                                color: (_isInsideZone
                                        ? AppTheme.cyan
                                        : AppTheme.red)
                                    .withValues(alpha: 0.2),
                                blurRadius: 20)
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '50m Venue Radius',
                            style: TextStyle(
                              color:
                                  _isInsideZone ? AppTheme.cyan : AppTheme.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      // User Location Dot Indicator
                      AnimatedAlign(
                        duration: const Duration(milliseconds: 500),
                        alignment: _isInsideZone
                            ? Alignment.center
                            : const Alignment(0.7, 0.7),
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isInsideZone ? AppTheme.green : AppTheme.red,
                            boxShadow: [
                              BoxShadow(
                                  color: _isInsideZone
                                      ? AppTheme.green
                                      : AppTheme.red,
                                  blurRadius: 12,
                                  spreadRadius: 3)
                            ],
                          ),
                          child: const Icon(Icons.my_location,
                              color: Colors.black, size: 14),
                        ),
                      ),

                      if (_isLocating)
                        Container(
                          color: Colors.black.withValues(alpha: 0.5),
                          child: const Center(
                            child: CircularProgressIndicator(
                                color: AppTheme.cyan),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Distance Information Banner Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.bgSurface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(
                      color: (_isInsideZone ? AppTheme.green : AppTheme.red)
                          .withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isInsideZone
                          ? Icons.verified_user_outlined
                          : Icons.gpp_bad_outlined,
                      color: _isInsideZone ? AppTheme.green : AppTheme.red,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isInsideZone
                                ? 'Inside Zone (${_calculatedDistance.toInt()}m away)'
                                : 'Outside Zone (${_calculatedDistance.toInt()}m away)',
                            style: TextStyle(
                              color: _isInsideZone
                                  ? AppTheme.green
                                  : AppTheme.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isInsideZone
                                ? 'You are within the verified venue perimeter.'
                                : 'Move closer to Main Auditorium to unlock scan.',
                            style: const TextStyle(
                                color: AppTheme.textSub, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Simulation Toggle & Action Row
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isInsideZone = !_isInsideZone;
                        _calculatedDistance = _isInsideZone ? 12.0 : 120.0;
                      });
                    },
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppTheme.bgCard,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusFull),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: const Icon(Icons.swap_horiz, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GradientButton(
                      label: 'Proceed to Face Scan',
                      icon: Icons.camera_alt_outlined,
                      onTap: _isInsideZone
                          ? () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const ScannerScreen()),
                              );
                            }
                          : null,
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
