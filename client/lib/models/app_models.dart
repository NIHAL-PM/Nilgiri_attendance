class UserModel {
  final String id;
  final String email;
  final String studentId;
  final String fullName;
  final String role;
  bool isFaceRegistered;
  final DateTime? faceRegisteredAt;

  UserModel({
    required this.id,
    required this.email,
    required this.studentId,
    required this.fullName,
    required this.role,
    required this.isFaceRegistered,
    this.faceRegisteredAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      studentId: json['student_id'] ?? '',
      fullName: json['full_name'] ?? '',
      role: json['role'] ?? 'student',
      isFaceRegistered: json['is_face_registered'] ?? false,
      faceRegisteredAt: json['face_registered_at'] != null 
          ? DateTime.tryParse(json['face_registered_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'student_id': studentId,
    'full_name': fullName,
    'role': role,
    'is_face_registered': isFaceRegistered,
    'face_registered_at': faceRegisteredAt?.toIso8601String(),
  };
}

class EventModel {
  final String id;
  final String code;
  final String name;
  final String? description;
  final String locationName;
  final double? latitude;
  final double? longitude;
  final double radiusMeters;
  final bool isGeofenced;
  final DateTime startTime;
  final DateTime endTime;
  final bool isActive;

  EventModel({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.locationName,
    this.latitude,
    this.longitude,
    required this.radiusMeters,
    required this.isGeofenced,
    required this.startTime,
    required this.endTime,
    required this.isActive,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      locationName: json['location_name'] ?? 'Auditorium',
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      radiusMeters: (json['radius_meters'] as num?)?.toDouble() ?? 50.0,
      isGeofenced: json['is_geofenced'] ?? false,
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      isActive: json['is_active'] ?? true,
    );
  }
}

class AttendanceVerifyResult {
  final String status;
  final String studentName;
  final double similarityScore;
  final String message;
  final DateTime timestamp;
  final bool geofenceVerified;
  final String? attendanceId;

  AttendanceVerifyResult({
    required this.status,
    required this.studentName,
    required this.similarityScore,
    required this.message,
    required this.timestamp,
    required this.geofenceVerified,
    this.attendanceId,
  });

  factory AttendanceVerifyResult.fromJson(Map<String, dynamic> json) {
    return AttendanceVerifyResult(
      status: json['status'] ?? 'failed',
      studentName: json['student_name'] ?? '',
      similarityScore: (json['similarity_score'] as num?)?.toDouble() ?? 0.0,
      message: json['message'] ?? '',
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now(),
      geofenceVerified: json['geofence_verified'] ?? true,
      attendanceId: json['attendance_id'],
    );
  }
}
