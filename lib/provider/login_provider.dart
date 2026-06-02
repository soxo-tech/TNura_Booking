import 'dart:async';
import 'dart:developer';
import 'package:booking/core/constants.dart';
import 'package:booking/core/env.dart';
import 'package:booking/model/booking_history_model.dart';
import 'package:booking/model/profile_model.dart';
import 'package:booking/services/api_services.dart';
import 'package:booking/services/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// A provider for managing the login state, including user credentials, authentication methods, and profile data.

class LoginProvider extends ChangeNotifier {
  // Controllers for managing input fields in the login form.
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  TextEditingController otpfieldController = TextEditingController();

  // Flags for different login methods and states.
  bool isEmailLogin = false;
  bool isMobileLogin = false;
  bool isUsernameLogin = false;
  bool isUsernameError = false;
  bool isPasswordError = false;
  bool isLoading = false;
  bool isBookingLoading = false;
  bool isBookingFailed = false;
  bool _isGuestLoading = false;
  bool get isGuestLoading => _isGuestLoading;

  set isGuestLoading(bool value) {
    _isGuestLoading = value;
    notifyListeners();
  }

  void setIsGuestLoading(bool value) {
    _isGuestLoading = value;
    notifyListeners();
  }

  // Model for user profile.
  ProfileModel profileModel = ProfileModel();

 

  //Flags for profile data loading and logout status
  bool isProfileLoading = false;
  bool isLogout = false;

  BookinghistoryModel? bookinghistoryModel;

  Future<BookinghistoryModel?> getBookingList() async {
    // Use the SAME device_id the booking was created against. The booking is
    // stored against the host-seeded kDeviceId (falling back to the live FCM
    // token only when none was seeded) in initiatePaymentV2(); querying with a
    // different value (e.g. the live FCM token) returns an empty list.
    final pref = await SharedPreferencesService.prefs;
    final deviceId = pref.getString(kDeviceId) ??
        (await FirebaseMessaging.instance.getToken() ?? "");
    isBookingLoading = true;
    isBookingFailed = false;
    notifyListeners();

    try {
      final response = await ApiService.apiMethodSetup(
        method: ApiMethod.get,
        url: Env().bookingList,
        options: Options(headers: {"device_id": deviceId}),
      );

      if (response != null && response.data['statusCode'] == 200) {
        bookinghistoryModel = BookinghistoryModel.fromJson(response.data);
        log('Booking List Response: ${response.data}');
      } else {
        isBookingFailed = true;
        bookinghistoryModel = null;
      }
    } catch (e) {
      isBookingFailed = true;
      bookinghistoryModel = null;
    }

    isBookingLoading = false;
    notifyListeners();
    return bookinghistoryModel;
  }

  String formatHistoryDate(DateTime date) {
    final today = DateTime.now();

    // Check if it's today
    bool isToday = date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;

    if (isToday) {
      return "Today";
    }

    // Example output: "7 January 2025"
    return "${date.day} ${_historyMonthName(date.month)} ${date.year}";
  }

  String formatTime(DateTime date, context) {
    // Example output: "10:00 AM"
    return TimeOfDay.fromDateTime(date).format(context);
  }

  String _historyMonthName(int month) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  return months[month - 1];
}


  /// Fetches user profile data from the API.
  Future<ProfileModel?> getProfileData({String from = 'Other'}) async {
    isProfileLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.apiMethodSetup(
        method: ApiMethod.get,
        url: Env().profileAPI,
      );
      log('Profile API response: ${response?.statusCode} - ${response?.data}');
      if (response != null && response.data['statusCode'] == 200) {
        var json = response.data;
        profileModel = ProfileModel.fromJson(json);

        // Crashlytics setup
        FirebaseCrashlytics.instance.setUserIdentifier(profileModel.id ?? "");
        FirebaseCrashlytics.instance
            .setCustomKey("email", profileModel.email ?? "");
        FirebaseCrashlytics.instance
            .setCustomKey("userId", profileModel.id ?? "");
        FirebaseCrashlytics.instance.setCustomKey(
          "name",
          "${profileModel.name ?? ""} ${profileModel.lname ?? ""}",
        );
      } else {
        log('Profile API error or invalid status code');
        ApiService.tokenRemover();
        isLogout = true;
      }
    } catch (e) {
      log('Exception in getProfileData: $e');
      ApiService.tokenRemover();
      isLogout = true;
    } finally {
      // This block ALWAYS runs after try or catch, ensuring the loader stops correctly
      isProfileLoading = false;
      notifyListeners();
    }

    return profileModel;
  }

 

  int getMaxPhoneLength(String countryCode) {
    switch (countryCode.trim()) {
      case '+91':
      case '91':
        return 10;
      case '+84':
      case '84':
        return 9;
      case '976':
      case '+976':
        return 8;
      default:
        return 10;
    }
  }
}
