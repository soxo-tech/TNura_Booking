import 'dart:convert';

import 'secure_crypto.dart';
import 'device.dart';
import 'package:uuid/uuid.dart';

class SecureHeaderResult {
  final String canonicalEndpoint;
  final String rawBody;
  final Map<String, String> headers;

  SecureHeaderResult({
    required this.canonicalEndpoint,
    required this.rawBody,
    required this.headers,
  });
}

/// Builds the headers/body for a booking-backend request.
///
/// When [gatewayEnabled] is true (the default, matching today's behaviour),
/// the request is HMAC-signed using the [clientId]/[clientSecret]/[env]
/// supplied by the host via `BookingFlowLauncher`. When false, only a plain
/// `Content-Type` header is returned, mirroring the host app's own "gateway
/// disabled" plain-call shape.
Future<SecureHeaderResult> createSecureHeaders({
  required String endpoint,
  required String method,
  dynamic body,
  bool gatewayEnabled = true,
  String? clientId,
  String? clientSecret,
  String? env,
}) async {
  final httpMethod = method.toUpperCase();

  final rawBody = (httpMethod == 'GET' || httpMethod == 'DELETE')
      ? ''
      : (body == null ? '' : (body is String ? body : jsonEncode(body)));

  final canonicalEndpoint = cleanNullParams(endpoint);

  if (!gatewayEnabled) {
    return SecureHeaderResult(
      canonicalEndpoint: canonicalEndpoint,
      rawBody: rawBody,
      headers: {
        if (httpMethod != 'GET' && httpMethod != 'DELETE')
          'Content-Type': 'application/json',
      },
    );
  }

  if (clientId == null ||
      clientId.isEmpty ||
      clientSecret == null ||
      clientSecret.isEmpty ||
      env == null ||
      env.isEmpty) {
    throw StateError(
      'API gateway is enabled but clientId/clientSecret/env were not '
      'supplied by the host via BookingFlowLauncher.',
    );
  }

  final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  final nonce = const Uuid().v4();

  final deviceId = await getOrCreateDeviceId();
  final fingerprint = await createDeviceFingerprint();

  final bodyHash = await sha256Hex(rawBody);

  final canonical =
      '$httpMethod\n$canonicalEndpoint\n$timestamp\n$nonce\n$bodyHash';
  final certToken = hmacSha256Base64Url(clientSecret, canonical);

  return SecureHeaderResult(
    canonicalEndpoint: canonicalEndpoint,
    rawBody: rawBody,
    headers: {
      'X-Client-Id': clientId,
      'X-Client-Secret': clientSecret,
      'X-Cert-Token': certToken,
      'X-Timestamp': timestamp,
      'X-Nonce': nonce,
      'X-Device-Id': deviceId,
      'X-Fingerprint': fingerprint,
      if (httpMethod != 'GET' && httpMethod != 'DELETE')
        'Content-Type': 'application/json',
      'X-env': env
    },
  );
}

String cleanNullParams(String url) {
  final uri = Uri.parse(url);

  final params = Map.fromEntries(
    uri.queryParameters.entries.where(
      (e) => e.value != null && e.value != "null" && e.value!.isNotEmpty,
    ),
  );

  final sortedKeys = params.keys.toList()..sort();

  final query = sortedKeys
      .map((k) => '$k=${Uri.encodeQueryComponent(params[k]!)}')
      .join('&');

  final path = uri.path.startsWith('/') ? uri.path : '/${uri.path}';

  return query.isEmpty ? path : '$path?$query';
}
