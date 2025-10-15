import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

const String _envEndpoint = String.fromEnvironment('BACKEND_URL', defaultValue: '');

String get backendEndpoint {
  if (_envEndpoint.isNotEmpty) return _envEndpoint;
  if (kIsWeb) return 'http://localhost:8000/api/generate-game';
  if (Platform.isAndroid) return 'http://10.0.2.2:8000/api/generate-game';
  return 'http://127.0.0.1:8000/api/generate-game';
}