class AttendanceEvent {
  final String id;
  final String title;
  final String venue;
  final DateTime startTime;
  final DateTime endTime;
  final bool isActive;
  final String? imageTag; // for colour coding

  const AttendanceEvent({
    required this.id,
    required this.title,
    required this.venue,
    required this.startTime,
    required this.endTime,
    required this.isActive,
    this.imageTag,
  });

  static final demoActive = AttendanceEvent(
    id: 'evt_001',
    title: 'Annual Tech Symposium 2026',
    venue: 'Main Auditorium, Block C',
    startTime: DateTime(2026, 9, 13, 10, 0),
    endTime: DateTime(2026, 9, 13, 13, 0),
    isActive: true,
    imageTag: 'cyan',
  );

  static final demoUpcoming = [
    AttendanceEvent(
      id: 'evt_002',
      title: 'AI & Neural Net Workshop',
      venue: 'Lab 4, Innovation Wing',
      startTime: DateTime(2026, 9, 14, 14, 0),
      endTime: DateTime(2026, 9, 14, 17, 0),
      isActive: false,
      imageTag: 'green',
    ),
    AttendanceEvent(
      id: 'evt_003',
      title: 'Cybersecurity Hackathon',
      venue: 'Central Seminar Hall',
      startTime: DateTime(2026, 9, 18, 9, 0),
      endTime: DateTime(2026, 9, 18, 21, 0),
      isActive: false,
      imageTag: 'red',
    ),
    AttendanceEvent(
      id: 'evt_004',
      title: 'Cloud Architecture Summit',
      venue: 'Conference Room A',
      startTime: DateTime(2026, 9, 22, 11, 0),
      endTime: DateTime(2026, 9, 22, 15, 0),
      isActive: false,
      imageTag: 'gold',
    ),
  ];
}
