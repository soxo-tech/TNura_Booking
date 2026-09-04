import 'dart:async';
import 'package:booking/core/constants.dart';
import 'package:booking/core/env.dart';
import 'package:booking/model/booking_history_model.dart';
import 'package:booking/model/profile_model.dart';
import 'package:booking/services/api_services.dart';
import 'package:booking/services/security_service/secure_fetch.dart';
import 'package:booking/services/shared_preferences.dart';
import 'package:flutter/material.dart';

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
    isBookingLoading = true;
    isBookingFailed = false;
    notifyListeners();

    try {
      final pref = await SharedPreferencesService.prefs;
      final deviceId = pref.getString(kDeviceId) ?? "";

      final response = await secureFetch(
        endpoint: Env().bookingList,
        method: 'GET',
        headers: {"device_id": deviceId},
      );


      if (response.data['statusCode'] == 200) {
        /// Remove extra nested list from result
        if (response.data['result'] != null &&
            response.data['result'] is List &&
            response.data['result'].isNotEmpty &&
            response.data['result'][0] is List) {
          response.data['result'] = response.data['result'][0];
        }

        bookinghistoryModel = BookinghistoryModel.fromJson(response.data);
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
       final response = await secureFetch(
        endpoint: Env().profileAPI,
        method: 'GET',
      );
      if (response.data['statusCode'] == 200) {
        var json = response.data;
        profileModel = ProfileModel.fromJson(json);
      } else {
        ApiService.tokenRemover();
        isLogout = true;
      }
    } catch (e) {
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
