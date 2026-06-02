import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:booking/core/constants.dart';
import 'package:booking/services/shared_preferences.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService extends ChangeNotifier {
  static RemoteConfigService? _instance;

  RemoteConfigService._internal();

  factory RemoteConfigService() {
    return _instance ??= RemoteConfigService._internal();
  }

  static RemoteConfigService get instance =>
      _instance ??= RemoteConfigService._internal();

  late final FirebaseRemoteConfig remoteConfig;

  final Completer<void> _initCompleter = Completer<void>();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  Future<void> init() async {
    remoteConfig = FirebaseRemoteConfig.instance;

    const minFetchInterval = 12;

    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(minutes: minFetchInterval),
      ),
    );

    await remoteConfig.setDefaults({
      "version": "{}",
      "countries": "{}",
      "templates": "{}",
      "templates_country": "{}",
      "translation_en": "{}",
      "translation_vi": "{}",
      "translation_mn": "{}",
    });

    await remoteConfig.fetchAndActivate();
    await _getBaseUrl();
    _initialized = true;
    _initCompleter.complete();
    notifyListeners();

    if (!kIsWeb) {
      remoteConfig.onConfigUpdated.listen((event) async {
        log('Updated keys: ${event.updatedKeys}', name: 'Remote Config');
        await remoteConfig.activate();
        await _getBaseUrl();
        notifyListeners();
      });
    }
  }

  Future<void> get waitUntilReady => _initCompleter.future;

  /// Method to set base url on basis of selected country
  /// If country is not found , break the funtion
  bool _isBookingFlowEnabled = false;
  bool get isBookingFlowEnabled => _isBookingFlowEnabled;
  bool _isGuestBookingEnabled = false;
  bool get isGuestBookingEnabled => _isGuestBookingEnabled;
   bool _isSyncareLinkEnabled = false;
  bool get isSyncareLinkEnabled => _isSyncareLinkEnabled;
// Inside RemoteConfigService class
  Future<void> refreshConfig() async {
    log("Manual config refresh triggered for country switch.");
    await _getBaseUrl();
    notifyListeners();
  }

  Future<void> _getBaseUrl() async {
    // Get the selected country from shared preferences
    final prefs = await SharedPreferencesService.prefs;
    String? selectedCountry = prefs.getString(kSelectedCountry);

// Decode countries
    final countriesList = jsonDecode(remoteConfig.getString("countries"));

    if (countriesList is! List || countriesList.isEmpty) {
      log("No countries found in remote config.");
      return;
    }

// FALLBACK: pick first country if none selected
    if (selectedCountry == null || selectedCountry.isEmpty) {
      selectedCountry = countriesList.first["country"];
      await prefs.setString(kSelectedCountry, selectedCountry!);
      log("No country selected. Defaulting to $selectedCountry");
    }

// Find selected country
    final selectedCountryJson = countriesList.firstWhere(
      (country) => country["country"] == selectedCountry,
      orElse: () => countriesList.first,
    );

    log("Selected country JSON: $selectedCountryJson");

    await Future.wait([
      prefs.setString(kCurrentBaseUrl, selectedCountryJson["url"] ?? ""),
      prefs.setString(kCurrentDbPtr, selectedCountryJson["dbptr"] ?? ""),
      prefs.setString(kCurrentPdfUrl, selectedCountryJson["pdf_url"] ?? ""),
      prefs.setString(
          kCurrentChatUrl, selectedCountryJson["chat_bot_url"] ?? ""),
      prefs.setString(kRazorpayKey, selectedCountryJson["razorpay_key"] ?? ""),
      prefs.setBool(kIsDetailedResultsEnabled,
          selectedCountryJson[kIsDetailedResultsEnabled] ?? false),
      prefs.setBool(kIsHealthScoreEnabled,
          selectedCountryJson[kIsHealthScoreEnabled] ?? false),
      prefs.setBool(
          kIsReferEnabled, selectedCountryJson[kIsReferEnabled] ?? false),
      prefs.setBool(
          kIsShareEnabled, selectedCountryJson[kIsShareEnabled] ?? false),
      prefs.setBool(kIsEmailLoginEnabled,
          selectedCountryJson[kIsEmailLoginEnabled] ?? false),
      prefs.setBool(kIsMobileLoginEnabled,
          selectedCountryJson[kIsMobileLoginEnabled] ?? false),
      prefs.setBool(kIsUsernameLoginEnabled,
          selectedCountryJson[kIsUsernameLoginEnabled] ?? false),
      prefs.setString(currency, selectedCountryJson['currency'] ?? ""),
      prefs.setString(privacyUrl, selectedCountryJson['privacy_url'] ?? "")
    ]);

    _isBookingFlowEnabled = selectedCountryJson[kIsBookingFlowEnabled] ?? false;

    _isGuestBookingEnabled =
        selectedCountryJson[kIsGuestBookingEnabled] ?? false;
    _isSyncareLinkEnabled = selectedCountryJson[kIsSyncareLinkEnabled] ?? false;

    notifyListeners();
  }

  // Helper to safely get decoded values after init
  Future<dynamic> _getDecodedValue(String key) async {
    await waitUntilReady;
    final value = remoteConfig.getString(key);
    log(value);
    try {
      return jsonDecode(value);
    } catch (e) {
      log("Error decoding key $key: $e", name: "RemoteConfigService");
      return {};
    }
  }

  // Public getters
  Future<dynamic> get requiredVersion => _getDecodedValue('version');
  Future<dynamic> get countries => _getDecodedValue('countries');
  Future<dynamic> get templatesV1 => _getDecodedValue('templates');
  Future<dynamic> get templatesV2 => _getDecodedValue('templates_country');
  Future<dynamic> get translationEn => _getDecodedValue('translation_en');
  Future<dynamic> get translationVi => _getDecodedValue('translation_vi');
  Future<dynamic> get translationMn => _getDecodedValue('translation_mn');
}