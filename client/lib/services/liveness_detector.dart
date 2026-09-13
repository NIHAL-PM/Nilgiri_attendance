import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

enum LivenessChallenge {
  lookStraight,
  blink,
  tiltHeadRight,
  tiltHeadLeft,
  smile,
}

class LivenessDetector {
  final FaceDetector _faceDetector;

  LivenessDetector()
      : _faceDetector = FaceDetector(
          options: FaceDetectorOptions(
            enableClassification: true, // Eye open & smiling probabilities
            enableLandmarks: true,
            enableContours: true,
            enableTracking: true,
            minFaceSize: 0.15,
            performanceMode: FaceDetectorMode.accurate,
          ),
        );

  Future<List<Face>> processImage(InputImage inputImage) async {
    return await _faceDetector.processImage(inputImage);
  }

  /// Evaluates whether the detected face satisfies positioning and liveness challenge
  LivenessEvaluation evaluateFace(
      List<Face> faces, LivenessChallenge challenge) {
    if (faces.isEmpty) {
      return LivenessEvaluation(
        isValid: false,
        message:
            'No face detected. Please position your face inside the frame.',
      );
    }
    if (faces.length > 1) {
      return LivenessEvaluation(
        isValid: false,
        message: 'Multiple faces detected. Please ensure only you are visible.',
      );
    }

    final face = faces.first;

    // Check head rotation (Euler Y = yaw/left-right, Euler Z = roll/tilt)
    final double yaw = face.headEulerAngleY ?? 0.0;
    final double roll = face.headEulerAngleZ ?? 0.0;
    final double pitch = face.headEulerAngleX ?? 0.0;

    // Eye open probabilities
    final double leftEyeOpen = face.leftEyeOpenProbability ?? 1.0;
    final double rightEyeOpen = face.rightEyeOpenProbability ?? 1.0;
    final double smileProb = face.smilingProbability ?? 0.0;

    switch (challenge) {
      case LivenessChallenge.lookStraight:
        if (yaw.abs() < 12 && roll.abs() < 12 && pitch.abs() < 15) {
          return LivenessEvaluation(
            isValid: true,
            message: 'Face centered! Hold still...',
            face: face,
          );
        }
        return LivenessEvaluation(
          isValid: false,
          message: 'Look straight directly into the camera lens.',
          face: face,
        );

      case LivenessChallenge.blink:
        // When both eyes are closed below 0.25 probability
        if (leftEyeOpen < 0.25 && rightEyeOpen < 0.25) {
          return LivenessEvaluation(
            isValid: true,
            message: 'Blink recognized!',
            face: face,
          );
        }
        return LivenessEvaluation(
          isValid: false,
          message: 'Blink your eyes naturally now.',
          face: face,
        );

      case LivenessChallenge.tiltHeadRight:
        if (yaw > 18.0) {
          return LivenessEvaluation(
            isValid: true,
            message: 'Head tilt recognized!',
            face: face,
          );
        }
        return LivenessEvaluation(
          isValid: false,
          message: 'Tilt your head slightly to the right.',
          face: face,
        );

      case LivenessChallenge.tiltHeadLeft:
        if (yaw < -18.0) {
          return LivenessEvaluation(
            isValid: true,
            message: 'Head tilt recognized!',
            face: face,
          );
        }
        return LivenessEvaluation(
          isValid: false,
          message: 'Tilt your head slightly to the left.',
          face: face,
        );

      case LivenessChallenge.smile:
        if (smileProb > 0.6) {
          return LivenessEvaluation(
            isValid: true,
            message: 'Smile recognized!',
            face: face,
          );
        }
        return LivenessEvaluation(
          isValid: false,
          message: 'Smile gently for the camera.',
          face: face,
        );
    }
  }

  void dispose() {
    _faceDetector.close();
  }
}

class LivenessEvaluation {
  final bool isValid;
  final String message;
  final Face? face;

  LivenessEvaluation({
    required this.isValid,
    required this.message,
    this.face,
  });
}
