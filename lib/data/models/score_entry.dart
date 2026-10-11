class ScoreEntry {
  final int roundNumber;
  final int score;
  final int change;
  final DateTime? timerStartedAt;

  ScoreEntry({
    int? score,
    this.roundNumber = 0,
    int? change,
    this.timerStartedAt,
  }) : score = score ?? change ?? 0,
       change = change ?? score ?? 0;

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
    : roundNumber = json['roundNumber'] ?? 0,
      score = json['score'] ?? json['change'] ?? 0,
      change = json['change'] ?? json['score'] ?? 0,
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
