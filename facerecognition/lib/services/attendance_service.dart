import '../models/attendance_record.dart';

/// Attendance data service - swap [_baseUrl] and HTTP calls
/// with your real backend when ready.
class AttendanceService {
  static final AttendanceService instance = AttendanceService._();
  AttendanceService._();

  // ignore: unused_field
  static const _baseUrl = 'https://api.pulseattend.dev/v1';

  /// Fetch attendance history for current user.
  Future<List<AttendanceRecord>> getHistory(String userId) async {
    await Future.delayed(const Duration(milliseconds: 800)); // mock latency
    // TODO: GET $_baseUrl/attendance?user=$userId
    return AttendanceRecord.demoList;
  }

  /// Mark attendance for [eventId] with a biometric [similarityScore].
  Future<bool> markAttendance({
    required String eventId,
    required String userId,
    required double similarityScore,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    // TODO: POST $_baseUrl/attendance { eventId, userId, similarityScore }
    return similarityScore >= BiometricServiceConst.threshold;
  }
}

abstract class BiometricServiceConst {
  static const double threshold = 0.75;
}
