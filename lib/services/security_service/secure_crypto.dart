import 'dart:convert';
import 'package:crypto/crypto.dart';

Future<String> sha256Hex(String input) async {
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

String hmacSha256Base64Url(String key, String data) {
  final keyBytes = utf8.encode(key);
  final dataBytes = utf8.encode(data);

  final hmac = Hmac(sha256, keyBytes);
  final digest = hmac.convert(dataBytes);

  return base64Url.encode(digest.bytes).replaceAll('=', '');
}

String canonicalizeEndpoint(String endpoint) {
  final uri = Uri.parse(endpoint);

  final params = uri.queryParameters.entries
      .where((e) => e.value.isNotEmpty && e.value != 'null')
      .toList()
    ..sort((a, b) => a.key.compareTo(b.key));

  final query = params.map((e) => '${e.key}=${e.value}').join('&');

  return query.isNotEmpty ? '${uri.path}?$query' : uri.path;
}
