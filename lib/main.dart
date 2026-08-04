import 'package:booking/services/navigation_services.dart';
import 'package:booking/view/booking/booking_flow_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Master switch for the booking flow.
///
/// Toggled by the host app (or by [_kStandaloneBookingFlowEnabled] in
/// standalone mode) to hide the booking entry point when the feature is
/// disabled remotely.
bool isBookingFlowEnabled = true;

/// Whether a guest must supply an email address to proceed.
///
/// When `false`, the email field is optional in the guest form.
bool isEmailMadatory = false;

/// Whether the user is authenticated against the host app.
///
/// Drives flow-control inside the booking module: logged-in users skip
/// billing-user OTP verification and route directly to confirmation after
/// slot blocking, while guests are bounced back to the host for login.
bool isAppLoggedIn = true;

/// Whether OTP verification is required for guest contact details.
bool isOtpEnabled = false;

/// Bumped every time a booking is successfully created so any mounted
/// booking-list view can refetch itself.
///
/// The embedded booking list on the host's home page is built in its own
/// provider scope and only loads once in `initState`; the package booking flow
/// runs in a separate scope and pops back to the home route without rebuilding
/// it. Listening to this notifier lets the list refresh when a new appointment
/// is created instead of waiting for an app restart.
final ValueNotifier<int> bookingListRefreshTick = ValueNotifier<int>(0);

// ─── Standalone-only hardcoded values ──────────────────────────────────────
// When this module is embedded in the main project, these come from the host
// app (token + baseURL + dbPtr + opno via the BookingFlowLauncher params, and
// country/currency from Remote Config). Standalone development runs without
// the host, so we seed them here.

/// Hardcoded operator number used only when running standalone.
const String _kStandaloneOpno = 'N1KZ89';

/// Hardcoded auth token used only when running standalone.
const String _kStandaloneToken =
    '';

/// Hardcoded API base URL used only when running standalone.
const String _kStandaloneBaseURL = '';

/// Hardcoded database pointer used only when running standalone.
const String _kStandaloneDbPtr = '';

/// Hardcoded country used only when running standalone.
const String _kStandaloneCountry = '';

/// Hardcoded currency symbol used only when running standalone.
const String _kStandaloneCurrency = '';

/// Hardcoded FCM device id used only when running standalone.
const String _kStandaloneDeviceId =
    '';

/// Hardcoded Razorpay test key used only when running standalone.
const String _kStandaloneRazorpayKey = '';

/// Standalone default for the booking-flow master switch.
const bool _kStandaloneBookingFlowEnabled = false;

/// Standalone default for email-mandatory flag.
const bool _kStandaloneEmailMandatory = false;

/// Standalone default for app-logged-in flag.
const bool _kStandaloneAppLoggedIn = false;

/// Standalone default for OTP-enabled flag.
const bool _kStandaloneOtpEnabled = false;

/// Standalone default for the API-gateway signing toggle. When `true`
/// (the default), [_kStandaloneClientId]/[_kStandaloneClientSecret]/
/// [_kStandaloneEnv] must be filled in locally for signed requests to work —
/// there is no built-in fallback. Set to `false` to send plain, unsigned
/// requests during standalone testing instead.
const bool _kStandaloneApiGatewayEnabled = true;

/// Hardcoded API gateway client id used only when running standalone. Fill
/// in locally for testing — never commit a real value here.
const String _kStandaloneClientId = '';

/// Hardcoded API gateway client secret used only when running standalone.
/// Fill in locally for testing — never commit a real value here.
const String _kStandaloneClientSecret = '';

/// Hardcoded API gateway environment tag used only when running standalone.
/// Fill in locally for testing — never commit a real value here.
const String _kStandaloneEnv = '';

