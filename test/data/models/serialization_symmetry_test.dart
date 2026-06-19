import 'package:flutter_test/flutter_test.dart';
import 'package:tallee/data/models/models.dart';

void main() {
  group('Serialization Symmetry Tests', () {
    late Player player1;
    late Player player2;
    late Game game;
    late Group group;
    late Match match;

    setUp(() {
      player1 = Player(name: 'Alice', id: 'p1');
      player2 = Player(name: 'Bob', id: 'p2');
      game = Game(name: 'Chess', ruleset: Ruleset.singleWinner, id: 'g1');
      group = Group(
        name: 'Monday Night',
        members: [player1, player2],
        id: 'gr1',
      );
      match = Match(
        name: 'Final Match',
        game: game,
        players: [player1, player2],
        group: group,
        id: 'm1',
        scores: {'p1': ScoreEntry(score: 10)},
        teams: [
          Team(name: 'Team A', members: [player1], id: 't1'),
        ],
      );
    });

    test('Match Normalized Symmetry', () {
      final json = match.toNormalizedJson();

      // Verify IDs are used in the normalized JSON
      expect(json['gameId'], 'g1');
      expect(json['groupId'], 'gr1');
      expect(json['playerIds'], containsAll(['p1', 'p2']));

      final reconstructed = Match.fromNormalizedJson(
        json,
        game: game,
        group: group,
        players: [player1, player2],
        teams: [
          Team.fromNormalizedJson(json['teams'][0], [player1]),
        ],
      );

      expect(reconstructed.id, match.id);
      expect(reconstructed.name, match.name);
      expect(reconstructed.game.id, game.id);
      expect(reconstructed.group?.id, group.id);
      expect(reconstructed.players.length, 2);
      expect(reconstructed.teams?[0].id, 't1');
      expect(reconstructed.scores['p1']?.score, 10);
    });

    test('Group Normalized Symmetry', () {
      final json = group.toNormalizedJson();
      expect(json['memberIds'], containsAll(['p1', 'p2']));

      final reconstructed = Group.fromNormalizedJson(json, [player1, player2]);

      expect(reconstructed.id, group.id);
      expect(reconstructed.name, group.name);
      expect(reconstructed.members.length, 2);
      expect(reconstructed.members[0].id, 'p1');
    });

    test('Team Normalized Symmetry', () {
      final team = match.teams![0];
      final json = team.toNormalizedJson();
      expect(json['memberIds'], contains('p1'));

      final reconstructed = Team.fromNormalizedJson(json, [player1]);

      expect(reconstructed.id, team.id);
      expect(reconstructed.name, team.name);
      expect(reconstructed.members.length, 1);
      expect(reconstructed.members[0].id, 'p1');
    });
  });
}
