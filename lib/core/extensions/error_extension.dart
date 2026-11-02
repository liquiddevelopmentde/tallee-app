import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

extension ErrorExtension on Object {
  /// Function to classify connection/network exceptions
  bool get isNetworkError {
    return this is SocketException ||
        this is TimeoutException ||
        this is HandshakeException ||
        this is http.ClientException ||
        toString().contains('SocketException') ||
        toString().contains('Failed host lookup');
  }
}
