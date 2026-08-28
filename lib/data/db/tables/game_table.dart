import 'package:drift/drift.dart';
import 'package:tallee/core/enums.dart';

/// Maps stored ruleset names to [Ruleset] values.
/// Unknown names (e.g. the legacy 'multipleWinners' ruleset) fall back to
/// [Ruleset.singleWinner].
class RulesetConverter extends TypeConverter<Ruleset, String> {
  const RulesetConverter();

  @override
  Ruleset fromSql(String fromDb) =>
      Ruleset.values.asNameMap()[fromDb] ?? Ruleset.singleWinner;

  @override
  String toSql(Ruleset value) => value.name;
}

class GameTable extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get name => text()();
  TextColumn get ruleset => text().map(const RulesetConverter())();
  TextColumn get description => text()();
  TextColumn get color => textEnum<AppColor>()();
  TextColumn get icon => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
