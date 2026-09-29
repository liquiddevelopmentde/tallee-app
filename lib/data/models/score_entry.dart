class ScoreEntry {
  final int roundNumber;
  final int score;
  final int change;
  final DateTime? timerStartedAt;

  ScoreEntry({
    required this.score,
    this.roundNumber = 0,
    this.change = 0,
    this.timerStartedAt,
  });

  @override
  String toString() {
    return 'ScoreEntry{roundNumber: $roundNumber, score: $score, change: $change, timerStartedAt: $timerStartedAt}';
  }

  ScoreEntry copyWith({
    int? roundNumber,
    int? score,
    int? change,
    DateTime? timerStartedAt,
  }) {
    return ScoreEntry(
      roundNumber: roundNumber ?? this.roundNumber,
      score: score ?? this.score,
      change: change ?? this.change,
      timerStartedAt: timerStartedAt ?? this.timerStartedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoreEntry &&
          runtimeType == other.runtimeType &&
          roundNumber == other.roundNumber &&
          score == other.score &&
          change == other.change &&
          timerStartedAt == other.timerStartedAt;

  @override
  int get hashCode => Object.hash(roundNumber, score, change, timerStartedAt);

  ScoreEntry.fromJson(Map<String, dynamic> json)
    : roundNumber = json['roundNumber'],
      score = json['score'],
      change = json['change'],
      timerStartedAt = json['timerStartedAt'] != null
          ? DateTime.parse(json['timerStartedAt'] as String)
          : null;

  Map<String, dynamic> toJson() => {
    'roundNumber': roundNumber,
    'score': score,
    'change': change,
    'timerStartedAt': timerStartedAt?.toIso8601String(),
  };
}
