import 'dart:convert';

import 'package:http/http.dart' as http;

/// Generates a human readable error message from a backend [response].
///
/// Our backend returns JSON payloads with a `detail` field when something goes
/// wrong (for example when the image upload is missing). The helper inspects
/// the response body and surfaces that detail so the UI can show a meaningful
/// message instead of just the status code.
String describeBackendError(http.Response response) {
  final status = response.statusCode;
  final body = response.body.trim();

  if (body.isNotEmpty) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final detail = decoded['detail'];
        if (detail is String && detail.trim().isNotEmpty) {
          return 'Backend error $status: ${detail.trim()}';
        }
        final message = decoded['message'];
        if (message is String && message.trim().isNotEmpty) {
          return 'Backend error $status: ${message.trim()}';
        }
      }
    } catch (_) {
      // Fall through and use the raw response body below.
    }

    return 'Backend error $status: $body';
  }

  return 'Backend error $status';
}