class AttendanceRecord {
  final String id;
  final String eventTitle;
  final DateTime timestamp;
  final double similarityScore;
  final bool isPresent;
  final String eventVenue;

  const AttendanceRecord({
    required this.id,
    required this.eventTitle,
    required this.timestamp,
    required this.similarityScore,
    required this.isPresent,
    required this.eventVenue,
  });

  static final demoList = [
    AttendanceRecord(id: 'att_001', eventTitle: 'Annual Tech Symposium 2026', timestamp: DateTime(2026, 9, 13, 10, 14), similarityScore: 0.892, isPresent: true, eventVenue: 'Main Auditorium'),
    AttendanceRecord(id: 'att_002', eventTitle: 'DevOps & Cloud Masterclass', timestamp: DateTime(2026, 9, 10, 11, 32), similarityScore: 0.91, isPresent: true, eventVenue: 'Lab 2'),
    AttendanceRecord(id: 'att_003', eventTitle: 'Orientation & Kickoff 2026', timestamp: DateTime(2026, 9, 2, 9, 5), similarityScore: 0.88, isPresent: true, eventVenue: 'Auditorium'),
    AttendanceRecord(id: 'att_004', eventTitle: 'React Native Deep Dive', timestamp: DateTime(2026, 8, 28, 14, 0), similarityScore: 0.65, isPresent: false, eventVenue: 'Innovation Hub'),
    AttendanceRecord(id: 'att_005', eventTitle: 'ML Fundamentals Bootcamp', timestamp: DateTime(2026, 8, 22, 9, 0), similarityScore: 0.94, isPresent: true, eventVenue: 'Lab 6'),
    AttendanceRecord(id: 'att_006', eventTitle: 'Blockchain & Web3 Talk', timestamp: DateTime(2026, 8, 15, 11, 0), similarityScore: 0.87, isPresent: true, eventVenue: 'Seminar Hall B'),
  ];
}
