class User {
  final String id;
  final String name;
  final String email;
  final String avatarUrl;
  final bool isVerified;
  final int totalEvents;
  final int presentCount;
  final int currentStreak;
  final double accuracyScore;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.isVerified,
    required this.totalEvents,
    required this.presentCount,
    required this.currentStreak,
    required this.accuracyScore,
  });

  int get absentCount => totalEvents - presentCount;
  double get attendanceRate => totalEvents == 0 ? 0 : presentCount / totalEvents;

  // Demo user
  static const demo = User(
    id: 'usr_9021',
    name: 'Alex Vance',
    email: 'alex.vance@nilgiri.edu',
    avatarUrl: 'https://i.pravatar.cc/150?img=33',
    isVerified: true,
    totalEvents: 18,
    presentCount: 16,
    currentStreak: 7,
    accuracyScore: 0.912,
  );
}
