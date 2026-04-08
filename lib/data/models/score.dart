class Score {
  final String playerId;
  final String matchId;
  final int roundNumber;
  int score = 0;
  int change = 0;

  Score({
    required this.playerId,
    required this.matchId,
    required this.roundNumber,
    required this.score,
    required this.change,
  });

  Score.fromJson(Map<String, dynamic> json)
    : playerId = json['playerId'],
      matchId = json['matchId'],
      roundNumber = json['roundNumber'],
      score = json['score'],
      change = json['change'];

  Map<String, dynamic> toJson() => {
    'playerId': playerId,
    'matchId': matchId,
    'roundNumber': roundNumber,
    'score': score,
    'change': change,
  };
}
