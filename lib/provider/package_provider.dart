import 'dart:convert';

import 'package:booking/core/constants.dart';
import 'package:booking/main.dart';
import 'package:booking/model/booking_flow_branches_list.dart';
import 'package:booking/model/branches_model.dart';
import 'package:booking/model/packages_list_model.dart';
import 'package:booking/provider/guests_provider.dart';
import 'package:booking/provider/login_provider.dart';
import 'package:booking/services/security_service/secure_fetch.dart';
import 'package:booking/view/booking/booking.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/env.dart';
import '../../services/shared_preferences.dart';

/// A provider for managing package and branch information in the application.
class PackagesProvider extends ChangeNotifier {
  /// The currently selected location or branch description.
  String selectedLocation = 'Select Location'.tr();

  /// A list of branches fetched from the API.
  List<BranchResult> branches = [];

  /// Updates the selected branch based on the provided index.
  ///
  /// [index] - The index of the selected branch in the `branches` list.
  void chooseBranch(int index) {
    selectedLocation = branches[index].description ?? "";
    notifyListeners();
  }

  /// Init the package screen

  bool isInitializing = false;
  bool isBookingNowButtonLoading = false;

  void setBookingLoading(bool value) {
    isBookingNowButtonLoading = value;
    notifyListeners();
  }

  Future<void> init(BuildContext context) async {
    isInitializing = true;
    notifyListeners();
    final prefs = await SharedPreferencesService.prefs;

    /// The selected country is whatever the host launcher (or the standalone
    /// bootstrap) seeded into SharedPreferences. Booking's RemoteConfigService
    /// is never registered as a Provider in either mode, so there is no remote
    /// country list to read here — prefs is the single source of truth.
    final currentCountry = prefs.getString(kSelectedCountry);
    if (currentCountry != null && currentCountry.isNotEmpty) {
      selectedCountry = currentCountry;
    }
    isInitializing = false;
    notifyListeners();
    if (!context.mounted) return;
    await getBookingFlowBranches(context, isInitial: true);
  }

  /// Fetches the list of branches from the API and updates the `branches` list.
  ///
  /// Uses the country preference from shared preferences to determine the correct database pointer.
  Future<void> getBranches() async {
    final pref = await SharedPreferencesService.prefs;
    String country = pref.getString('country') ?? "India";

    await secureFetch(
      method: 'GET',
      endpoint: Env().branchListAPI,
      dbPtr: country == 'Mongolia' ? 'nuramho' : null,
    ).then((response) {
      var json = response.data;
      branches = BranchesModel.fromJson(json).result ?? [];
      notifyListeners();
    });
  }

