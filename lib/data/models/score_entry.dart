class ScoreEntry {
  final int roundNumber;
  final int change;
  final DateTime? timerStartedAt;

  // Backwards compatibility for UI PR
  @Deprecated('Use change instead')
  int get score => change;

  ScoreEntry({
    // Backwards compatibility for UI PR
    @Deprecated('Use change instead') int? score,
    this.roundNumber = 0,
    int? change,
    this.timerStartedAt,
  }) : change = change ?? score ?? 0;

  @override
  String toString() =>
      'ScoreEntry{roundNumber: $roundNumber, change: $change, score: $score, timerStartedAt: $timerStartedAt}';

  ScoreEntry copyWith({
    int? roundNumber,
    int? change,
    @Deprecated('Use change instead') int? score,
    DateTime? timerStartedAt,
  }) => ScoreEntry(
    roundNumber: roundNumber ?? this.roundNumber,
    change: change ?? this.change,
    timerStartedAt: timerStartedAt ?? this.timerStartedAt,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoreEntry &&
          runtimeType == other.runtimeType &&
          roundNumber == other.roundNumber &&
          change == other.change &&
          timerStartedAt == other.timerStartedAt;

  @override
  int get hashCode => Object.hash(roundNumber, change, timerStartedAt);

  ScoreEntry.fromJson(Map<String, dynamic> json)
    : roundNumber = json['roundNumber'] ?? 0,
      // Backwards compatibility for UI PR: fall back to score if change is missing
      change = json['change'] != 0 ? json['change'] : json['score'] ?? 0,
      timerStartedAt = json['timerStartedAt'] != null
          ? DateTime.parse(json['timerStartedAt'] as String)
          : null;

  Map<String, dynamic> toJson() => {
    'roundNumber': roundNumber,
    'change': change,
    'timerStartedAt': timerStartedAt?.toIso8601String(),
  };
}
