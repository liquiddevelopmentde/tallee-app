class ScoreEntry {
  final int roundNumber;
  final int score;
  final int change;

  ScoreEntry({required this.score, this.roundNumber = 0, this.change = 0});

  @override
  String toString() {
    return 'ScoreEntry{roundNumber: $roundNumber, score: $score, change: $change}';
  }

  ScoreEntry copyWith({int? roundNumber, int? score, int? change}) {
    return ScoreEntry(
      roundNumber: roundNumber ?? this.roundNumber,
      score: score ?? this.score,
      change: change ?? this.change,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoreEntry &&
          runtimeType == other.runtimeType &&
          roundNumber == other.roundNumber &&
          score == other.score &&
          change == other.change;

  @override
  int get hashCode => Object.hash(roundNumber, score, change);

  ScoreEntry.fromJson(Map<String, dynamic> json)
    : roundNumber = json['roundNumber'],
      score = json['score'],
      change = json['change'];

  Map<String, dynamic> toJson() => {
    'roundNumber': roundNumber,
    'score': score,
    'change': change,
  };
}
