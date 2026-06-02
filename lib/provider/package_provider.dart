import 'dart:convert';
import 'dart:developer';

import 'package:booking/core/constants.dart';
import 'package:booking/main.dart';
import 'package:booking/model/booking_flow_branches_list.dart';
import 'package:booking/model/branches_model.dart';
import 'package:booking/model/packages_list_model.dart';
import 'package:booking/provider/guests_provider.dart';
import 'package:booking/provider/login_provider.dart';
import 'package:booking/services/api_services.dart';
import 'package:booking/services/remote_config_services.dart';
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

    /// Initialze a empty countries variable
    List<String> countries = [];

    /// Get Countries json from remote config.
    /// In standalone mode RemoteConfigService is not registered, so fall back
    /// to whatever country was already seeded in SharedPreferences.
    try {
      if (!context.mounted) return;
      dynamic json = await context.read<RemoteConfigService>().countries;
      for (var element in json) {
        countries.add(element['country']);
      }
    } catch (e) {
      log('RemoteConfigService unavailable; using prefs-only country: $e');
    }

    /// Get Selected Country from local storage
    final currentCountry = prefs.getString(kSelectedCountry);

    if (countries.isNotEmpty) {
      final index = countries.indexOf(currentCountry ?? '');
      if (index != -1) {
        selectedCountryIndex = index;
        selectedCountry = countries[index];
      }
    } else if (currentCountry != null && currentCountry.isNotEmpty) {
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

    await ApiService.apiMethodSetup(
      method: ApiMethod.get,
      url: Env().branchListAPI,
      dbPtr: country == 'Mongolia' ? 'nuramho' : null,
    ).then((response) {
      var json = response?.data;
      log(json.toString());
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
    RegExp rgbRegex =
        RegExp(r'rgb(a)?\((\d+),\s*(\d+),\s*(\d+)(,\s*([\d.]+))?\)');
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
      return;
    }

    try {
      final response = await ApiService.apiMethodSetup(
        method: ApiMethod.get,
        url: Env().bookingFlowBranchersAPI,
        dbPtr: dbptr,
      );

      if (response?.data['statusCode'] == 200) {
        var json = response?.data;
        BookingFlowBranchesList branchList =
            BookingFlowBranchesList.fromJson(json);

        bookingFlowBranches = (branchList.result ?? []).where((e) {
          final brOtherdet1 = e.brOtherdet1 ?? "";
          final otherDetMap = jsonDecode(brOtherdet1);
          final visibility = otherDetMap['web_visibility']?.toString();
          return visibility != "N";
        }).toList();

        if (!isInitial) {
          isBranchListLoadingSuccess = true;
        }

        final String? newDbPtr = pref.getString(kSelectedBranchDbptr);

        if (newDbPtr == null || newDbPtr.isEmpty) {
          if (bookingFlowBranches.isNotEmpty) {
            await setSelectedBranch(0, shouldMigrate: false);
            await getPackagesList();
          }
        } else {
          final currentBranch = pref.getString(kSelectedBranch);
          final index = bookingFlowBranches.indexWhere(
            (e) => e.brDesc == currentBranch,
          );

          if (index != -1) {
            await setSelectedBranch(index, shouldMigrate: false);
            await getPackagesList();
          } else if (bookingFlowBranches.isNotEmpty) {
            await setSelectedBranch(0, shouldMigrate: false);
            await getPackagesList();
          }
        }

        notifyListeners();
      }
    } catch (e) {
      log('Error fetching branches: $e');
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
  Future<void> setSelectedBranch(int index,
      {bool shouldMigrate = false,}) async {
    final pref = await SharedPreferencesService.prefs;
    final isLoggedIn = isAppLoggedIn;

    if (index < 0 || index >= bookingFlowBranches.length) return;

    final branch = bookingFlowBranches[index];
    final newDbPtr =
        jsonDecode(branch.brOtherdet1 ?? '{}')['db_ptr']?.toString();

    if (newDbPtr == null || newDbPtr.isEmpty) {
      log('No db_ptr found for branch: ${branch.brDesc}');
      return;
    }

    // If no migration needed or not logged in, just update the branch
    if (!shouldMigrate || !isLoggedIn) {
      return _updateBranch(pref, branch, newDbPtr, index);
    }

    // Call migration API
    log('Migrating account to ${branch.brDesc} (db_ptr: $newDbPtr)');

    try {
      final response = await ApiService.apiMethodSetup(
        method: ApiMethod.post,
        url: Env().migrateAccountAPI,
        data: {"mode": "GSTDMIG", "destination_branch_ptr": newDbPtr},
      );

      final statusCode =
          response?.data['status_code'] ?? response?.data['statusCode'];

      if (statusCode != 200) {
        log('Migration failed: ${response?.data['message']}');
        return;
      }

      log('Migration successful: ${response?.data['message']}');
      await _updateBranch(pref, branch, newDbPtr, index);
    } catch (e) {
      log('Migration error: $e');
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
      final selectedBranchDbPtr =
          jsonDecode(branch.brOtherdet1 ?? '{}')['db_ptr']?.toString();

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
    selectedBranch = branch.brDesc;
    selectedBranchIndex = index;
    selectedBranchDbPtr = newDbPtr;

    await pref.setString(kSelectedBranch, branch.brDesc ?? "");
    await pref.setString(kSelectedBranchDbptr, newDbPtr);
    if (branch.brCode != null) {
      await pref.setString(branchptr, branch.brCode!);
    }
    if (branch.brFirmptr != null) {
      await pref.setString(firmptr, branch.brFirmptr!);
    }

    notifyListeners();
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
      final response = await ApiService.apiMethodSetup(
        method: ApiMethod.get,
        url: Env().packagesListAPI,
        dbPtr: branchDbPtr,
      );

      final rawData = response?.data;

      List<dynamic> itemsToParse = [];
      if (rawData is List && rawData.isNotEmpty) {
        if (rawData.first is List) {
          itemsToParse = rawData.first;
        } else {
          itemsToParse = rawData;
        }
      }

      final List<PackagesListModel> tempList = [];

      for (var item in itemsToParse) {
        try {
          final String detailStr = item["itm_otherdet3"]?.toString() ?? "{}";
          final cleanedJson =
              detailStr.replaceAll('\n', '').replaceAll('\r', '');
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
          log("Error parsing specific package: $itemError");
          continue;
        }
      }

      packagesList = tempList;
    } catch (globalError) {
      log("Global API Error: $globalError");
    } finally {
      isPackagesListLoading = false;
      notifyListeners();
    }
  }
}
