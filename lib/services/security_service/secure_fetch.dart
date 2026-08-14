import 'dart:convert';
import 'dart:developer';
import 'package:booking/services/api_services.dart';
import 'package:booking/services/security_service/secure_headers.dart';
import 'package:booking/services/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'handle_401.dart';

/// Invoked when a request is still unauthorized after [handle401]'s
/// refresh-and-retry attempt — i.e. this module's own short-lived session is
/// unrecoverable. Set by the host via [BookingFlowLauncher.onUnauthorized]
/// so the host app can react (e.g. force a full app logout); this module has
/// no concept of the host's auth flow beyond its own access/refresh tokens.
void Function()? onUnauthorized;

class SecureFetchResponse {
  final bool ok;
  final int status;
  final dynamic data;

  SecureFetchResponse({
    required this.ok,
    required this.status,
    this.data,
  });
}

Future<SecureFetchResponse> secureFetch(
    {required String endpoint,
    String method = 'GET',
    dynamic body,
    Map<String, String> headers = const {},
    bool requireAuth = true,
    String? dbPtr}) async {
  final pref = await SharedPreferencesService.prefs;
  // Base URL, gateway toggle and signing credentials all come from the host
  // via BookingFlowLauncher (persisted by SharedPreferenceController) — there
  // is no hardcoded fallback.
  final baseUrl = pref.getString('url') ?? '';
  final gatewayEnabled = pref.getBool('apiGatewayEnabled') ?? true;
  final gatewayClientId = pref.getString('clientId');
  final gatewayClientSecret = pref.getString('clientSecret');
  final gatewayEnv = pref.getString('env');
  final httpMethod = method.toUpperCase();
  String dbptr = pref.getString('dbptr') ?? "";

  if (baseUrl.isEmpty) {
    log(
      'API ERROR: Base URL is empty. Ensure it is passed to BookingFlowLauncher by the host.',
    );
    return SecureFetchResponse(
      ok: false,
      status: 0,
      data: {'error': 'Base URL not configured'},
    );
  }

  String finalEndpoint = endpoint;

  if (httpMethod == 'GET' && body != null) {
    finalEndpoint = appendQueryParams(endpoint, body);
  }
  Future<http.Response> makeRequest() async {
    final secure = await createSecureHeaders(
      endpoint: finalEndpoint,
      method: httpMethod,
      body: (httpMethod == 'GET') ? null : body,
      gatewayEnabled: gatewayEnabled,
      clientId: gatewayClientId,
      clientSecret: gatewayClientSecret,
      env: gatewayEnv,
    );

    final prefs = await SharedPreferences.getInstance();
    // The host seeds the auth token in memory via ApiService.setAuthToken (it is
    // intentionally never persisted). The Dio path already reads it; secureFetch
    // must use the SAME token or every auth-required call 401s because the
    // 'token' pref key is never written. Fall back to prefs for legacy callers.
    final token = ApiService.authToken ?? prefs.getString('token');

    final fullUrl = baseUrl + finalEndpoint;

    final request = http.Request(
      httpMethod,
      Uri.parse(fullUrl),
    );
    Map<String, String> finalHeaders = {
      ...secure.headers,
      ...headers,
    };
    finalHeaders["db_ptr"] = dbPtr ?? dbptr;

    // Pass the user's NuraId (opno) supplied by the host as the `realId` header
    // so the backend can attribute every request to the user. Mirrors the Dio
    // ApiService path; opno is persisted under the "realId" pref key.
    final realId = pref.getString("realId") ?? "";
    if (realId.isNotEmpty) {
      finalHeaders["realId"] = realId;
    }
    // Attach token only if required
    if (requireAuth && token != null && token.isNotEmpty) {
      finalHeaders['Authorization'] = 'Bearer $token';
    }

    request.headers.addAll(finalHeaders);
    request.body =
        (httpMethod == 'GET' || httpMethod == 'DELETE') ? '' : secure.rawBody;
    // Debug builds only: these dumps include the bearer token, the signing
    // headers and patient data, none of which may reach release logs.
    if (kDebugMode) {
      debugPrint("----------- API REQUEST -----------");
      debugPrint("Url: $fullUrl");
      debugPrint("Method: $httpMethod");
      debugPrint("Require auth: $requireAuth");
      debugPrint("Token: ${requireAuth ? token : "Not used"}");

      log("Headers: ");
      finalHeaders.forEach((key, value) {
        debugPrint("$key: $value");
      });

      debugPrint(
        request.body.isNotEmpty ? "Body: ${request.body}" : "Body: empty",
      );
    }
    return request.send().then(http.Response.fromStream);
  }

  var response = await makeRequest();
  if (kDebugMode) {
    debugPrint("Response: ${response.statusCode} - ${response.body}");
  }
  if (response.statusCode == 401) {
    final newToken = await handle401();

    if (newToken != null) {
      response = await makeRequest();
    }
  }

  if (response.statusCode == 401) {
    onUnauthorized?.call();
  }

  dynamic data;
  try {
    data = jsonDecode(response.body);
  } catch (_) {
    data = response.body;
  }

  return SecureFetchResponse(
    ok: response.statusCode >= 200 && response.statusCode < 300,
    status: response.statusCode,
    data: data,
  );
}

String appendQueryParams(String url, dynamic body) {
  if (body == null) return url;

  Map<String, dynamic> map;

  if (body is String) {
    map = jsonDecode(body);
  } else if (body is Map<String, dynamic>) {
    map = body;
  } else {
    return url;
  }

  final uri = Uri.parse(url);

  final newQuery = {
    ...uri.queryParameters,
    ...map.map((k, v) => MapEntry(k, v.toString())),
  };

  return uri.replace(queryParameters: newQuery).toString();
}
