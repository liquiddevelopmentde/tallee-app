class ScoreEntry {
  final int roundNumber;
  final int score;
  final int change;

  ScoreEntry({required this.score, this.roundNumber = 0, this.change = 0});

  @override
  String toString() {
    return 'ScoreEntry{roundNumber: $roundNumber, score: $score, change: $change}';
  }

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
