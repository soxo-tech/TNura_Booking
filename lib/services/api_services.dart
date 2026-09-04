import 'dart:async';
import 'dart:io';
import 'package:booking/services/navigation_services.dart';
import 'package:booking/services/shared_preferences.dart';
import 'package:dio/dio.dart';

/// Enum to define the HTTP methods supported by [ApiService].
enum ApiMethod { get, post, delete, update, patch }

/// A service class to handle API requests using [Dio].
class ApiService {
  static Map errorResponse = {};
  static Dio dio = Dio();

  /// The auth token in use for the current session.
  ///
  /// Seeded from [BookingFlowLauncher] on every launch and held in memory only
  /// — it is intentionally NOT persisted. The host app owns the token's
  /// lifecycle, so each launch uses exactly the token the host passes and no
  /// stale copy can linger in storage to cause spurious 401s.
  static String? authToken;

  /// Sets the in-memory auth token for the current session.
  ///
  /// [token] is the value supplied by the host (or by standalone seed values).
  static void setAuthToken(String token) {
    if (token.length > 5) {
      authToken = token;
    }
  }

  /// Clears the in-memory token.
  ///
  /// This should be called when logging out or when the token expires. Since
  /// the token is never persisted, there is nothing to remove from storage.
  static Future<void> tokenRemover() async {
    authToken = null;
    dio.options.headers["Authorization"] = "";
  }

  /// Sets up and executes an API request using [Dio].
  ///
  /// [method] specifies the HTTP method to use.
  /// [url] is the endpoint for the request.
  /// [data] and [queryParameters] are optional parameters for the request.
  /// [onSendProgress] and [onReceiveProgress] are optional callbacks for progress reporting.
  /// [options] provides additional [Dio] options.
  /// [dbPtr] and [bUrl] provide additional headers and base URL respectively.
  ///
  /// Returns the [Response] of the request or `null` if an error occurs.
  static Future<Response<dynamic>?> apiMethodSetup({
    required ApiMethod method,
    required String url,
    var data,
    var queryParameters,
    Function(int, int)? onSendProgress,
    Function(int, int)? onReceiveProgress,
    Options? options,
    String? dbPtr,
    String? bUrl,
  }) async {
    final pref = await SharedPreferencesService.prefs;

    String? baseURL = pref.getString('url');
    String dbptr = pref.getString('dbptr') ?? "";

    // Priority: explicit per-call [bUrl] > host-supplied value in prefs.
    // There is no hardcoded fallback — the host must supply a base URL.
    final finalBaseUrl = bUrl ?? baseURL ?? '';
    if (finalBaseUrl.isEmpty) {
      return null;
    }

    dio.options.baseUrl = finalBaseUrl;
    dio.options.connectTimeout = const Duration(seconds: 120);
    dio.options.receiveTimeout = const Duration(seconds: 120);
    dio.options.headers["db_ptr"] = dbPtr ?? dbptr;

    // Pass the user's NuraId (real_id) supplied by the host as the `realId`
    // header so the backend can attribute every request to the user.
    final realId = pref.getString("realId") ?? "";
    if (realId.isNotEmpty) {
      dio.options.headers["realId"] = realId;
    }

    if (!dio.interceptors.any((e) => e is TokenInterceptor)) {
      dio.interceptors.add(TokenInterceptor(dio));
    }

    if (options != null && options.headers?["Authorization"] != null) {
      dio.options.headers["Authorization"] = options.headers?["Authorization"];
    }

    try {
      Response? response;
      switch (method) {
        case ApiMethod.get:
          response = data != null
              ? await dio.get(
                  url,
                  queryParameters: data,
                  options:
                      options ??
                      Options(receiveTimeout: const Duration(minutes: 2)),
                )
              : await dio.get(
                  url,
                  options:
                      options ??
                      Options(receiveTimeout: const Duration(minutes: 2)),
                );
          break;
        case ApiMethod.post:
          response = await dio.post(
            url,
            data: data,
            queryParameters: queryParameters,
            options:
                options ?? Options(receiveTimeout: const Duration(minutes: 2)),
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          );
          break;

        case ApiMethod.delete:
          response = await dio.delete(url);
          break;
        case ApiMethod.update:
          response = await dio.put(
            url,
            data: data,
            queryParameters: queryParameters,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          );
          break;
        case ApiMethod.patch:
          response = await dio.patch(
            url,
            data: data,
            queryParameters: queryParameters,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          );
          break;
      }
      return response;
    } on DioException catch (e) {
      // Only the timeouts and a dead connection say anything to the user;
      // every other failure — a 500 included — is left to the caller, which
      // reads the null returned below.
      if (e.type == DioExceptionType.receiveTimeout) {
        showSnackBar(scaffoldMessengerKey.currentContext!, 'Receive Timeout');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        showSnackBar(
          scaffoldMessengerKey.currentContext!,
          'Connection Timeout',
        );
      } else if (e.error is SocketException) {
        errorResponse["status"] = "101";
        errorResponse["message"] = "Internet error";
      }
    }
    return null;
  }
}

class TokenInterceptor extends Interceptor {
  final Dio dio;
  // ignore: unused_field
  final bool _isRefreshing = false;
  // ignore: unused_field
  Completer<void>? _refreshCompleter;

  TokenInterceptor(this.dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    /// Skip auth logic for login/refresh APIs
    if (options.extra["skipAuth"] == true) {
      return handler.next(options);
    }

    final token = ApiService.authToken;

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    options.headers['Content-Type'] = 'application/json';
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.requestOptions.extra["skipAuth"] == true) {
      return handler.next(err);
    }

    return super.onError(err, handler);
  }

  // ignore: unused_element
  Future<void> _retryWithNewToken(
    DioException err,
    ErrorInterceptorHandler handler,
    String token,
  ) async {
    try {
      final requestOptions = err.requestOptions;

      final retryResponse = await dio.request(
        requestOptions.path,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        options: Options(
          method: requestOptions.method,
          headers: {
            ...requestOptions.headers,
            "Authorization": "Bearer $token",
          },
          extra: requestOptions.extra,
        ),
      );
      return handler.resolve(retryResponse);
    } catch (_) {
      // Nothing to recover here: this failure was only ever logged.
    }
    return handler.next(err);
  }
}

Timer? _throttle;

void throttledCall(
  Function fn, {
  Duration duration = const Duration(seconds: 1),
}) {
  if (_throttle?.isActive ?? false) return;
  _throttle = Timer(duration, () {});
  fn();
}
