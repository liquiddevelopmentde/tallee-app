abstract class MatchShareException implements Exception {}

class NetworkException extends MatchShareException {}

class ServerException extends MatchShareException {
  final int statusCode;
  ServerException(this.statusCode);
}

class ParsingException extends MatchShareException {}

class MatchAlreadyExistsException extends MatchShareException {
  @override
  String toString() => 'Match already exists';
}
