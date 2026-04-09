class Score {
  final String playerId;
  final int roundNumber;
  int score = 0;
  int change = 0;

  Score({
    required this.playerId,
    required this.roundNumber,
    required this.score,
    required this.change,
  });

  Score.fromJson(Map<String, dynamic> json)
    : playerId = json['playerId'],
      roundNumber = json['roundNumber'],
      score = json['score'],
      change = json['change'];

  Map<String, dynamic> toJson() => {
    'playerId': playerId,
    'roundNumber': roundNumber,
    'score': score,
    'change': change,
  };
}
