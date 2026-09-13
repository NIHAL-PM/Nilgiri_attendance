import 'dart:convert';
import '../models/attendance_record.dart';
import 'api_service.dart';

class AttendanceService {
  static final AttendanceService instance = AttendanceService._();
  AttendanceService._();

  Future<List<AttendanceRecord>> getHistory(String userId) async {
    final response = await ApiService.instance.get('/attendance/history');
    if (response != null && response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) {
        return AttendanceRecord(
          id: item['id'],
          eventTitle: item['event_title'] ?? 'Symposium',
          timestamp: DateTime.parse(item['timestamp']),
          similarityScore: (item['similarity_score'] as num).toDouble(),
          isPresent: item['is_present'],
          eventVenue: item['event_venue'] ?? 'Auditorium',
        );
      }).toList();
    }

    // Demo fallback when offline
    await Future.delayed(const Duration(milliseconds: 400));
    return AttendanceRecord.demoList;
  }

  Future<bool> markAttendance({
    required String eventId,
    required String userId,
    required double similarityScore,
    required List<float> faceEmbedding,
    required double latitude,
    required double longitude,
  }) async {
    final response = await ApiService.instance.post('/attendance/mark', {
      'event_id': eventId,
      'face_embedding': faceEmbedding,
      'latitude': latitude,
      'longitude': longitude,
    });

    if (response != null && response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['is_present'] == true;
    }

    // Demo fallback
    await Future.delayed(const Duration(milliseconds: 400));
    return similarityScore >= 0.75;
  }
}

typedef float = double;
