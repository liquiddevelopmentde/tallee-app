import 'package:drift/drift.dart';
import 'package:tallee/core/enums.dart';
import 'package:tallee/data/db/database.dart';
import 'package:tallee/data/db/tables/statistic_scope_table.dart';

part 'statistic_scope_dao.g.dart';

@DriftAccessor(tables: [StatisticScopeTable])
class StatisticScopeDao extends DatabaseAccessor<AppDatabase>
    with _$StatisticScopeDaoMixin {
  StatisticScopeDao(super.db);

  /// Retrieves a list of statistic scopes associated with a specific statistic ID.
  Future<List<StatisticScope>> getScopeForStatistic(String statisticId) async {
    final query = select(statisticScopeTable)
      ..where((tbl) => tbl.statisticId.equals(statisticId));

    final results = await query.get();
    return results
        .map(
          (result) => StatisticScope.values.firstWhere(
            (e) => e.name == result.scope,
            orElse: () => throw Exception(
              'Invalid scope value: ${result.scope} for statistic ID: $statisticId',
            ),
          ),
        )
        .toList();
  }

  Future<bool> addStatisticScopes({
    required String statisticId,
    required List<StatisticScope> scopes,
  }) async {
    final entries = scopes
        .map(
          (scope) => StatisticScopeTableCompanion.insert(
            statisticId: statisticId,
            scope: scope.name,
          ),
        )
        .toList();

    return batch((batch) {
      batch.insertAll(
        statisticScopeTable,
        entries,
        mode: InsertMode.insertOrReplace,
      );
    }).then((_) => true).catchError((error) {
      print('Error adding statistic scopes: $error');
      return false;
    });
  }
}
