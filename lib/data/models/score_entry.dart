class ScoreEntry {
  final int roundNumber;
  final int change;

  // Backwards compatibility for UI PR
  @Deprecated('Use change instead')
  int get score => change;

  ScoreEntry({
    // Backwards compatibility for UI PR
    @Deprecated('Use change instead') int? score,
    this.roundNumber = 0,
    int? change,
  }) : change = change ?? score ?? 0;

  @override
  String toString() {
    return 'ScoreEntry{roundNumber: $roundNumber, change: $change, score: $score}';
  }

  ScoreEntry copyWith({
    int? roundNumber,
    int? change,
    @Deprecated('Use change instead') int? score,
  }) {
    return ScoreEntry(
      roundNumber: roundNumber ?? this.roundNumber,
      change: change ?? this.change,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoreEntry &&
          runtimeType == other.runtimeType &&
          roundNumber == other.roundNumber &&
          change == other.change;

  @override
  int get hashCode => Object.hash(roundNumber, change);

  ScoreEntry.fromJson(Map<String, dynamic> json)
    : roundNumber = json['roundNumber'] ?? 0,
      // Backwards compatibility for UI PR: fall back to score if change is missing
      change = json['change'] ?? json['score'] ?? 0;

  Map<String, dynamic> toJson() => {
    'roundNumber': roundNumber,
    'change': change,
    // Backwards compatibility for UI PR
    'score': change,
  };
}
