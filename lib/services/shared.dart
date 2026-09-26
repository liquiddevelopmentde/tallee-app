import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:json_schema/json_schema.dart';

/// Helper method to read the content of [file] as a UTF-8 string.
/// Returns `null` if the file could not be read.
Future<String?> readFileContent({required PlatformFile file}) async {
  final Uint8List bytes;
  try {
    bytes = await file.readAsBytes();
  } catch (_) {
    return null;
  }
  return utf8.decode(bytes);
}

/// Validates the given JSON string against the schema.
Future<bool> validateJsonSchema({
  required String jsonString,
  required String schemaAssetPath,
}) async {
  try {
    final schemaString = await rootBundle.loadString(schemaAssetPath);
    final schema = JsonSchema.create(json.decode(schemaString));
    final jsonData = json.decode(jsonString);
    final result = schema.validate(jsonData);

    return result.isValid;
  } catch (exception) {
    return false;
  }
}

bool isSchemaVersionCorrect({
  required Map<String, dynamic> jsonMap,
  required int schemaVersion,
}) {
  final version = jsonMap['version'];
  if (version is int && version == schemaVersion) {
    return true;
  }
  return false;
}
