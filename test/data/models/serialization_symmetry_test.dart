import 'package:flutter_test/flutter_test.dart';
import 'package:tallee/data/models/models.dart';

void main() {
  late Player testPlayer1;
  late Player testPlayer2;
  late Game testGame;
  late Group testGroup;
  late Match testMatch;

  setUp(() {
    testPlayer1 = Player(name: 'Alice', id: 'p1');
    testPlayer2 = Player(name: 'Bob', id: 'p2');
    testGame = Game(name: 'Chess', ruleset: Ruleset.singleWinner, id: 'g1');
    testGroup = Group(
      name: 'Monday Night',
      members: [testPlayer1, testPlayer2],
      id: 'gr1',
    );
    testMatch = Match(
      name: 'Final Match',
      game: testGame,
      players: [testPlayer1, testPlayer2],
      group: testGroup,
      id: 'm1',
      scores: {'p1': ScoreEntry(score: 10)},
      teams: [
        Team(name: 'Team A', members: [testPlayer1], id: 't1'),
      ],
    );
  });

  group('Serialization Symmetry Tests', () {
    test('Match Normalized Symmetry', () {
      final json = testMatch.toNormalizedJson();

      // Verify IDs are used in the normalized JSON
      expect(json['gameId'], 'g1');
      expect(json['groupId'], 'gr1');
      expect(json['playerIds'], containsAll(['p1', 'p2']));

      final reconstructed = Match.fromNormalizedJson(
        json,
        game: testGame,
        group: testGroup,
        players: [testPlayer1, testPlayer2],
        teams: [
          Team.fromNormalizedJson(json['teams'][0], [testPlayer1]),
        ],
      );

      expect(reconstructed.id, testMatch.id);
      expect(reconstructed.name, testMatch.name);
      expect(reconstructed.game.id, testGame.id);
      expect(reconstructed.group?.id, testGroup.id);
      expect(reconstructed.players.length, 2);
      expect(reconstructed.teams?[0].id, 't1');
      expect(reconstructed.scores['p1']?.score, 10);
    });

    test('Group Normalized Symmetry', () {
      final json = testGroup.toNormalizedJson();
      expect(json['memberIds'], containsAll(['p1', 'p2']));

      final reconstructed = Group.fromNormalizedJson(json, [
        testPlayer1,
        testPlayer2,
      ]);

      expect(reconstructed.id, testGroup.id);
      expect(reconstructed.name, testGroup.name);
      expect(reconstructed.members.length, 2);
      expect(reconstructed.members[0].id, 'p1');
    });

    test('Team Normalized Symmetry', () {
      final team = testMatch.teams![0];
      final json = team.toNormalizedJson();
      expect(json['memberIds'], contains('p1'));

      final reconstructed = Team.fromNormalizedJson(json, [testPlayer1]);

      expect(reconstructed.id, team.id);
      expect(reconstructed.name, team.name);
      expect(reconstructed.members.length, 1);
      expect(reconstructed.members[0].id, 'p1');
    });
  });
}
