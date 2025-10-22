import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

Future<http.MultipartFile> createImageMultipart(
    String fieldName,
    XFile file,
    ) async {
  final bytes = await file.readAsBytes();
  final guessedMime = lookupMimeType(file.path, headerBytes: bytes);
  MediaType? mediaType;
  if (guessedMime != null) {
    try {
      final parsed = MediaType.parse(guessedMime);
      if (parsed.type == 'image') {
        mediaType = parsed;
      }
    } catch (_) {
      mediaType = null;
    }
  }

  mediaType ??= MediaType('image', 'jpeg');

  final fileName = file.name.trim().isNotEmpty
      ? file.name
      : file.path.split(RegExp(r'[\\/]')).last;

  return http.MultipartFile.fromBytes(
    fieldName,
    bytes,
    filename: fileName.isEmpty ? 'upload.jpg' : fileName,
    contentType: mediaType,
  );
}