  LinearGradient parseGradient(String? gradientString) {
    // Return default gradient
    if (gradientString == null || gradientString.isEmpty) {
      return defaultGradient();
    }

    List<Color> colors = [];

    // Extract hex colors
    RegExp hexRegex = RegExp(r'#([A-Fa-f0-9]{6})');
    Iterable<Match> hexMatches = hexRegex.allMatches(gradientString);
    colors.addAll(
      hexMatches.map((match) => Color(int.parse('0xFF${match.group(1)}'))),
    );

    // Extract RGB/RGBA colors
    RegExp rgbRegex = RegExp(
      r'rgb(a)?\((\d+),\s*(\d+),\s*(\d+)(,\s*([\d.]+))?\)',
    );
    Iterable<Match> rgbMatches = rgbRegex.allMatches(gradientString);
    colors.addAll(
      rgbMatches.map((match) {
        int r = int.parse(match.group(2)!);
        int g = int.parse(match.group(3)!);
        int b = int.parse(match.group(4)!);

        return Color.fromARGB(1, r, g, b);
      }),
    );

    // If no valid colors are found, return default gradient
    if (colors.isEmpty) {
      return defaultGradient();
    }

    return LinearGradient(
      colors: colors,
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
  }

  LinearGradient defaultGradient() {
    // Default colors
    return const LinearGradient(
      colors: [Color(0xFFFAC140), Color(0xFFBB7A1C)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
  }

  bool isPackagesListLoading = false;
  List<PackagesListModel> packagesList = [];

  int? selectedCountryIndex;
  int? selectedBranchIndex;
  String? selectedCountry;
  String? selectedBranch;
  bool loggedInFlag = false;

  /// A list of booking branches fetched from the API.
  List<BookingBranches> bookingFlowBranches = [];
  String? selectedBranchDbPtr;
  bool isBranchListLoading = false;
  bool isBranchListLoadingSuccess = false;
  bool isBranchListLoadingInitial = false;

  Future<void> getBookingFlowBranches(
    BuildContext context, {
    bool isInitial = false,
  }) async {
    isBranchListLoadingSuccess = false;
    packagesList = [];

    if (isInitial) {
      isBranchListLoadingInitial = true;
      notifyListeners();
    } else {
      isBranchListLoading = true;
      notifyListeners();
    }

    final pref = await SharedPreferencesService.prefs;
    String? dbptr = pref.getString('dbptr');

    if (dbptr == null || dbptr.isEmpty) {
      // Nothing to fetch against. Clear the loading flags on the way out, or
      // everything gated on them — the Packages screen, and now
      // [ensurePackagesLoaded]'s callers — waits forever.
      isBranchListLoadingInitial = false;
      isBranchListLoading = false;
      notifyListeners();
      return;
    }



    try {
      final response = await secureFetch(
        method: 'GET',
        endpoint: Env().branchListAPI,
        dbPtr: dbptr,
      );
      if (response.data['statusCode'] == 200) {
        var json = response.data;
        BookingFlowBranchesList branchList = BookingFlowBranchesList.fromJson(
          json,
        );

        bookingFlowBranches = (branchList.result ?? []).where((e) {
          final brOtherdet1 = e.otherdet1 ?? "";
          final otherDetMap = jsonDecode(brOtherdet1);
          final visibility = otherDetMap['web_visibility']?.toString();
          return visibility != "N";
        }).toList();

        if (!isInitial) {
          isBranchListLoadingSuccess = true;
        }

        String? newDbPtr = pref.getString(kSelectedBranchDbptr);

        if (newDbPtr == null || newDbPtr.isEmpty) {
          // No saved branch — pick the first one
          if (bookingFlowBranches.isNotEmpty) {
            await setSelectedBranch(0, shouldMigrate: false);
            // ADD THIS: Explicitly fetch packages for the first branch
            await getPackagesList();
          }
        } else {
          final currentBranch = pref.getString(kSelectedBranch);
          final index = bookingFlowBranches.indexWhere(
            (e) => e.desc == currentBranch,
          );

          if (index != -1) {
            await setSelectedBranch(index, shouldMigrate: false);
            // ALREADY THERE/ENSURE THIS:
            await getPackagesList();
          } else if (bookingFlowBranches.isNotEmpty) {
            await setSelectedBranch(0, shouldMigrate: false);
            // ADD THIS:
            await getPackagesList();
          }
        }

        // Notify UI about branch list update
        notifyListeners();
      }
    } catch (_) {
      // Nothing to recover here: this failure was only ever logged.
    } finally {
      if (isInitial) {
        isBranchListLoadingInitial = false;
      } else {
        isBranchListLoading = false;
      }
      notifyListeners();
    }
  }

  PackagesListModel? getPackageByCode(String? code) {
    if (code == null || code.isEmpty) return null;
    try {
      return packagesList.firstWhere((pkg) => pkg.itmCode == code);
    } catch (_) {
      return null;
    }
  }

  /// Method to update selected branch dbptr when tapped
  Future<void> setSelectedBranch(
    int index, {
    bool shouldMigrate = false,
  }) async {
    final pref = await SharedPreferencesService.prefs;
    final isLoggedIn = isAppLoggedIn;

    if (index < 0 || index >= bookingFlowBranches.length) return;

    final branch = bookingFlowBranches[index];
    final newDbPtr = jsonDecode(branch.otherdet1 ?? '{}')['db_ptr']?.toString();

    if (newDbPtr == null || newDbPtr.isEmpty) {
      return;
    }

    // If no migration needed or not logged in, just update the branch
    if (!shouldMigrate || !isLoggedIn) {
      return _updateBranch(pref, branch, newDbPtr, index);
    }

    // Call migration API

    try {
      final response = await secureFetch(
        method: 'POST',
        endpoint: Env().migrateAccountAPI,
        body: {"mode": "GSTDMIG", "destination_branch_ptr": newDbPtr},
      );

      final statusCode =
          response.data['status_code'] ?? response.data['statusCode'];

      if (statusCode != 200) {
        return;
      }

      await _updateBranch(pref, branch, newDbPtr, index);
    } catch (_) {
      // Nothing to recover here: this failure was only ever logged.
    }
  }

  Future<void> handleBranchSelection(
    BuildContext context,
    int index, {
    bool shouldNavigate = false,
    bool isFromBranchList = false,
  }) async {
    final pref = await SharedPreferencesService.prefs;
    final isLoggedIn = isAppLoggedIn;

    // Save selected branch index
    await pref.setInt('selected_branch_index', index);

    // Determine if migration is needed (only for logged-in users)
    bool needsMigration = false;
    if (isLoggedIn && index >= 0 && index < bookingFlowBranches.length) {
      final userProfileDbPtr = pref.getString('dbptr');
      final branch = bookingFlowBranches[index];
      final selectedBranchDbPtr = jsonDecode(
        branch.otherdet1 ?? '{}',
      )['db_ptr']?.toString();

      // Migration needed if user's profile branch differs from selected branch
      needsMigration = userProfileDbPtr != selectedBranchDbPtr;
    }

    // Set the branch (and migrate if needed)
    await setSelectedBranch(index, shouldMigrate: needsMigration);

    // Refresh packages for logged-in users
    await getPackagesList();

    // Pop if from branch list
    if (isFromBranchList && context.mounted) {
      Navigator.pop(context);
    }

    // Navigate if requested
    if (shouldNavigate && context.mounted) {
      // Host app's Navigator sits above the BookingFlowLauncher's MultiProvider,
      // so the pushed route loses the booking providers unless we forward the
      // existing instances.
      final guestProvider = context.read<GuestProvider>();
      final packagesProvider = context.read<PackagesProvider>();
      final loginProvider = context.read<LoginProvider>();
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MultiProvider(
            providers: [
              ChangeNotifierProvider<GuestProvider>.value(value: guestProvider),
              ChangeNotifierProvider<PackagesProvider>.value(
                value: packagesProvider,
              ),
              ChangeNotifierProvider<LoginProvider>.value(value: loginProvider),
            ],
            child: AddGuestsDetail(),
          ),
          settings: const RouteSettings(name: '/AddGuestsDetail'),
        ),
      );
    }
  }

  /// Helper method to update branch info and notify listeners
  Future<void> _updateBranch(
    SharedPreferences pref,
    BookingBranches branch,
    String newDbPtr,
    int index,
  ) async {
    selectedBranch = branch.desc;
    selectedBranchIndex = index;
    selectedBranchDbPtr = newDbPtr;

    await pref.setString(kSelectedBranch, branch.desc ?? "");
    await pref.setString(kSelectedBranchDbptr, newDbPtr);
    if (branch.code != null) {
      await pref.setString(branchptr, branch.code!);
    }
    if (branch.firmptr != null) {
      await pref.setString(firmptr, branch.firmptr!);
    }

    // CRITICAL: If your ApiService caches the dbptr or base url,
    // ensure it is refreshed here before getPackagesList() is called.
    notifyListeners();
    await getPackagesList();
  }

  /// Loads the packages list, selecting a branch first when none is stored.
  ///
  /// [getPackagesList] fetches against `kSelectedBranchDbptr`, and the only
  /// thing that ever writes that pref is [getBookingFlowBranches] — which runs
  /// from the Packages screen's [init] alone. Any screen reachable without
  /// passing through Packages (the booking list the host mounts on its home
  /// page, appointment history) would otherwise fetch with a null dbptr, get
  /// an empty list back, and render its cards without the package gradient.
  /// Fetching the branches first fills the pref and pulls the packages itself,
  /// so once a branch is stored this costs nothing extra.
  Future<void> ensurePackagesLoaded(BuildContext context) async {
    final pref = await SharedPreferencesService.prefs;
    final String? branchDbPtr = pref.getString(kSelectedBranchDbptr);

    if (branchDbPtr == null || branchDbPtr.isEmpty) {
      if (!context.mounted) return;
      await getBookingFlowBranches(context, isInitial: true);
      // Branch selection fetches the packages itself; only fall through when
      // it could not select one, so the call below stays a last resort.
      if (packagesList.isNotEmpty) return;
    }

    await getPackagesList();
  }

  /// Fetches the package list using the stored branch dbptr.
  Future<void> getPackagesList({String? gender}) async {
    final pref = await SharedPreferencesService.prefs;
    final String? branchDbPtr = pref.getString(kSelectedBranchDbptr);
    isPackagesListLoading = true;
    packagesList = [];
    notifyListeners();

    try {
      final response = await secureFetch(
        endpoint: Env().packagesListAPI,
        method: 'GET',
        requireAuth: false,
        dbPtr: branchDbPtr,
      );

      final rawData = response.data;
      // The packages API now returns a `{statusCode, message, success, result}`
      // envelope with the list under `result`. Older responses returned the
      // list directly (or nested one level). Handle all three shapes.
      List<dynamic> itemsToParse = [];
      if (rawData is Map && rawData['result'] is List) {
        itemsToParse = rawData['result'];
      } else if (rawData is List && rawData.isNotEmpty) {
        if (rawData.first is List) {
          itemsToParse = rawData.first;
        } else {
          itemsToParse = rawData;
        }
      }

      final List<PackagesListModel> tempList = [];

      for (var item in itemsToParse) {
        try {
          final String detailStr =
              (item["otherDetails3"] ?? item["itm_otherdet3"])?.toString() ??
                  "{}";
          final cleanedJson = detailStr
              .replaceAll('\n', '')
              .replaceAll('\r', '');
          Map<String, dynamic> extraDetails = {};

          try {
            extraDetails = jsonDecode(cleanedJson);
          } catch (_) {
            extraDetails = {};
          }

          final visibility =
              extraDetails["web_visibility"]?.toString().toUpperCase() ?? "Y";
          if (visibility == "N") continue;

          tempList.add(PackagesListModel.fromJson(item));
        } catch (itemError) {
          continue;
        }
      }

      packagesList = tempList;
    } catch (_) {
      // Nothing to recover here: this failure was only ever logged.
    } finally {
      isPackagesListLoading = false;
      notifyListeners();
    }
  }
}
