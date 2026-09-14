import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:json_schema/json_schema.dart';

/// Helper method to read file content from either bytes or path
Future<String?> readFileContent({required PlatformFile file}) async {
  if (file.bytes != null) return utf8.decode(file.bytes!);
  if (file.path != null) return await File(file.path!).readAsString();
  return null;
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
  } catch (e, stack) {
    print('[validateJsonSchema] $e');
    print(stack);
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
