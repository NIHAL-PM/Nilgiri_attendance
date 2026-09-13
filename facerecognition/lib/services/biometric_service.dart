import 'dart:math';

/// Abstracts face biometric matching.
/// Replace [compareFaces] body with ML Kit / custom model when ready.
class BiometricService {
  static final BiometricService instance = BiometricService._();
  BiometricService._();

  // In a real app: accepts image bytes from camera and baseline embedding.
  // Returns cosine similarity score 0.0 - 1.0.
  Future<double> compareFaces() async {
    // Simulate network / inference latency
    await Future.delayed(const Duration(milliseconds: 600));
    // TODO: replace with actual ML Kit face detection + embedding comparison
    final r = Random();
    return 0.82 + r.nextDouble() * 0.12; // mock 0.82 - 0.94
  }

  static const double threshold = 0.75;

  bool passes(double score) => score >= threshold;
}
