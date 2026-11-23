import 'package:tallee/core/extensions/string_extensions.dart';

extension ListExtension<T> on List<T> {
  void sortByLowercaseName(String Function(T) name) =>
      sort((a, b) => name(a).compareIgnoringCaseTo(name(b)));
}
