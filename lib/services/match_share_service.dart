import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tallee/data/models/models.dart';
import 'package:tallee/services/share_exceptions.dart';

class MatchShareService {
  Future<String> getShareToken(Match match) async {
    try {
      final response = await http.post(
        Uri.parse('https://10.0.2.2:8000/v1/shares'),
        body: jsonEncode(match.toJson()),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 201) {
        throw ServerException(response.statusCode);
      }

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (!data.containsKey('token')) {
        throw ParsingException();
      }

      return data['token'] as String;
    } on SocketException {
      // Wenn kein Internet oder Server down
      throw NetworkException();
    } on FormatException {
      // Wenn jsonDecode fehlschlägt
      throw ParsingException();
    }
  }

  Future<Match> getMatchByToken(String token) async {
    final response = await http.get(
      Uri.parse('https://10.0.2.2:8000/v1/shares'),
      headers: {'token': token},
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Match.fromJson(data);
    } else {
      throw Exception('Failed to get match by token.');
    }
  }

  Future<void> shareMatchAsFile(Match match) async {
    String formattedMatchName = match.name.replaceAll(' ', '_');
    var filename = '$formattedMatchName.tallee';
    final temp = await getTemporaryDirectory();
    final path = '${temp.path}/$filename';
    File(path).writeAsString(jsonEncode(match));
    await SharePlus.instance.share(
      ShareParams(
        text: 'Here is the shared match "${match.name}"',
        title: 'Tallee Match Share',
        files: [XFile(path)],
      ),
    );
    //TODO: add locs
  }

  Future<void> saveMatchToCustomLocation(Match match) async {
    String formattedMatchName = match.name.replaceAll(' ', '_');
    var filename = '$formattedMatchName.tallee';

    String jsonString = jsonEncode(match.toJson());
    Uint8List fileBytes = utf8.encode(jsonString);

    await FilePicker.saveFile(
      dialogTitle: 'Choose where to save your match:',
      fileName: filename,
      bytes: fileBytes,
    );
    // TODO: add locs
  }
}