/// Application entry point.
///
/// Initialises Flutter bindings, then launches [Booking] with the standalone
/// seed values defined above.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Silence EasyLocalization's verbose logs.
  EasyLocalization.logger.enableLevels = [];

  runApp(const Booking(
    opno: _kStandaloneOpno,
    token: _kStandaloneToken,
    baseURL: _kStandaloneBaseURL,
    dbPtr: _kStandaloneDbPtr,
    country: _kStandaloneCountry,
    currencySymbol: _kStandaloneCurrency,
    deviceId: _kStandaloneDeviceId,
    razorpayKey: _kStandaloneRazorpayKey,
    isStandalone: true,
    isBookingFlowEnabled: _kStandaloneBookingFlowEnabled,
    isEmailMandatory: _kStandaloneEmailMandatory,
    isAppLoggedIn: _kStandaloneAppLoggedIn,
    isOtpEnabled: _kStandaloneOtpEnabled,
    apiGatewayEnabled: _kStandaloneApiGatewayEnabled,
    clientId: _kStandaloneClientId,
    clientSecret: _kStandaloneClientSecret,
    env: _kStandaloneEnv,
  ));
}

/// Root widget of the Booking module.
///
/// Wraps a [MaterialApp] around [BookingFlowLauncher] and exposes the
/// host-supplied configuration (auth, locale, payment keys, feature flags).
/// When [isStandalone] is `true` the values are seeded by [main]; otherwise
/// the host app passes them in.
class Booking extends StatelessWidget {
  /// Operator number identifying the calling application/customer.
  final String opno;

  /// Bearer token used to authenticate API calls.
  final String token;

  /// Base URL of the booking backend.
  final String baseURL;

  /// Database pointer selecting which tenant database to query.
  final String dbPtr;

  /// ISO country name used for locale-specific behaviour (e.g. phone codes).
  final String? country;

  /// Currency symbol displayed alongside prices.
  final String? currencySymbol;

  /// FCM device id used for push notifications and order attribution.
  final String? deviceId;

  /// Razorpay key used to initialise the checkout SDK.
  final String? razorpayKey;

  /// Whether the module is running outside the host app.
  final bool isStandalone;

  /// Master toggle for the booking flow (mirrors [isBookingFlowEnabled]).
  final bool isBookingFlowEnabled;

  /// Whether guests must provide an email address.
  final bool isEmailMandatory;

  /// Whether the user is signed in against the host app.
  final bool isAppLoggedIn;

  /// Whether OTP verification is required for guest contact details.
  final bool isOtpEnabled;

  /// Whether calls to the booking backend should be signed for the host's
  /// API gateway (mirrors [BookingFlowLauncher.apiGatewayEnabled]).
  final bool apiGatewayEnabled;

  /// API gateway client id, supplied by the host when [apiGatewayEnabled].
  final String? clientId;

  /// API gateway client secret, supplied by the host when [apiGatewayEnabled].
  final String? clientSecret;

  /// API gateway environment tag, supplied by the host when [apiGatewayEnabled].
  final String? env;

  /// Creates the root [Booking] widget.
  ///
  /// [opno] and [token] are required; all other fields default to safe values
  /// for embedded use.
  const Booking({
    super.key,
    required this.opno,
    required this.token,
    this.baseURL = '',
    this.dbPtr = '',
    this.country,
    this.currencySymbol,
    this.deviceId,
    this.razorpayKey,
    this.isStandalone = false,
    this.isBookingFlowEnabled = true,
    this.isEmailMandatory = false,
    this.isAppLoggedIn = true,
    this.isOtpEnabled = false,
    this.apiGatewayEnabled = true,
    this.clientId,
    this.clientSecret,
    this.env,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      home: BookingFlowLauncher(
        opno: opno,
        token: token,
        // baseURL: baseURL,
        dbPtr: dbPtr,
        country: country,
        currencySymbol: currencySymbol,
        deviceId: deviceId,
        razorpayKey: razorpayKey,
        isStandalone: isStandalone,
        isBookingFlowEnabled: isBookingFlowEnabled,
        isEmailMandatory: isEmailMandatory,
        isAppLoggedIn: isAppLoggedIn,
        isOtpEnabled: isOtpEnabled,
        apiGatewayEnabled: apiGatewayEnabled,
        clientId: clientId,
        clientSecret: clientSecret,
        env: env,
      ),
    );
  }
}
