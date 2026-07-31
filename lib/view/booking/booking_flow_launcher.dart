import 'package:booking/core/constants.dart';
import 'package:booking/main.dart' as app_globals;
import 'package:booking/provider/guests_provider.dart';
import 'package:booking/provider/login_provider.dart';
import 'package:booking/provider/package_provider.dart';
import 'package:booking/services/api_services.dart';
import 'package:booking/services/shared_preferences.dart';
import 'package:booking/view/booking_list/appointment_history.dart';
import 'package:booking/view/booking_list/booking_list.dart';
import 'package:booking/view/packages/packages.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Selects which screen the [BookingFlowLauncher] mounts.
///
/// The host app uses the same launcher in several places, passing a different
/// destination at each mount point:
/// * [packages] — the screening packages list (the original booking entry).
/// * [bookingList] — the user's bookings, mounted on the host's home page.
/// * [appointmentHistory] — past appointments, mounted from the hamburger menu.
enum BookingDestination { packages, bookingList, appointmentHistory }

/// A self-contained launcher for the Health Action Plan module.
///
/// This widget acts as the gateway for external applications. It handles:
/// 1. Persisting the [token], [baseURL], and [dbPtr] for API authentication.
/// 2. Initializing the booking-module providers.
/// 3. Rendering the screen selected by [destination] inside that shared scope,
///    so the host can mount any of the module's screens from different places
///    while reusing the exact same bootstrapping.
class BookingFlowLauncher  extends StatefulWidget {
  /// Which screen of the module to display. Defaults to [BookingDestination.packages]
  /// to preserve the original behaviour for existing call sites.
  final BookingDestination destination;

  final String opno;
  final String token;
  final String? baseURL;
  final String? dbPtr;
  final String? country;
  final String? currencySymbol;
  final String? deviceId;
  final String? razorpayKey;
  final bool isStandalone;
  final bool isBookingFlowEnabled;
  final bool isEmailMandatory;
  final bool isAppLoggedIn;
  final bool isOtpEnabled;

  /// When true, the launcher is being mounted inline inside a host screen
  /// (e.g. above a card on the home page) rather than as a full-page route.
  ///
  /// In this mode it renders no [Scaffold] and shows nothing (zero height)
  /// while the module is bootstrapping, so the host's layout is never pushed
  /// down by a spinner — the booking content simply appears once it loads.
  final bool embedded;

  /// Called after a slot is successfully blocked while the user is not
  /// authenticated. The host can use this to redirect away from the booking
  /// flow (e.g. to a login screen or the home tab).
  final VoidCallback? onUnauthorizedSlotBlocked;

  const BookingFlowLauncher({
    super.key,
    this.destination = BookingDestination.packages,
    required this.opno,
    required this.token,
    this.baseURL,
    this.dbPtr,
    this.country,
    this.currencySymbol,
    this.deviceId,
    this.razorpayKey,
    this.isStandalone = false,
    this.isBookingFlowEnabled = true,
    this.isEmailMandatory = false,
    this.isAppLoggedIn = true,
    this.isOtpEnabled = false,
    this.embedded = false,
    this.onUnauthorizedSlotBlocked,
  });

  @override
  State<BookingFlowLauncher> createState() =>
      _BookingFlowLauncherState();
}

class _BookingFlowLauncherState extends State<BookingFlowLauncher> {
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _initializeModule();
  }

  Future<void> _initializeModule() async {
   EasyLocalization.logger.enableLevels = [];

    // Propagate feature flags from the host into the module-level globals
    // that the rest of the codebase reads.
    isStandalone = widget.isStandalone;
    app_globals.isBookingFlowEnabled = widget.isBookingFlowEnabled;
    app_globals.isEmailMadatory = widget.isEmailMandatory;
    app_globals.isAppLoggedIn = widget.isAppLoggedIn;
    app_globals.isOtpEnabled = widget.isOtpEnabled;

    // Seed the auth token in memory only — never persisted, so each launch
    // uses exactly the token the host passes and no stale copy can cause 401s.
    ApiService.setAuthToken(widget.token);

    // Ensure the environment config is saved before the view loads.
    await SharedPreferenceController().setInitialControllerValues(
      baseURL: widget.baseURL,
      dbPtr: widget.dbPtr,
      country: widget.country,
      currencySymbol: widget.currencySymbol,
      deviceId: widget.deviceId,
      razorpayKey: widget.razorpayKey,
      opno: widget.opno,
    );

    if (mounted) {
      setState(() {
        _isReady = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      // When embedded inline in a host screen, take up no space while the
      // module bootstraps so nothing is shown until the content is ready.
      return widget.embedded
          ? const SizedBox.shrink()
          : const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PackagesProvider()),
        ChangeNotifierProvider(create: (_) => GuestProvider()),
        ChangeNotifierProvider(create: (_) => LoginProvider()),
      ],
      child: Builder(
        builder: (context) {
          // Give GuestProvider references to its sibling providers so it can
          // re-expose them on routes pushed via the root navigatorKey (which
          // sits above this MultiProvider scope).
          context.read<GuestProvider>()
            ..bindCompanionProviders(
              context.read<PackagesProvider>(),
              context.read<LoginProvider>(),
            )
            ..onUnauthorizedSlotBlocked = widget.onUnauthorizedSlotBlocked;
          return _screenForDestination(widget.destination);
        },
      ),
    );
  }

  /// Maps the requested [destination] to its screen. All screens are built
  /// inside the same provider scope set up in [build], so they share the
  /// module's auth token, environment config and providers.
  Widget _screenForDestination(BookingDestination destination) {
    switch (destination) {
      case BookingDestination.packages:
        return const Packages();
      case BookingDestination.bookingList:
        return BookingListScreen(embedded: widget.embedded);
      case BookingDestination.appointmentHistory:
        return const AppointmentHistory();
    }
  }
}
