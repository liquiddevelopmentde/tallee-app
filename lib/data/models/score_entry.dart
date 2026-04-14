class ScoreEntry {
  int roundNumber = 0;
  final int score;
  final int change;

  ScoreEntry({
    required this.roundNumber,
    required this.score,
    required this.change,
  });

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
