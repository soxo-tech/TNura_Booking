import 'package:booking/core/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Singleton service for managing SharedPreferences.
class SharedPreferencesService {
  // Singleton instance
  static final SharedPreferencesService _instance =
      SharedPreferencesService._internal();

  /// Factory constructor to return the singleton instance.
  factory SharedPreferencesService() {
    return _instance;
  }

  SharedPreferencesService._internal();

  /// A future that completes with the SharedPreferences instance.
  static Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  /// Initializes the SharedPreferences instance.
  /// This method is not required to be explicitly called as SharedPreferences is initialized lazily.
  Future<void> setPreferences() async {
    await prefs;
  }
}

/// Controller class for managing and accessing shared preferences values.
class SharedPreferenceController {
  /// Persists the environment config supplied by the host.
  ///
  /// The auth token is intentionally NOT handled here — it is held in memory
  /// only via [ApiService.setAuthToken] so it can never go stale in storage.
  Future<void> setInitialControllerValues({
    String? baseURL,
    String? dbPtr,
    String? country,
    String? currencySymbol,
    String? deviceId,
    String? razorpayKey,
    String? opno,
    bool? apiGatewayEnabled,
    String? clientId,
    String? clientSecret,
    String? env,
  }) async {
    final pref = await SharedPreferencesService.prefs;
    if (baseURL != null) {
      await pref.setString("url", baseURL);
    }
    if (dbPtr != null) {
      await pref.setString("dbptr", dbPtr);
    }
    if (apiGatewayEnabled != null) {
      await pref.setBool("apiGatewayEnabled", apiGatewayEnabled);
    }
    if (clientId != null) {
      await pref.setString("clientId", clientId);
    }
    if (clientSecret != null) {
      await pref.setString("clientSecret", clientSecret);
    }
    if (env != null) {
      await pref.setString("env", env);
    }
    // Sent as the `realId` request header on every module API call.
    if (opno != null) {
      await pref.setString("realId", opno);
    }
    if (country != null) {
      await pref.setString(kSelectedCountry, country);
    }
    if (currencySymbol != null) {
      await pref.setString(currency, currencySymbol);
    }
    if (deviceId != null) {
      await pref.setString(kDeviceId, deviceId);
    }
    if (razorpayKey != null) {
      await pref.setString(kRazorpayKey, razorpayKey);
    }
  }
}
