class Score {
  final int roundNumber;
  int score = 0;
  int change = 0;

  Score({required this.roundNumber, required this.score, required this.change});

  Score.fromJson(Map<String, dynamic> json)
    : roundNumber = json['roundNumber'],
      score = json['score'],
      change = json['change'];

  Map<String, dynamic> toJson() => {
    'roundNumber': roundNumber,
    'score': score,
    'change': change,
  };
}
