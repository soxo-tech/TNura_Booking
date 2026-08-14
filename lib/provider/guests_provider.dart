// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:booking/core/colors.dart';
import 'package:booking/core/constants.dart';
import 'package:booking/core/database/database.dart';
import 'package:booking/core/env.dart';
import 'package:booking/main.dart';
import 'package:booking/model/add_on_test_model.dart';
import 'package:booking/model/available_slots_model.dart';
import 'package:booking/model/packages_list_model.dart';
import 'package:booking/model/profile_model.dart';
import 'package:booking/provider/login_provider.dart';
import 'package:booking/provider/package_provider.dart';
import 'package:booking/services/api_services.dart';
import 'package:booking/services/navigation_services.dart';
import 'package:booking/services/security_service/secure_fetch.dart';
import 'package:booking/services/shared_preferences.dart';
import 'package:booking/view/booking/payment_failure.dart' show PaymentFailure;
import 'package:booking/view/booking/payment_succesfull.dart';
import 'package:booking/widgets/refracted_text.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

enum GuestStep { appointmentScheduling, addGuest, confirmation }

class Guest {
  // Controllers
  TextEditingController firstNameController = TextEditingController();
  TextEditingController secondNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController dateOfBirthController = TextEditingController();
  TextEditingController otpController = TextEditingController();

  // State flags
  bool isExpanded = false;
  bool showOtp = false;
  bool canResendOtp = false;
  bool isGuestLoading = false;
  bool isAppointmentSelected = false;
  bool otpVerified = false;
  bool showError = false;
  bool isOtpError = false;
  bool firstNameError = false;
  bool lastNameError = false;
  bool isSelected = false;
  bool ageError = false;
  bool phoneError = false;
  String verifiedPhoneNumber = '';
  String pendingOtpPhone = '';
  bool emailError = false;
  bool cameFromBillingUser = false;

  bool get hasAnyError =>
      firstNameError || lastNameError || ageError || phoneError || emailError;

  // Data
  String isAgeEligible = '';
  String countryCode = '+91';
  String otpID = '';
  String? selectedSlot;
  String tokenNo = '';
  int? selectedDoctorId;
  String packageTypeValue = '';
  DateTime selectedDate = DateTime.now();
  int? selectedPackageIndex;
  List<String> morningSlots = [];
  List<String> afternoonSlots = [];
  String? appointmentId;
  String? daId;
  // Package selection
  List<PackagesListModel> packageList = [];
  String selectedPackage = '';
  String selectedPackageRate = '';

  // Gender
  String? selectedGender = 'Male';

  // Step tracking
  GuestStep step = GuestStep.appointmentScheduling;

  // OTP Timer
  int otpTimer = 60;
  Timer? _timer;

  // Constructor
  Guest();

  // Named constructor from ProfileModel
  Guest.fromProfile(ProfileModel profile) {
    firstNameController.text = profile.name ?? '';
    secondNameController.text = profile.lname ?? '';
    emailController.text = profile.email ?? '';
    phoneController.text = profile.phone ?? '';
    ageController.text = profile.ageDay?.toString() ?? '';
    countryCode = profile.countryCodeMob1 ?? '+91';
    selectedGender = profile.gender ?? 'Male';
  }

  /// Calculate total package price for this guest
  int packageRate = 0;

  int get totalPrice {
    return packageRate;
  }

  /// Start the OTP timer and update UI
  void startOtpTimer(VoidCallback updateUI) {
    otpTimer = 60;
    canResendOtp = false;

    _timer?.cancel(); // Cancel any existing timer

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (otpTimer > 0) {
        otpTimer--;
        updateUI();
      } else {
        timer.cancel();
        canResendOtp = true;
        updateUI();
      }
    });
  }

  /// Dispose controllers and timer when needed
  void dispose() {
    firstNameController.dispose();
    secondNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    ageController.dispose();
    otpController.dispose();
    _timer?.cancel();
  }
}

class GuestProvider extends ChangeNotifier {
  final TextEditingController billingUserNameController =
      TextEditingController();
  final TextEditingController billingUserPhoneController =
      TextEditingController();

  final TextEditingController billingUserEmailController =
      TextEditingController();
  String billingUsercountryCodeController = '+91';
  final TextEditingController billingUserOtpController =
      TextEditingController();
  final TextEditingController offersAndCouponController =
      TextEditingController();
  final TextEditingController referalCodeController = TextEditingController();

  int? offersSelectedIndex;
  List<bool> isReferralApplied = List.generate(4, (index) => false);

  bool isListExpanded = false;
  Map<String, String> slotToTokenMap = {};
  bool isBillingUserError = false;
  bool isBillingPhoneNumberError = false;
  bool isBillingEmailError = false;
  bool isBillingUserOtpError = false;
  bool isBillingUserOtpSent = false;
  bool isReturningFromBillingUser = false;
  bool showConfirmAppointmentDetails = false;
  bool continueAsGuest = false;
  bool isPaymentConfirmed = false;
  bool isCouponApplied = false;
  String couponError = '';
  bool isAddonExpanded = false;

  List<AddOns> selectedAddons = [];

  bool isCouponExpanded = false;
  bool isCouponValidating = false;
  bool isCouponInvalid = false;
  int couponValue = 0;
  String couponType = "A";

  int discountedAmount = 0;

  // ignore: unused_field
  int _currentGuestIndex = 0;
  String? transactionId;
  Razorpay? _razorpay;
  String? billingUserVerifiedPhone;

  // Captured at payment initiation so the Razorpay success callback can
  // navigate using the host app's navigator when this module runs embedded
  // (the standalone [navigatorKey] is only attached in [main.dart]).
  NavigatorState? _paymentNavigator;

  // Companion providers captured from the BookingFlowLauncher scope so we can
  // re-expose them on routes pushed via the root navigatorKey (which sits
  // above the MultiProvider).
  PackagesProvider? _packagesProvider;
  LoginProvider? _loginProvider;

  // Host-supplied hook fired when a slot is blocked while the user is not
  // authenticated. Lets the host redirect out of the booking flow.
  VoidCallback? onUnauthorizedSlotBlocked;

  void bindCompanionProviders(
    PackagesProvider packages,
    LoginProvider login,
  ) {
    _packagesProvider = packages;
    _loginProvider = login;
  }

  Widget _wrapWithProviders(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GuestProvider>.value(value: this),
        if (_packagesProvider != null)
          ChangeNotifierProvider<PackagesProvider>.value(value: _packagesProvider!),
        if (_loginProvider != null)
          ChangeNotifierProvider<LoginProvider>.value(value: _loginProvider!),
      ],
      child: child,
    );
  }

  void initRazorpayIfNeeded() {
    if (_razorpay != null) return;
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void disposeRazorpay() {
    _razorpay?.clear();
  }

  Future<void> openCheckout({
    required String name,
    required int amount,
    required String orderId,
  }) async {
    final pref = await SharedPreferencesService.prefs;
    final razorpayKey = pref.getString(kRazorpayKey);
    if (razorpayKey == null || razorpayKey.isEmpty) {
      debugPrint(" Razorpay key not found in SharedPreferences!");
      return;
    }
    var options = {
      'key': razorpayKey,
      'amount': amount * 100,
      'name': name,
      'description': 'Payment for your order',
      'order_id': orderId,
      'prefill': {
        'contact': billingUserPhoneController.text,
        'email': billingUserEmailController.text,
      },
    };
    try {
      _razorpay?.open(options);
    } catch (e) {
      debugPrint('Razorpay Error: $e');
    }
  }

  void handleBackNavigation(
    BuildContext context, {
    bool isAppLoggedIn = false,
  }) async {
    if (guests.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final guest = guests[0];

    // 1. Back from Confirmation -> Go back to Appointment Scheduling
    if (guest.step == GuestStep.confirmation) {
      isAvailableSlotsLoading = true;
      guest.otpVerified = true;
      couponValue = 0;
      isCouponExpanded = false;
      isCouponApplied = false;
      isCouponInvalid = false;
      clearAddons();
      offersAndCouponController.clear();
      notifyListeners();
      guest.step = GuestStep.appointmentScheduling;
      await getAvailableSlots(0, context);
      isAvailableSlotsLoading = false;
      notifyListeners();
      return;
    }

    // 2. Back from Appointment Scheduling
    if (guest.step == GuestStep.appointmentScheduling) {
      if (guest.showOtp) {
        guest.showOtp = false;
        notifyListeners();
        return;
      }

      // Clear coupon and state
      couponValue = 0;
      offersAndCouponController.clear();
      isCouponApplied = false;

      if (!continueAsGuest) {
        // Common Cleanup
        stopAppointmentTimer();
        guest.selectedSlot = null;
        guests.clear();
        continueAsGuest = false;
        notifyListeners();

        // THE CORE LOGIC:
        if (isFromReschedule) {
          stopAppointmentTimer();
          guests.clear();
          continueAsGuest = false;

          notifyListeners();

          Navigator.pop(context);
          isFromReschedule = false;
          return;
        }

        if (isAppLoggedIn) {
          // Logged-in: just pop back to Packages.
          stopAppointmentTimer();
          guests.clear();
          continueAsGuest = false;
          notifyListeners();
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else {
          // Guest/Not Logged-in: Clear the "white page" and go to the start
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        // Guest is still in the form flow, just go back to the previous step
        guest.step = GuestStep.addGuest;
        notifyListeners();
      }
      return;
    }

    // 3. Back from Add Guest Form
    if (guest.step == GuestStep.addGuest) {
      Navigator.pop(context);
      return;
    }

    Navigator.pop(context);
  }

  bool isFromReschedule = false;

  @override
  void dispose() {
    appointmentTimer?.cancel();
    super.dispose();
  }

  Map<String, dynamic>? _appointmentDetails;
  Map<String, dynamic>? get appointmentDetails => _appointmentDetails;
// Model for user payment status.
  ProfileModel profileModel = ProfileModel();
  Future<Map<String, dynamic>?> getPaymentStatus(
    String paymentId,
    BuildContext context,
    int index,
  ) async {
    log('paymentid: $paymentId');
    try {
      final res = await secureFetch(
        method: 'GET',
        endpoint: Env().getPaymentStatus(paymentId: paymentId),
        dbPtr: (await SharedPreferencesService.prefs)
            .getString(kSelectedBranchDbptr),
      );
      

      final data = res.data;
      log('Payment status response: $data');
      if (data == null || data['status'] != 200 || data['success'] != true) {
        _setPaymentProcessing(false);
        _toast(context, data?['message'] ?? 'Failed to fetch payment status');
        return null;
      }

      // Store the complete appointment data with da_id
      final appointmentData = (data['data'] as List<dynamic>? ?? []);

      if (appointmentData.isEmpty) {
        _setPaymentProcessing(false);
        _toast(context, 'No appointment data returned');
        return null;
      }

      // Extract appointment IDs for fetchAppointmentDetails
      final ids = appointmentData
          .map((e) => e['appointment_id'] as String?)
          .whereType<String>()
          .toList();

      // Fetch appointment details
      final appointmentDetails = await fetchAppointmentDetails(
        appointmentIds: ids,
        context: context,
      );

      if (appointmentDetails == null) return null;

      // Merge da_id into appointment details
      final appointments =
          (appointmentDetails['appointments'] as List<dynamic>?) ?? [];

      for (int i = 0;
          i < appointments.length && i < appointmentData.length;
          i++) {
        appointments[i]['da_id'] = appointmentData[i]['da_id'];
        appointments[i]['appointment_id'] =
            appointmentData[i]['appointment_id'];
      }

      return {
        ...appointmentDetails,
        "appointments": appointments,
      };
    } catch (e, st) {
      debugPrint('getPaymentStatus → $e\n$st');
      _toast(context, 'Network error — please try again.');
      return null;
    }
  }

  int get payableAmount {
    return (packageTotal - discountAmount + addonTotal).clamp(0, 9999999);
  }

  AddOnItemModel addOnTestModel = AddOnItemModel(data: []);

  Future<void> getAvailableAddOnTest(
      String packageTypeValue, BuildContext context) async {
    try {
      final res = await secureFetch(
        method: 'GET',
        endpoint: Env().getAddOnTests(packageTypeValue: packageTypeValue),
        dbPtr: (await SharedPreferencesService.prefs)
            .getString(kSelectedBranchDbptr),
      );
     

      final data = res.data;
      log('Add-on tests response: $data');
      if (data == null ||
          data['statusCode'] != 200 ||
          data['success'] != true) {
        _toast(context, data?['message'] ?? 'Failed');
        return;
      }

      addOnTestModel = AddOnItemModel.fromJson(data);

      notifyListeners();
    } catch (e) {
      _toast(context, 'Error');
    }
  }

  void _toast(BuildContext c, String m) => showSnackBar(c, m);
  int get discountAmount {
    if (couponValue == 0) return 0;

    if (couponType == "P") {
      double discount = (packageTotal * couponValue) / 100;
      return discount.toInt().clamp(0, packageTotal);
    } else {
      return couponValue.clamp(0, packageTotal);
    }
  }

 Future<bool> validateCoupon(BuildContext context) async {
    final guestList = guests;
    final prefs = await SharedPreferencesService.prefs;
    String? branchDbptr = prefs.getString(kSelectedBranchDbptr);

    var data = {
      "coupon_no": offersAndCouponController.text.trim(),
      "item": guestList[0].packageTypeValue,
      "booking_date":
          DateFormat('yyyy-MM-dd').format(guestList[0].selectedDate),
      "applicable_on": "APP",
    };

    log('Coupon Payload: ${jsonEncode(data)}');

    try {
      var response = await secureFetch(
        method: 'POST',
        endpoint: Env().validateCoupon,
        body: data,
        dbPtr: branchDbptr,
      );

      log('Coupon Response: ${jsonEncode(response.data)}');

      if ((response.data['status_code'] == 200 ||
              response.data['status_code'] == 201) &&
          response.data['success'] == true) {
        return true;
      } else {
        showSnackBar(context, "Invalid coupon. Try again.");
        return false;
      }
    } catch (e) {
      showSnackBar(context, "Something went wrong. Try again.");
      return false;
    }
  }


  Future<bool> getCoupon(BuildContext context) async {
    final guestList = guests;
    final prefs = await SharedPreferencesService.prefs;
    String? branchDbptr = prefs.getString(kSelectedBranchDbptr);

    var data = {
      "coupon_no": offersAndCouponController.text.trim(),
      "item": guestList[0].packageTypeValue,
      "booking_date":
          DateFormat('yyyy-MM-dd').format(guestList[0].selectedDate),
      "applicable_on": "APP",
    };

    log('Coupon Payload: ${jsonEncode(data)}');

    try {
      var response = await secureFetch(
        method: 'POST',
        endpoint: Env().applyCoupon,
        body: jsonEncode(data),
        dbPtr: branchDbptr,
      );

      log('Coupon Response: ${jsonEncode(response.data)}');

      if ((response.status == 200 || response.status == 201) &&
          response.data['success'] == true) {
        final data = response.data['data'];

        couponValue = data['coupon_value'] ?? 0;
        couponType = data['value_type'] ?? "A";

        log('Coupon Value: $couponValue');
        log('Coupon Type: $couponType');

        notifyListeners();
        return true;
      } else {
        showSnackBar(context, "Invalid coupon. Try again.");
        return false;
      }
    } catch (e) {
      log("Coupon Error: $e");
      showSnackBar(context, "Something went wrong. Try again.");
      return false;
    }
  }

  String? rescheduleAppointmentId;
  Future<void> applyCoupon(BuildContext context) async {
    if (offersAndCouponController.text.isEmpty) return;

    isCouponValidating = true;
    isCouponInvalid = false;
    notifyListeners();

    // Step 1: Validate
    bool isValid = await validateCoupon(context);

    if (!isValid) {
      isCouponValidating = false;
      isCouponInvalid = true;
      notifyListeners();
      return;
    }

    // Step 2: Apply (get coupon values)
    bool applied = await getCoupon(context);

    isCouponValidating = false;

    if (applied) {
      isCouponApplied = true;
      isCouponExpanded = false;
      isCouponInvalid = false;
    } else {
      isCouponInvalid = true;
    }

    notifyListeners();
  }

  void toggleCouponExpand() {
    isCouponExpanded = !isCouponExpanded;
    notifyListeners();
  }

  void removeCoupon() {
    isCouponApplied = false;
    isCouponExpanded = true;
    couponValue = 0;
    discountedAmount = totalAmount;
    offersAndCouponController.clear();
    notifyListeners();
  }

  void clearCoupon() {
    isCouponApplied = false;
    isCouponExpanded = false;
    couponValue = 0;
    discountedAmount = totalAmount;
    offersAndCouponController.clear();
    notifyListeners();
  }

  void _onPaymentSuccess(PaymentSuccessResponse rsp) async {
    log("####### CALLBACK RECEIVED FROM RAZORPAY #######");
    log('########### Payment ID: ${rsp.paymentId}');

    _setPaymentProcessing(false);
    _setFetchingPaymentDetails(true);

    final nav = _paymentNavigator ?? navigatorKey.currentState;
    if (nav == null) {
      log("❌ No navigator available to handle payment success");
      _setFetchingPaymentDetails(false);
      return;
    }

    /// STEP 1: Wait for appointment_id
    final appointmentIds = await _waitForAppointmentIds(
      rsp.paymentId!,
      nav.context,
    );

    if (appointmentIds == null || appointmentIds.isEmpty) {
      _setFetchingPaymentDetails(false);

      showSnackBar(
        nav.context,
        "Payment successful. Appointment will be available shortly.",
      );

      // Payment already succeeded server-side even though the appointment
      // hasn't shown up in our polling window yet — signal a refetch so the
      // booking-list view can pick it up once the backend catches up, rather
      // than requiring an app restart.
      bookingListRefreshTick.value++;

      nav.pop(); // or navigate to home
      return;
    }

    /// STEP 2: Fetch full appointment details
    final details = await fetchAppointmentDetails(
      appointmentIds: appointmentIds,
      context: nav.context,
    );

    // A new appointment now exists — signal any mounted booking-list view
    // (e.g. the embedded list on the host's home page) to refetch so it shows
    // up without waiting for an app restart. Bump this regardless of whether
    // the detail-enrichment call below succeeds: the source of truth is the
    // server's booking-list endpoint, not this client-side detail fetch.
    bookingListRefreshTick.value++;

    if (details == null) {
      _setFetchingPaymentDetails(false);
      return;
    }

    _setFetchingPaymentDetails(false);

    /// STEP 3: Navigate to success screen
    nav.pushReplacement(
      MaterialPageRoute(
        builder: (_) => _wrapWithProviders(
          PaymentSuccessful(
            totalAmount: couponValue == 0 ? '$totalAmount' : '$payableAmount',
            transactionId: rsp.paymentId,
            appointmentJson: details,
          ),
        ),
      ),
    ).then((_) {
      clearAddons();
      clearGuestData();
    });
  }

  Future<List<String>?> _waitForAppointmentIds(
    String paymentId,
    BuildContext context,
  ) async {
    const maxRetries = 15;
    const delaySeconds = 2;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      log("🔁 Checking appointment_id (Attempt $attempt)");

      try {
        final res = await secureFetch(
          method: 'GET',
          endpoint: Env().getPaymentStatus(paymentId: paymentId),
          dbPtr: (await SharedPreferencesService.prefs)
              .getString(kSelectedBranchDbptr),
        );

        final responseData =
            res.data is String ? jsonDecode(res.data) : res.data;

        if (responseData is Map &&
            responseData['status'] == 200 &&
            responseData['success'] == true) {
          final list = responseData['data'] as List? ?? [];

          if (list.isNotEmpty) {
            final ids = list
                .map((e) => e['appointment_id']?.toString())
                .whereType<String>()
                .toList();

            if (ids.isNotEmpty) {
              log("✅ appointment_id received: $ids");
              return ids;
            }
          }
        }

        log("⏳ appointment_id not ready yet...");
      } catch (e) {
        log("❌ Polling error: $e");
      }

      await Future.delayed(const Duration(seconds: delaySeconds));
    }

    log("❌ appointment_id not received after retries");
    return null;
  }
  void _handlePaymentError(
    BuildContext context,
    PaymentFailureResponse response,
  ) {
    _setPaymentProcessing(false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => _wrapWithProviders(
          PaymentFailure(
            name: billingUserNameController.text,
            amount: totalAmount,
            orderId: paymentId,
          ),
        ),
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    _setPaymentProcessing(false);
  }

  // Track if billing user is verified
  bool isBillingVerified = false;
  int billingOtpTimer = 60;
  Timer? _timer;
  Timer? appointmentTimer;
  bool canBillingUserResendOtp = false;
  Duration remainingTime = Duration(minutes: 10);

  void startAppointmentTimer() {
    appointmentTimer?.cancel();
    remainingTime = Duration(minutes: 10);
    appointmentTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingTime.inSeconds > 0) {
        remainingTime -= Duration(seconds: 1);
      } else {
        timer.cancel();
      }
      notifyListeners();
    });
  }

  void stopAppointmentTimer() {
    appointmentTimer?.cancel();
    appointmentTimer = null;
    remainingTime = Duration(minutes: 0);
    notifyListeners();
  }

  // Track if UI should move to appointment scheduling
  bool moveToScheduleAppointment = false;
  List<String> get nameOptions => guests
      .map(
        (guest) =>
            '${guest.firstNameController.text} ${guest.secondNameController.text}',
      )
      .toList();

  List<String> get phoneOptions {
    final seen = <String>{};
    final result = <String>[];

    for (var guest in guests) {
      final phone = guest.phoneController.text.trim();

      if (phone.isEmpty) continue;

      if (seen.add(phone)) {
        result.add(phone);
      }
    }

    return result;
  }

  // Call this method whenever guest details change
  void updateGuestLists() {
    notifyListeners();
  }

  List<String> _filteredOptions = [];
  bool _isDropdownOpen = false;
  String _currentField = '';

  List<String> get filteredOptions => _filteredOptions;
  List<Guest> filteredNumbers = [];

  bool get isDropdownOpen => _isDropdownOpen;
  String get currentField => _currentField;
  bool isAvailableSlotsLoading = false;
  List<AvailableSlot> availableSlots = [];
  AvailableSlotsModel availableSlotsModel = AvailableSlotsModel();
  List<Guest> guests = [];
  bool isMembersLoading = true;

  void setInitialLoading(bool value) {
    isMembersLoading = value;
    notifyListeners();
  }

  void toggleAddonExpand() {
    isAddonExpanded = !isAddonExpanded;
    notifyListeners();
  }

  void toggleAddonSelection(AddOns addon) {
    final index = selectedAddons.indexWhere((e) => e.itmCode == addon.itmCode);

    if (index != -1) {
      selectedAddons.removeAt(index);
    } else {
      selectedAddons.add(addon);
    }

    notifyListeners();
  }

  void removeAddon(AddOns addon) {
    selectedAddons.remove(addon);
    notifyListeners();
  }

  bool isAddonSelected(AddOns addon) {
    return selectedAddons.any((e) => e.itmCode == addon.itmCode);
  }

  void clearAddons() {
    selectedAddons.clear();
    isAddonExpanded = false;
    notifyListeners();
  }

  List<String> get selectedAddonCodes {
    return selectedAddons
        .map((addon) => addon.itmCode)
        .where((code) => code != null && code.isNotEmpty)
        .cast<String>()
        .toList();
  }

  int get addonTotal {
    return selectedAddons.fold<int>(0, (sum, addon) {
      final price = addon.irRate ?? addon.itmCost ?? 0;
      return sum + price;
    });
  }

  // Initial form
  List<RelatedUser> relatedUsers = [];

  // 1. Add forceRefresh as a parameter with a default value of false
  Future<void> initializeGuest(
    BuildContext context,
    bool isAppLoggedIn, {
    bool forceRefresh = false,
  }) async {
    if (!isAppLoggedIn) return;

    // 2. Now 'forceRefresh' is defined.
    // If we aren't forcing a refresh and we already have data, just stop here.
    if (!forceRefresh &&
        guests.isNotEmpty &&
        guests[0].firstNameController.text.isNotEmpty) {
      isMembersLoading = false;
      notifyListeners();
      return;
    }

    isMembersLoading = true;
    notifyListeners();

    try {
      if (guests.isEmpty) {
        guests.add(Guest());
        guests[0].selectedDate = DateTime.now();
      }

      final loginProvider = Provider.of<LoginProvider>(context, listen: false);

      // We fetch the profile data
      final profile = await loginProvider.getProfileData(from: 'AddGuests');

      if (profile != null) {
        final guest = guests[0];
        guest.firstNameController.text = profile.name ?? '';
        guest.secondNameController.text = profile.lname ?? '';
        guest.emailController.text = profile.email ?? '';
        guest.phoneController.text = profile.mobile1 ?? '';
        guest.ageController.text = _resolveAge(profile)?.toString() ?? '';
        guest.dateOfBirthController = profile.dob != null
            ? TextEditingController(
                text: DateFormat('yyyy-MM-dd').format(profile.dob!),
              )
            : TextEditingController();
        guest.otpVerified = true;

        // Billing Info
        billingUserNameController.text = '${profile.name} ${profile.lname}';
        billingUserEmailController.text = profile.email ?? '';
        billingUserPhoneController.text =
            '+${profile.countryCodeMob1 ?? "91"}${profile.mobile1}';

        final gender = profile.gender?.trim().toLowerCase() ?? '';
        guest.selectedGender =
            (gender == 'm' || gender == 'male') ? 'Male' : 'Female';
      }
    } catch (e) {
      debugPrint('Error in initializeGuest: $e');
    } finally {
      isMembersLoading = false;
      notifyListeners();
    }
  }

  Future<void> prepareGuestFromBooking({
    required BuildContext context,
    required dynamic booking,
    required String packageName,
    required dynamic packageDrId,
  }) async {
    // Clear old guests
    guests.clear();

    // Reset pricing state for reschedule flow
    couponValue = 0;
    isCouponApplied = false;
    offersAndCouponController.clear();

    // Create new guest
    final guest = Guest();

    guest.firstNameController.text = booking.daFname?.toString() ?? '';
    guest.secondNameController.text = booking.daLname?.toString() ?? '';
    guest.emailController.text = booking.daEmail?.toString() ?? '';
    guest.phoneController.text = booking.daMobile?.toString() ?? '';
    guest.ageController.text = booking.age?.toString() ?? '';
    // Age calculation
    /*  if (booking.daDob != null) {
      final dob = DateTime.tryParse(booking.daDob.toString());

      if (dob != null) {
        final today = DateTime.now();
        int age = today.year - dob.year;

        if (today.month < dob.month ||
            (today.month == dob.month && today.day < dob.day)) {
          age--;
        }
        log("daDob from booking:  ${booking.daDob}");
        guest.ageController.text = age.toString();
      }
    } */

    guest.selectedGender =
        (booking.daGender?.toString() == 'M') ? 'Male' : 'Female';

    // Package details
    guest.selectedPackage = packageName;
    guest.selectedPackageRate = booking.daBillvalue?.toString() ?? '';
    guest.packageTypeValue = booking.daPackagetypevalue;
    guest.selectedDoctorId = int.tryParse(packageDrId ?? '');

    // Reset slot for reschedule
    guest.selectedSlot = null;
    guest.step = GuestStep.appointmentScheduling;

    // Add to list
    guests.add(guest);

    // Reset UI state
    showConfirmAppointmentDetails = false;

    // Fetch slots
    await getAvailableSlots(0, context);

    notifyListeners();
  }

  void clearGuestData() {
    guests.clear();
    billingUserNameController.clear();
    billingUserEmailController.clear();
    billingUserPhoneController.clear();
    // Reset coupon/discount state
    couponValue = 0;
    isCouponApplied = false;
    offersAndCouponController.clear();
    notifyListeners();
  }

  bool showBillingUser = false;
  bool isBillingUserVerified = false;
  int? currentGuestIndex;

  Future<void> verifyBillingUser(BuildContext context, int index) async {
    if (billingUserOtpController.text.isEmpty) {
      isBillingUserOtpError = true;
      notifyListeners();
      return;
    }

    setBillingOtpLoading = true;
    notifyListeners();

    var response = await verifyOTP(
      context: context,
      otp: billingUserOtpController.text,
      phoneNumber: billingUserPhoneController.text,
      name: billingUserNameController.text,
    );

    setBillingOtpLoading = false;

    if (response != null && response["success"] == true) {
      log('billingUser Verify: $response');

      isBillingVerified = true;
      isBillingUserOtpSent = false;
      showBillingUser = false;
      billingOtpTimer = -1;
      billingUserOtpController.clear();
      moveToScheduleAppointment = true;

      // Update guest steps
      for (var guest in guests) {
        guest.step = GuestStep.appointmentScheduling;
      }

      // Add a small delay to ensure token is properly saved
      await Future.delayed(Duration(milliseconds: 500));

      // Fetch slots for each guest
      for (int i = 0; i < guests.length; i++) {
        await getAvailableSlots(i, context);
      }

      isReturningFromBillingUser = true;

      notifyListeners();
    } else {
      showSnackBar(context, response?["message"] ?? "OTP verification failed");

      notifyListeners();
    }
  }

  void confirmPackage(Guest guest) {
    guest.step = GuestStep.appointmentScheduling;
    notifyListeners();
  }

  // Add this to your GuestProvider class
  Future saveSlot(BuildContext context, int index) async {
    final guest = guests[index];

    if (guest.selectedSlot == null) {
      showDialog(
        context: context,
        builder: (_) => _buildAlertDialog(
          context,
          message:
              'Almost there! Finish any remaining slot selections before moving forward.',
          buttonText: 'Finish selection',
        ),
      );
      return;
    }

    await slotBlocking(index, context);
    log("Selection Complete: Date = ${guest.selectedDate}, Slot = ${guest.selectedSlot}");

    /// Refresh slots for other guests (except current index)
    await Future.wait([
      for (int i = 0; i < guests.length; i++)
        if (i != index) getAvailableSlots(i, context),
    ]);
  }

  Widget _buildAlertDialog(
    BuildContext context, {
    required String message,
    required String buttonText,
  }) {
    return AlertDialog(
      contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RefractedText(
            textAlign: TextAlign.center,
            text: message,
            fontSize: 20,
            fontWeight: FontWeight.w400,
            textColor: AppColors.packageTextPrimary,
          ),
          SizedBox(height: 10),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.fromLTRB(10, 7, 10, 7),
              decoration: BoxDecoration(
                color: AppColors.bookNowButtonColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: RefractedText(
                  textAlign: TextAlign.center,
                  text: buttonText,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  textColor: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void resetReturnFlag() {
    isReturningFromBillingUser = false;
  }

  void selectDate(BuildContext context, int index) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: guests[index].selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.containerBackgroundColor,
              onPrimary: AppColors.sessionTextColor,
              onSurface: AppColors.packageTextPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.sessionTextColor,
              ),
            ),
            datePickerTheme: DatePickerThemeData(
              headerHeadlineStyle: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.packageTextPrimary,
              ),
              yearStyle: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.packageTextPrimary,
              ),
              dayStyle: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.packageTextPrimary,
              ),
              weekdayStyle: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.packageTextPrimary,
              ),
              headerHelpStyle: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.packageTextPrimary,
              ),

              /* dayHeaderStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.packageTextPrimary,
              ), */
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      guests[index].selectedDate = picked;

      notifyListeners();

      //  Call API to refresh available slots
      await getAvailableSlots(index, context);
    }
  }

  String formatSelectedDate(DateTime selectedDate) {
    final today = DateTime.now();
    final isToday = selectedDate.year == today.year &&
        selectedDate.month == today.month &&
        selectedDate.day == today.day;

    return isToday
        ? "Today, ${DateFormat('dd MMM yyyy').format(selectedDate)}"
        : DateFormat('EEE, dd MMM yyyy').format(selectedDate);
  }

  void moveToAppointmentScheduling(int index) {
    guests[index].step = GuestStep.appointmentScheduling;
    notifyListeners();
  }

  int get packageTotal {
    return guests.fold(0, (sum, guest) {
      int rate = int.tryParse(guest.selectedPackageRate) ?? 0;
      return sum + rate;
    });
  }

  int get totalAmount {
    int packageTotal = guests.fold(0, (sum, guest) {
      int rate = int.tryParse(guest.selectedPackageRate) ?? 0;
      return sum + rate;
    });

    return packageTotal + addonTotal;
  }

  void openDropdown(String field) {
    _currentField = field;
    _filteredOptions = field == 'Phone Number' ? phoneOptions : nameOptions;
    _isDropdownOpen = _filteredOptions.isNotEmpty;
    notifyListeners();
  }

  void closeDropdown() {
    _isDropdownOpen = false;
    notifyListeners();
  }

  Future<bool> paymentStatus(int index, String? paymentId) async {
    final pref = await SharedPreferencesService.prefs;
    final brchPtr = pref.getString(branchptr);
    final frmptr = pref.getString(firmptr);
    final sessionId = pref.getString(session);
    try {
      final guestList = guests;

      List<Map<String, dynamic>> members = guestList.map((guest) {
        return {
          "primary": true,
          "first_name": guest.firstNameController.text,
          "last_name": guest.secondNameController.text,
          "mobile": guest.phoneController.text,
          "package_value": guest.packageTypeValue,
          "age": guest.ageController.text,
          "gender": guest.selectedGender,
          "date": DateFormat('yyyy-MM-dd').format(guest.selectedDate),
          "appointment_time": guest.selectedSlot,
          "token": guest.tokenNo,
          "doctor": guest.selectedDoctorId,
          "email": guest.emailController.text,
          "othernatid": "",
        };
      }).toList();

      var data = {
        "package_type": "ITM",
        "branchptr": brchPtr,
        "firmptr": frmptr,
        "guestBooking": true,
        "mode": "NURA",
        "source": "APP",
        "cart_total": totalAmount,
        "payment_id": paymentId,
        "coupon_code": "",
        "members": members,
        "session_id": sessionId,
        "billing_guest": {
          "name": billingUserNameController.text,
          "email": billingUserEmailController.text,
          "email_verified": true,
          "mobile": billingUserPhoneController.text,
          "mobile_verified": false,
        },
      };
      log('SaveOrder Payload: ${jsonEncode(data)}');
      final prefs = await SharedPreferencesService.prefs;
      String? branchDbptr = prefs.getString(kSelectedBranchDbptr);

      var response = await secureFetch(
        method: 'POST',
        endpoint: Env().saveOrder,
        body: jsonEncode(data),
        dbPtr: branchDbptr,
      );

      if (response.data != null) {
        log('SaveOrder Response: ${jsonEncode(response.data)}');

        return true;
      } else {
        log('Failed to add Order');
        return false;
      }
    } catch (e) {
      log('Error during Save Order: $e');
      return false;
    }
  }
  Future<bool> saveOrder(int index, String? paymentId) async {
    final pref = await SharedPreferencesService.prefs;
    final brchPtr = pref.getString(branchptr);
    final frmptr = pref.getString(firmptr);
    final sessionId = pref.getString(session);
    try {
      final guestList = guests;

      List<Map<String, dynamic>> members = guestList.map((guest) {
        return {
          "primary": true,
          "first_name": guest.firstNameController.text,
          "last_name": guest.secondNameController.text,
          "mobile": guest.phoneController.text,
          "package_value": guest.packageTypeValue,
          "age": guest.ageController.text,
          "gender": guest.selectedGender,
          "date": DateFormat('yyyy-MM-dd').format(guest.selectedDate),
          "appointment_time": guest.selectedSlot,
          "token": guest.tokenNo,
          "doctor": guest.selectedDoctorId,
          "email": guest.emailController.text,
          "othernatid": "",
        };
      }).toList();

      var data = {
        "package_type": "ITM",
        "branchptr": brchPtr,
        "firmptr": frmptr,
        "guestBooking": true,
        "mode": "NURA",
        "source": "APP",
        "cart_total": totalAmount,
        "payment_id": paymentId,
        "coupon_code": "",
        "members": members,
        "session_id": sessionId,
        "billing_guest": {
          "name": billingUserNameController.text,
          "email": billingUserEmailController.text,
          "email_verified": true,
          "mobile": billingUserPhoneController.text,
          "mobile_verified": false,
        },
      };
      log('SaveOrder Payload: ${jsonEncode(data)}');
      final prefs = await SharedPreferencesService.prefs;
      String? branchDbptr = prefs.getString(kSelectedBranchDbptr);
      var response = await secureFetch(
        method: 'POST',
        endpoint: Env().saveOrder,
        body: jsonEncode(data),
        dbPtr: branchDbptr,
      );

      if (response.data != null) {
        log('SaveOrder Response: ${jsonEncode(response.data)}');

        return true;
      } else {
        log('Failed to add Order');
        return false;
      }
    } catch (e) {
      log('Error during Save Order: $e');
      return false;
    }
  }


  Future addGuest(int index) async {
    final guest = guests[index];
    final pref = await SharedPreferencesService.prefs;
    final deviceId = pref.getString(kDeviceId) ?? "";
    final sessionId = pref.getString(session);
    final lat = pref.getString(latitude);
    final long = pref.getString(longitude);
    await ensureGuestToken();

    var data = {
      "mode": "app",
      "device_id": deviceId,
      "session_id": sessionId,
      "guestDetails": {
        "index": index,
        "firstName": guest.firstNameController.text,
        "lastName": guest.secondNameController.text,
        "age": guest.ageController.text,
        "gender": guest.selectedGender,
        "mobile": guest.phoneController.text,
        // "email": guest.emailController.text,
        "email": isEmailMadatory
            ? guest.emailController.text.trim()
            : (guest.emailController.text.trim().isNotEmpty
                ? guest.emailController.text.trim()
                : ""),
        "mobileCountryCode": guest.countryCode,
      },
      "appointmentDetails": {
        "index": index,
        "appointment_date": '',
        "appointment_time": '',
      },
      "otherDetails": {"latitude": lat, "longitude": long},
    };

    log('Add guest Payload: ${jsonEncode(data)}');
    String? branchDbptr = pref.getString(kSelectedBranchDbptr);

    var response = await secureFetch(
      method: 'POST',
      endpoint: Env().addGuest,
      body: jsonEncode(data),
      dbPtr: branchDbptr,
    );

    if (response.data != null) {
      log('📥 Response: ${jsonEncode(response.data)}');
      final success = response.data['success'] == true;
      final message = response.data['message'] ?? "Something went wrong.";

      return {
        "success": success,
        "message": message,
      };
    } else {
      return {
        "success": false,
        "message": "No response from server.",
      };
    }
  }

  Future<Map<String, dynamic>> updateGuest(int index) async {
    final guest = guests[index];
    final pref = await SharedPreferencesService.prefs;
    final deviceId = pref.getString(kDeviceId) ?? "";
    final sessionId = pref.getString(session);
    // Safely handle nulls before formatting
    String formattedDate = "";
    String formattedTime = "";
    formattedDate = DateFormat('yyyy-MM-dd').format(guest.selectedDate);
    if (guest.selectedSlot != null) {
      formattedTime = guest.selectedSlot!;
    }

    try {
      var data = {
        "mode": "app",
        "device_id": deviceId,
        "session_id": sessionId,
        "guestDetails": {
          "index": index,
          "firstName": guest.firstNameController.text,
          "lastName": guest.secondNameController.text,
        },
        "appointmentDetails": {
          "index": index,
          "appointment_date": formattedDate,
          "appointment_time": formattedTime,
          "package": guest.selectedPackage,
        },
      };

      log('Update guest Payload: $data');
      String? branchDbptr = pref.getString(kSelectedBranchDbptr);

      var response = await secureFetch(
        method: 'POST',
        endpoint: Env().addGuest,
        body: jsonEncode(data),
        dbPtr: branchDbptr,
      );

      if (response.data != null) {
        log('Update Guest Payload: ${jsonEncode(data)}');
        log('Update Guest Response: ${response.data}');

        bool success = response.data["success"] ?? false;
        String message = response.data["message"] ?? "Unknown error";

        return {
          "success": success,
          "message": message,
        };
      } else {
        return {
          "success": false,
          "message": "Server did not respond",
        };
      }
    } catch (e) {
      log('Error during add guest: $e');
      return {
        "success": false,
        "message": "An unexpected error occurred",
      };
    }
  }

  Future<void> slotBlocking(int index, BuildContext context) async {
    setSlotsLoading(index, true);
    final pref = await SharedPreferencesService.prefs;

    // 1. Check Login Status — read from the module global (set by the host
    // via BookingFlowLauncher.isAppLoggedIn), not from SharedPreferences,
    // because nothing in this module persists that key.
    bool isLoggedIn = isAppLoggedIn;

    String? branchDbptr = pref.getString(kSelectedBranchDbptr);
    final guest = guests[index];
    final formattedDate = DateFormat('yyyy-MM-dd').format(guest.selectedDate);
    final formattedTime = guest.selectedSlot!;
    final sessionId = pref.getString(session);
    final sessionIdWithIndex = '${sessionId}_$index';

    var data = {
      "sessionid": sessionIdWithIndex,
      "appdate": formattedDate,
      "tokennumber": guest.tokenNo,
      "apptime": formattedTime,
      "source": "WEB",
      "submode": "APP",
      "packagetypevalue": guest.packageTypeValue,
      "mode": "NURA",
      "doctorptr": guest.selectedDoctorId,
    };

    var response = await secureFetch(
      method: 'POST',
      endpoint: Env().proceedPayment,
      body: jsonEncode(data),
      dbPtr: branchDbptr,
    );

    log('slotBlocking response statusCode: ${response.data?['statusCode']}, '
        'isLoggedIn: $isLoggedIn, otpVerified: ${guest.otpVerified}, '
        'hasUnauthorizedCallback: ${onUnauthorizedSlotBlocked != null}');
    if (response.data != null && response.data['statusCode'] == 200) {
      if (isLoggedIn) {
        // 3. APP-LOGGED-IN FLOW: Move directly to Confirmation
        guest.step = GuestStep.confirmation;
        showConfirmAppointmentDetails = true;
        log('User Authorized (Logged In: $isLoggedIn, OTP: ${guest.otpVerified})');
      } else {
        // 4. NOT APP-LOGGED-IN FLOW: Let the host decide where to send the
        // user (e.g. back to the home tab or to a login screen). OTP-only
        // verification still counts as not logged in for the host app.
        log('slotBlocking firing onUnauthorizedSlotBlocked callback');
        onUnauthorizedSlotBlocked?.call();
      }

      if (appointmentTimer == null || !appointmentTimer!.isActive) {
        startAppointmentTimer();
      }

      log('Slot Blocked Successfully');
      setSlotsLoading(index, false);
      notifyListeners();
    } else {
      log('Failed to Block');
      setSlotsLoading(index, false);
    }
  }

  String paymentId = '';
  String paymentv2Id = '';
  Future<void> initiatePaymentV2(
    BuildContext context,
    int index,
    bool loggedInFlag,
  ) async {
    final pref = await SharedPreferencesService.prefs;
    log('InitiatePaymentV2 called');
    final brchPtr = pref.getString(branchptr);
    final frmptr = pref.getString(firmptr);
    String? branchDbptr = pref.getString(kSelectedBranchDbptr);
    final deviceId = pref.getString(kDeviceId) ?? "";
    log('Firmid: $frmptr, Branchid: $brchPtr');
    final razorpayKey = pref.getString('razorpay_key');
    log('Razorpay Key: $razorpayKey');
    log('Device ID: $deviceId');
    if (razorpayKey == null || razorpayKey.isEmpty) return;
    // show overlay before preparing payment
    _setPaymentProcessing(true);

    // Prepare payload
    final guestList = guests;
    List<Map<String, dynamic>> members = guestList.map((guest) {
      return {
        "first_name": guest.firstNameController.text,
        "last_name": guest.secondNameController.text,
        "mobile": sanitizePhone(guest.phoneController.text),
        "country_code": sanitizeCountryCode(guest.countryCode),
        "dob": guest.dateOfBirthController.text,
        "package_value": guest.packageTypeValue,
        "age": guest.ageController.text,
        "gender": guest.selectedGender,
        "date": DateFormat('yyyy-MM-dd').format(guest.selectedDate),
        "appointment_time": guest.selectedSlot,
        "token": guest.tokenNo,
        "doctor": guest.selectedDoctorId,
        "email": isEmailMadatory
            ? guest.emailController.text.trim()
            : (guest.emailController.text.trim().isNotEmpty
                ? guest.emailController.text.trim()
                : ""),
        "othernatid": "",
        if (selectedAddons.isNotEmpty) "addon_packages": selectedAddonCodes,
      };
    }).toList();
    final sessionId = pref.getString(session);
    var data = {
      "amount": payableAmount == 0 ? totalAmount : payableAmount,
      "branchptr": brchPtr,
      "firmptr": frmptr,
      "package_type": "ITM",
      "coupon_code": payableAmount == 0 ? '' : offersAndCouponController.text,
      "national_id": "",
      "device_id": deviceId,
      "source": 'NAPP',
      "addon_packages": [],
      "session_id": sessionId,
      "members": members,
      if (!loggedInFlag)
        "billing_guest": {
          "name": billingUserNameController.text,
          "email": billingUserEmailController.text,
          "email_verified": billingUserEmailController.text.isNotEmpty,
          "mobile": sanitizePhone(billingUserPhoneController.text),
          "mobile_verified": billingUserPhoneController.text.isNotEmpty,
        },
    };

    log('Payload: ${jsonEncode(data)}');
    log('Original Session ID: $sessionId');
    try {
      // Call API to initiate order
      var response = await secureFetch(
        method: 'POST',
        endpoint: Env().initiatePaymentV2,
        body: jsonEncode(data),
        dbPtr: branchDbptr,
      );
     log('Response Status Code: ${response.status}');
      log('Response Data: ${jsonEncode(response.data)}');
      if ((response.status == 200 || response.status == 201) &&
          response.data['success'] == true) {
        paymentv2Id = response.data['data'];
        log('paymentV2 Id from initiate payment: $paymentId');
        // Hide loader before opening Razorpay

        log('Initiate PaymentV2 Response: ${jsonEncode(response.data)}');
        _currentGuestIndex = index;
        await initiatePayment(context, paymentv2Id);
        log('Initiated Payment Successfully');
      } else {
        _setPaymentProcessing(false);
        showSnackBar(
          context,
          response.data['message'] ?? "Failed to initiate payment. Try again.",
        );
      }
    } catch (e) {
      _setPaymentProcessing(false);
      log('Error initiating paymentV2: $e');

      showSnackBar(context, "Something went wrong. Try again.");
    }
  }

  String sanitizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[^\d]'), '');
  }

  String sanitizeCountryCode(String code) {
    return code.replaceAll(RegExp(r'[^\d]'), '');
  }

  Future<void> initiatePayment(BuildContext context, paymentv2Id) async {
    // Capture the host app's root navigator before launching Razorpay so the
    // success callback can navigate when this module is embedded (no module
    // [MaterialApp]/[navigatorKey] is in the tree in that case).
    _paymentNavigator = Navigator.of(context, rootNavigator: true);
    final pref = await SharedPreferencesService.prefs;
    String? branchDbptr = pref.getString(kSelectedBranchDbptr);
    var data = {"paymentRefId": paymentv2Id, "paymentProvider": 'razorpay'};
    try {
      // Call API to initiate order
      var response = await ApiService.apiMethodSetup(
        method: ApiMethod.post,
        url: Env().initiateOrder,
        data: jsonEncode(data),
        dbPtr: branchDbptr,
        options: Options(
          headers: {
            "mode": "booking",
          },
          validateStatus: (status) {
            return true;
          },
        ),
      );
      log('Response Status Code: ${response?.statusCode}');
      log('Initiate order payload: ${jsonEncode(data)}');
      log('Response Data: ${jsonEncode(response?.data)}');
      if ((response?.statusCode == 200 || response?.statusCode == 201) &&
          response?.data['success'] == true) {
        paymentId = response?.data['data']['id'];
        log('Order Id from initiate payment: $paymentId');
        // Hide loader before opening Razorpay
        _setPaymentProcessing(false);
        log('Initiate Payment Response: ${jsonEncode(response?.data)}');
        openCheckout(
          name: billingUserNameController.text,
          amount: totalAmount,
          orderId: paymentId,
        );
        log('Initiated Payment Successfully');
      } else {
        _setPaymentProcessing(false);
        showSnackBar(context, "Failed to initiate payment. Try again.");
      }
    } catch (e) {
      _setPaymentProcessing(false);
      log('Error initiating payment: $e');

      showSnackBar(context, "Something went wrong. Try again.");
    }
  }

  Future<Map<String, dynamic>?> fetchAppointmentDetails({
    required BuildContext context,
    required List<String> appointmentIds,
  }) async {
    final prefs = await SharedPreferencesService.prefs;
    final branchDbptr = prefs.getString(kSelectedBranchDbptr);

    final body = {
      "appointment_ids": appointmentIds,
      "country_code": guests.first.countryCode,
    };

    try {
       final response = await secureFetch(
        method: 'POST',
        endpoint: Env().appointmentDetails,
        body: jsonEncode(body),
        dbPtr: branchDbptr,
      );

      final code = response.data?['status'] ?? response.data?['statusCode'];

      if (code == 200 && response.data?['success'] == true) {
        log('Appointment Detail response: ${response.data}');
        return response.data;
      }

      showSnackBar(
        context,
        response.data?['message'] ?? 'Something went wrong. Please try again.',
      );
    } catch (e, st) {
      log('fetchAppointmentDetails → $e\n$st');
      showSnackBar(context, 'Network error — please try again.');
    }

    return null;
  }

  Future<bool> downloadAndOpenPdf(String? previewB64) async {
    if (previewB64 == null || previewB64.trim().isEmpty) return false;

    try {
      /* 1. base64 → HTML → PDF */
      final html = utf8.decode(base64Decode(previewB64));
      // ignore: deprecated_member_use
      final Uint8List pdfBytes = await Printing.convertHtml(html: html);

      /* 2. Decide where to put it */
      // ─── ANDROID ──────────────────────────────────────────────────────────
      late final Directory targetDir;

      if (Platform.isAndroid) {
        // ask politely – required for Android 13+ public folders
        final storageOk = await Permission.manageExternalStorage.request();
        if (storageOk.isGranted) {
          targetDir = ((await getDownloadsDirectory()) ??
              await getExternalStorageDirectory())!;
        } else {
          // user said “no” → fall back to private cache
          targetDir = await getTemporaryDirectory();
        }
      }
      // ─── iOS ─────────────────────────────────────────────────────────────
      else if (Platform.isIOS) {
        // iOS has no public ’Downloads’, keep it in Documents
        targetDir = await getApplicationDocumentsDirectory();
      }
      // ─── DESKTOP / WEB Fallback ──────────────────────────────────────────
      else {
        targetDir =
            await getDownloadsDirectory() ?? await getTemporaryDirectory();
      }

      /* 3. Write it */
      final fileName =
          'confirmation_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${targetDir.path}/$fileName');
      await file.writeAsBytes(pdfBytes, flush: true);

      debugPrint('PDF saved at → ${file.path}');

      /* 4. Fire it up */
      final result = await OpenFilex.open(file.path);
      return result.type == ResultType.done;
    } catch (e, s) {
      debugPrint('downloadAndOpenPdf failed → $e\n$s');
      return false;
    }
  }

  void selectValue(String value) {
    if (currentField == 'Phone Number') {
      billingUserPhoneController.text = value;

      final phone = sanitisePhone(value, billingUsercountryCodeController);

      if (!verifiedPhoneNumbers.contains(phone)) {
        verifiedPhoneNumbers.add(phone);
      }

      if (isBillingPhoneVerified()) {
        isBillingVerified = true;
        moveToScheduleAppointment = true;
      }
    } else if (currentField == 'Name') {
      billingUserNameController.text = value;
    }

    _isDropdownOpen = false;
    notifyListeners();
  }

  bool isBillingPhoneVerified() {
    final phone = sanitisePhone(
      billingUserPhoneController.text,
      billingUsercountryCodeController,
    );
    return verifiedPhoneNumbers.contains(phone);
  }

  void selectBillingPhone(String phone) {
    final cleaned = sanitisePhone(phone, billingUsercountryCodeController);
    billingUserPhoneController.text = phone;
    isBillingVerified = true;
    billingUserVerifiedPhone = cleaned;

    if (!verifiedPhoneNumbers.contains(cleaned)) {
      verifiedPhoneNumbers.add(cleaned);
    }

    closeDropdown();
    notifyListeners();
  }

  void selectPhone(String phone, Guest guest) {
    final cleaned = sanitisePhone(phone, guest.countryCode);
    guest.phoneController.text = phone;
    guest.otpVerified = true;
    guest.verifiedPhoneNumber = cleaned;

    if (!verifiedPhoneNumbers.contains(cleaned)) {
      verifiedPhoneNumbers.add(cleaned); //  Ensure this
    }

    closeDropdown();
    notifyListeners();
  }

  void filterOptions(String query) {
    if (_currentField.isEmpty) return;

    if (_currentField == 'Phone Number') {
      _filteredOptions = phoneOptions;
      _isDropdownOpen = query.isEmpty;
    } else {
      _filteredOptions = nameOptions
          .where((option) => option.toLowerCase().contains(query.toLowerCase()))
          .toList();
      _isDropdownOpen = _filteredOptions.isNotEmpty || query.isEmpty;
    }

    notifyListeners();
  }

  void sendOtpForBillingUser() {
    if (billingUserNameController.text.isEmpty) {
      isBillingUserError = true;
      notifyListeners();
    } else if (billingUserPhoneController.text.isEmpty) {
      isBillingUserError = false;
      isBillingPhoneNumberError = true;
      notifyListeners();
    } else {
      isBillingUserError = false;
      isBillingPhoneNumberError = false;
      isBillingEmailError = false;
      isBillingUserOtpSent = true;
      notifyListeners();
    }
  }

  /// Method to start the OTP timer
  void startBillingOtpTimer() {
    billingOtpTimer = 60; // Reset timer
    canBillingUserResendOtp = false;
    notifyListeners();

    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (billingOtpTimer > 0) {
        billingOtpTimer--;
        notifyListeners();
      } else {
        timer.cancel();
        canBillingUserResendOtp = true;
      }
    });
  }

// inside GuestProvider class
  Future<void> selectPackageAndProceed(
    BuildContext context,
    PackagesListModel package,
  ) async {
    showConfirmAppointmentDetails = false;
    isFromReschedule = false;

    // Reset pricing state to prevent stale data from previous selections
    couponValue = 0;
    isCouponApplied = false;
    isCouponExpanded = false;
    selectedAddons.clear();
    offersAndCouponController.clear();

    // 1. Ensure exactly one Guest object exists for the primary user
    if (guests.isEmpty) {
      guests.add(Guest());
      guests[0].selectedDate = DateTime.now();
    } else {
      // If we already have guests, we target the first one (primary user)
      // and clear any previous selection to avoid stale data
      log("Reusing existing guest object to prevent duplicates.");
    }

    final guest = guests[0];

    // 2. Initialize profile if logged in
    if (isAppLoggedIn) {
      await initializeGuest(context, isAppLoggedIn);
    }

    // 3. Update the package details for the primary guest
    guest.selectedPackageIndex = 0;
    guest.selectedPackage = package.itmDesc ?? '';
    guest.selectedPackageRate = package.irRate.toString();
    guest.selectedDoctorId = int.tryParse(package.itmSlotdoctorptr ?? '');
    guest.packageTypeValue = package.itmCode.toString();

    // Reset slot selection so they pick a fresh one
    guest.selectedSlot = null;
    guest.step = GuestStep.appointmentScheduling;

    // 4. Fetch slots
    await getAvailableSlots(0, context);

    notifyListeners();
  }

  void selectPackageForGuest(int index, PackagesListModel package) {
    guests[index].selectedPackage = package.itmDesc ?? '';
    guests[index].packageRate = package.irRate ?? 0;
    notifyListeners();
  }

  void editGuest(int index) {
    if (index < 0 || index >= guests.length) return;

    // collapse everything first
    for (var g in guests) {
      g.isExpanded = false;
      g.showOtp = false;
    }

    final guest = guests[index];

    guest
      ..isExpanded = true
      ..step = GuestStep.appointmentScheduling
      ..otpController.clear()
      ..isOtpError = false;
    // ..otpVerified = false; // <-- reset the “verified” state
// Clear previously selected package
    guest.selectedPackageIndex = null;
    guest.selectedPackage = '';
    guest.selectedPackageRate = '';
    guest.selectedDoctorId = null;
    guest.packageTypeValue = '';
    updateGuestPackage(guest, '', '');
    currentGuestIndex = index;
    setLoading(index, false);
    notifyListeners();
  }

  void editFromConfirmation(int index) {
    // 1. Crucial: Tell the UI to stop showing the Confirmation View
    showConfirmAppointmentDetails = false;

    // 2. Set the current editing index
    currentGuestIndex = index;

    // 3. Reset the step for the guest being edited
    if (index >= 0 && index < guests.length) {
      guests[index].step = GuestStep.appointmentScheduling;
      guests[index].isExpanded = true; // Ensure the card is open for editing
    }

    // 4. Reset other internal flags that might interfere
    isCouponApplied = false;

    log("DEBUG: Editing from Confirmation. Flag set to false. Step set to Scheduling.");
    guests[0].otpVerified = true;

    notifyListeners();
  }

  void expandGuestForm(int index) {
    if (index < 0 || index >= guests.length) return;

    // Collapse all guests except the one being expanded
    for (int i = 0; i < guests.length; i++) {
      if (i != index) {
        guests[i].isExpanded = false;
        guests[i].showOtp = false;
      }
    }

    guests[index].isExpanded = true;

    // Restore the step user left off at
    if (guests[index].step != GuestStep.appointmentScheduling) {
      guests[index].showOtp = true;
    }

    notifyListeners();
  }

  /// Check if all guests have selected a time slot and date
  bool get areAllGuestsScheduled {
    return guests.every(
      (guest) =>
          guest.selectedSlot != null && guest.isAppointmentSelected == true,
    );
  }

  bool anyGuestBeforePackageDetail(List<Guest> guests) {
    return guests.any(
      (guest) => guest.step.index < GuestStep.appointmentScheduling.index,
    );
  }

  int? _paymentGuestIndex;

  int? get paymentGuestIndex => _paymentGuestIndex;

  bool get allGuestsConfirmed =>
      guests.every((g) => g.step == GuestStep.confirmation);

  Future<void> scheduleGuestsAfterBillingVerification(
    BuildContext context,
  ) async {
    for (var guest in guests) {
      guest.step = GuestStep.appointmentScheduling;
    }
    for (int i = 0; i < guests.length; i++) {
      await getAvailableSlots(i, context);
    }
    isReturningFromBillingUser = true;
    moveToScheduleAppointment = false;
    notifyListeners();
  }

  Future<void> onBillingVerificationSuccess(BuildContext context) async {
    isBillingVerified = true;
    isBillingUserOtpSent = false;
    showBillingUser = false;
    billingOtpTimer = -1;
    billingUserOtpController.clear();
    moveToScheduleAppointment = false;

    // 🚨 Do NOT assert guest steps here
    // Just move forward after billing is verified

    // Only update guests to appointmentScheduling step
    for (var guest in guests) {
      if (guest.step.index < GuestStep.appointmentScheduling.index) {
        guest.step = GuestStep.appointmentScheduling;
      }
    }

    // Small delay to ensure session/token sync
    await Future.delayed(Duration(milliseconds: 500));

    for (int i = 0; i < guests.length; i++) {
      await getAvailableSlots(i, context);
    }

    isReturningFromBillingUser = true;
    notifyListeners();
  }

  // In your Provider class
  bool isBillingLoading = false;

 Future<void> handleContinue(
    BuildContext context,
    int index,
    bool loggedInFlag,
  ) async {
    if (guests.isEmpty) return;

    isBillingLoading = true;
    notifyListeners();

    try {
      final guest = guests[index];
      final currentStep = guest.step;

      switch (currentStep) {
        case GuestStep.addGuest:
          // 1. If OTP is showing but not verified, warn the user
          if (guest.showOtp && !guest.otpVerified) {
            showSnackBar(context, 'Please verify the OTP to continue.');
          }
          // 2. If OTP is already verified, move to confirmation
          else if (guest.showOtp && guest.otpVerified) {
            guest.step = GuestStep.confirmation;
          }
          // 3. Otherwise, perform the initial form validaftion and add guest
          else {
            await validateAndProceed(context, index);
          }
          break;

        case GuestStep.appointmentScheduling:
          // 1. Check if slots are selected
          if (guest.showOtp && !guest.otpVerified) {
            showSnackBar(context, 'Please verify the OTP to continue.');
            isBillingLoading = false;
            notifyListeners();
            return;
          }

          if (guest.selectedSlot == null) {
            await _showIncompleteSlotsDialog(context);
            return;
          }
          if (isFromReschedule) {
            isBillingLoading = true;
            notifyListeners();
            final success = await rescheduleAppointment(
              context,
              rescheduleAppointmentId ?? '',
            );
            isBillingLoading = false;
            notifyListeners();
            if (success) {
              isFromReschedule = false;
              guests.clear();
              notifyListeners();

              if (context.mounted && Navigator.canPop(context)) {
                Navigator.pop(context, true);
              }
            }

            return;
          }
          await saveSlot(context, index);
          break;

        case GuestStep.confirmation:
          if (remainingTime.inSeconds <= 0) {
            showSnackBar(
              context,
              'Your slot expired. Please select a new slot to book.',
            );
            notifyListeners();
            return;
          }
          // 1. Gender/Package Mismatch Validation
          if (_isPackageMismatch(guest)) {
            _handlePackageMismatchRedirect(context, guest);
            return;
          }

          // 2. Final step: Trigger Payment
          await initiatePaymentV2(context, 0, loggedInFlag);
          break;
      }
    } catch (e) {
      debugPrint("Error in handleContinue: $e");
    } finally {
      isBillingLoading = false;
      notifyListeners();
    }
  }

   Future<bool> rescheduleAppointment(
    BuildContext context,
    String appointmentId,
  ) async {
    final pref = await SharedPreferencesService.prefs;

    final guest = guests[0];
    final formattedDate = DateFormat('yyyy-MM-dd').format(guest.selectedDate);
    final formattedTime = guest.selectedSlot!;
    final brchPtr = pref.getString(kSelectedBranchDbptr);

    var map = {
      "doctorptr": guest.selectedDoctorId,
      "date": formattedDate,
      "aptime": formattedTime,
      "tokenno": guest.tokenNo
    };

    final url = Env().resheduleAppointment(appointmentId: appointmentId);

    try {
      final response = await secureFetch(
        method: 'PUT',
        endpoint: url,
        body: map,
        dbPtr: brchPtr,
      );

     if ((response.data['statusCode'] == 200 ||
              response.data['statusCode'] == 201) &&
          response.data['success'] == true) {
        showSnackBar(
          context,
          'Your appointment has successfully rescheduled'.tr(),
        );
        final loginProvider =
            Provider.of<LoginProvider>(context, listen: false);

        loginProvider.getBookingList();
        return true;
      } else {
        showSnackBar(
            context, response.data['message'] ?? 'Something went wrong');
        return false;
      }
    } catch (e) {
      debugPrint("Reschedule error: $e");
      showSnackBar(context, 'Something went wrong');
      return false;
    }
  }


  bool _isPackageMismatch(Guest guest) {
    final gender = guest.selectedGender?.toLowerCase() ?? '';
    final packageType = int.tryParse(guest.packageTypeValue.toString()) ?? 0;

    bool isMaleMismatch =
        (gender == 'male' || gender == 'm') && packageType != 16;
    bool isFemaleMismatch =
        (gender == 'female' || gender == 'f') && packageType != 17;

    return isMaleMismatch || isFemaleMismatch;
  }

  void _handlePackageMismatchRedirect(BuildContext context, Guest guest) {
    String registeredAs =
        (guest.selectedGender?.toLowerCase().startsWith('m') ?? false)
            ? "Male"
            : "Female";

    showSnackBar(
      context,
      "You are registered as $registeredAs, but selected a different package. Redirecting...",
    );

    guest.step = GuestStep.appointmentScheduling;
    showConfirmAppointmentDetails = false;

    if (context.mounted) {
      final navigator = Navigator.of(context);
      if (navigator.canPop()) {
        navigator.pop();
        if (navigator.canPop()) {
          navigator.pop();
        }
      }
      guest.selectedDate = DateTime.now();
      guest.selectedSlot = null;
      clearAddons();
      clearCoupon();
    }
  }

  // ignore: unused_element
  void _setAllSteps(GuestStep step) {
    for (final g in guests) {
      g.step = step;
    }
  }

/* helper dialog extracted to keep main method tidy */
  Future<void> _showIncompleteSlotsDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (_) => AlertDialog(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const RefractedText(
              textAlign: TextAlign.center,
              text:
                  'Almost there! Finish any remaining slot selections before moving forward.',
              fontSize: 20,
              fontWeight: FontWeight.w400,
              textColor: AppColors.packageTextPrimary,
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
                decoration: BoxDecoration(
                  color: AppColors.bookNowButtonColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(
                  child: RefractedText(
                    textAlign: TextAlign.center,
                    text: 'Finish selection',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    textColor: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Sets the loading state.
  bool isPaymentProcessing = false;
  bool isFetchingPaymentDetails = false;

  void _setFetchingPaymentDetails(bool val) {
    isFetchingPaymentDetails = val;
    notifyListeners();
  }

  void _setPaymentProcessing(bool value) {
    isPaymentProcessing = value;
    notifyListeners();
  }

  void setPaymentProcessing(bool value) => _setPaymentProcessing(value);

  bool isLoading = false;
  void setLoading(int index, bool value) {
    guests[index].isGuestLoading = value;
    notifyListeners();
  }

  bool isSlotsLoading = false;
  void setSlotsLoading(int index, bool value) {
    guests[index].isAppointmentSelected = value;
    notifyListeners();
  }

  bool isLoadingGuest(int index) => guests[index].isGuestLoading;
  bool isSlotSelected(int index) => guests[index].isAppointmentSelected;

  /// Sets the loading state.
  set setBillingOtpLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  /// Generate an OTP for Number verification.
  Future<dynamic> generateOTP({
    required String userType,
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    var data = {
      "id": "",
      "fname": firstName,
      "lname": lastName,
      "phone_number": phoneNumber,
    };
    await SharedPreferencesService.prefs;
    try {
       var response = await secureFetch(
        method: 'POST',
        endpoint: Env().generateOtpForGuestsUser,
        body: jsonEncode(data),
        // dbPtr: branchDbptr,
      );
      log('Generate Otp Payload: ${jsonEncode(data)}');
      log('Generate OTP: $response');
// Return response data if successful
      return response.data;
    } catch (e) {
      log("Error sending OTP: $e");
      // Return null if an error occurs
      return null;
    }
  }

  final _billingnameReg = RegExp(r"^[A-Za-z]+(?:[ '\-][A-Za-z]+)*$");

  // ignore: unused_element
  bool _isValidBillingName(String s) => _billingnameReg.hasMatch(s.trim());

  Future<void> generateOtpForBilling(BuildContext context) async {
    final isClean = _setBillingErrors();
    notifyListeners();

    if (!isClean) return;

    //  no errors → proceed
    isLoading = true;
    notifyListeners();

    final response = await generateOTP(
      userType: "",
      firstName: billingUserNameController.text,
      lastName: "",
      phoneNumber: billingUserPhoneController.text,
    );

    if (response?["success"] == true) {
      startBillingOtpTimer();
      isBillingUserOtpSent = true;
      showSnackBar(context, 'OTP sent successfully!');
    } else {
      showSnackBar(context, response?["message"] ?? "Failed to send OTP");
    }

    isLoading = false;
    notifyListeners();
  }

  final _nameReg = RegExp(r'^[A-Za-z\s]+$');
  final _emailReg = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[A-Za-z]{2,}$');
  final _digitsReg = RegExp(r'^\d+$');

  bool _isValidName(String s) => _nameReg.hasMatch(s.trim());
  bool _isValidEmail(String s) => _emailReg.hasMatch(s.trim());
  bool _isDigitsOnly(String s) => _digitsReg.hasMatch(s.trim());

  int? _resolveAge(ProfileModel profile) {
    if (profile.calculatedAge != null) return profile.calculatedAge;
    if (profile.ageYear != null) return profile.ageYear;
    final dob = profile.dob;
    if (dob != null) {
      final today = DateTime.now();
      var age = today.year - dob.year;
      if (today.month < dob.month ||
          (today.month == dob.month && today.day < dob.day)) {
        age--;
      }
      if (age >= 0) return age;
    }
    return null;
  }

  bool _setBillingErrors() {
    // Name validation - required and must be valid
    isBillingUserError = billingUserNameController.text.isEmpty ||
        !_isValidName(billingUserNameController.text);

    // Phone validation - required and must be digits only
    isBillingPhoneNumberError = billingUserPhoneController.text.isEmpty ||
        !_isDigitsOnly(billingUserPhoneController.text);

    // Email validation - optional, but if provided must be valid
    isBillingEmailError = billingUserEmailController.text.isNotEmpty &&
        !_isValidEmail(billingUserEmailController.text);

    // Return true if no errors, false if any errors exist
    return !(isBillingUserError ||
        isBillingPhoneNumberError ||
        isBillingEmailError);
  }

  bool needsOtp(Guest guest) {
    if (!isOtpEnabled) return false;

    final current =
        sanitisePhone(guest.phoneController.text, guest.countryCode);

    // Even if guest.verifiedPhoneNumber is null/empty, fallback to global list
    final isAlreadyVerified = current == guest.verifiedPhoneNumber ||
        verifiedPhoneNumbers.contains(current);

    return !isAlreadyVerified;
  }

  Future<void> validateAndProceed(BuildContext context, int index) async {
    setLoading(index, true);

    if (index < 0 || index >= guests.length) {
      setLoading(index, false);
      return;
    }

    final guest = guests[index];

    //  Field-level validation
    guest.firstNameError = guest.firstNameController.text.trim().isEmpty ||
        !_isValidName(guest.firstNameController.text);
    guest.lastNameError = guest.secondNameController.text.trim().isEmpty ||
        !_isValidName(guest.secondNameController.text);
    guest.ageError = guest.ageController.text.isEmpty ||
        !_isDigitsOnly(guest.ageController.text);
    guest.phoneError = guest.phoneController.text.isEmpty ||
        !_isDigitsOnly(guest.phoneController.text) ||
        !isPhoneLengthValid(guest.phoneController.text, guest.countryCode);
    guest.emailError = guest.emailController.text.trim().isEmpty ||
        !_isValidEmail(guest.emailController.text.trim());
    billingUserNameController.text =
        '${guest.firstNameController.text} ${guest.secondNameController.text}';
    billingUserEmailController.text = guest.emailController.text.trim();
    billingUserPhoneController.text =
        '${guest.countryCode}${guest.phoneController.text}';
    if (guest.hasAnyError ||
        guest.selectedGender == null ||
        guest.countryCode.isEmpty) {
      setLoading(index, false);
      notifyListeners();
      return;
    }

    // Age validation
    final age = int.tryParse(guest.ageController.text);
    if (age == null || age < 20) {
      showSnackBar(
        context,
        'Oops! Guests of this age are not eligible for screening',
      );
      setLoading(index, false);
      return;
    }

    //  Persist guest (The API call to save data)
    final result = await addGuest(index);
    if (!(result['success'] ?? false)) {
      showSnackBar(context, result['message'] ?? 'Failed to add guest.');
      setLoading(index, false);
      notifyListeners();
      return;
    }

    //  OTP and Step Logic
    final currentPhone =
        sanitisePhone(guest.phoneController.text, guest.countryCode);
    final phoneAlreadyVerified = verifiedPhoneNumbers.contains(currentPhone) ||
        guest.verifiedPhoneNumber == currentPhone;

    _collapseAllExcept(index);

    if (isOtpEnabled && !phoneAlreadyVerified) {
      // FLOW: Send OTP
      final response = await generateOTP(
        userType: '',
        firstName: guest.firstNameController.text,
        lastName: guest.secondNameController.text,
        phoneNumber: currentPhone,
      );

      if (response['success'] == true) {
        guest.pendingOtpPhone = currentPhone;

        // 1. Prepare the guest state
        guest
          ..showOtp = true
          ..otpVerified = false
          ..isOtpError = false
          ..isExpanded = true;

        // 2. THIS IS THE KEY:
        // This global flag in GuestProvider must be false so the
        // ListView rebuilds and picks 'GuestDetail' instead of 'GuestForm'
        continueAsGuest = false;

        // 3. Update the step to something other than addGuest
        // (e.g., appointmentScheduling or a specific OTP step)
        guest.step = GuestStep.appointmentScheduling;

        guest.startOtpTimer(notifyListeners);

        // 4. Force immediate UI refresh
        notifyListeners();
      } else {
        showSnackBar(context, response['message'] ?? 'Failed to send OTP');
      }
    } else {
      // FLOW: Skip OTP (Already verified)
      continueAsGuest = false;
      guest
        ..showOtp = false // No need to show OTP field
        ..otpVerified = true
        ..verifiedPhoneNumber = currentPhone
        ..isExpanded = true
        ..step = GuestStep.confirmation; // Skip directly to scheduling

      // Note: Package API call removed as requested.
    }

    setLoading(index, false);
    notifyListeners();
  }

  int getMaxPhoneLength(String countryCode) {
    switch (countryCode.trim()) {
      case '+91':
      case '91':
        return 10;
      case '+1':
      case '1':
        return 10;
      case '971':
      case '+971':
        return 9;
      default:
        return 10;
    }
  }

  bool isPhoneLengthValid(String phone, String countryCode) {
    final phoneLength = phone.trim().length;
    final maxLength = getMaxPhoneLength(countryCode);
    return phoneLength == maxLength;
  }

  String sanitisePhone(String phone, String countryCode) {
    return '$countryCode${phone.replaceAll(RegExp(r'\D'), '')}';
  }

  final Set<String> verifiedPhoneNumbers = {};

  void _collapseAllExcept(int index, {bool keepOtpForCurrent = false}) {
    for (var i = 0; i < guests.length; i++) {
      guests[i].isExpanded = i == index;
      if (i != index || !keepOtpForCurrent) {
        guests[i].showOtp = false;
      }
    }
  }

  void verifyGuestOTP(BuildContext context, int index) async {
    final guest = guests[index];
    setLoading(index, true);
    if (guest.otpController.text.isEmpty) {
      guest.isOtpError = true;
      notifyListeners();
      return;
    }

    guest
      ..isOtpError = false
      ..otpVerified = false;
    notifyListeners();
    var response = await verifyOTP(
      context: context,
      otp: guest.otpController.text,
      phoneNumber: sanitisePhone(guest.phoneController.text, guest.countryCode),
      name: guest.firstNameController.text,
    );

    if (response != null && response["success"] == true) {
      guest.otpVerified = true;
      guest.isOtpError = false;
      notifyListeners(); // Show green success state
      log('Verify OTP: ${guest.otpVerified}');
      await Future.delayed(Duration(seconds: 2));

      // THIS IS THE FIX:
      guest.showOtp = false; // This hides the OTP input
      guest.step = GuestStep.confirmation;

      notifyListeners();
      log('Verify Otp From Guests: $response');
    } else {
      guest.otpVerified = false;
      guest.isOtpError = true;
    }

    setLoading(index, false);
    notifyListeners();
  }

  /// Reusable function to verify OTP for both billing users and guests
  Future<dynamic> verifyOTP({
    required BuildContext context,
    required String otp,
    required String phoneNumber,
    required String name,
  }) async {
    var data = {
      "otp": otp,
      "value": phoneNumber,
      "type": 'mobile',
      "name": name,
    };

    log("OTP Verification Request: $data");
    await SharedPreferencesService.prefs;
    try {
      final response = await secureFetch(
        method: 'POST',
        endpoint: Env().verifyOtpForGuestUser,
        body: jsonEncode(data),
        // dbPtr: branchDbptr
      );
      log('Otp Verification response: ${response.data}');
      return response.data;
    } catch (e) {
      log("Error verifying OTP: $e");
      return null;
    }
  }

  bool allGuestsReachedPackageDetail(List<Guest> guests) {
    return guests
        .every((guest) => guest.step == GuestStep.appointmentScheduling);
  }

  void resendOTP(BuildContext context, int index) async {
    final guest = guests[index];
    final currentPhone =
        sanitisePhone(guest.phoneController.text, guest.countryCode);
    var response = await generateOTP(
      userType: "",
      firstName: guest.firstNameController.text,
      lastName: guest.secondNameController.text,
      phoneNumber: currentPhone,
    );

    if (response['success'] == true) {
      // guest.otpID = response["otp_id"]; // Update OTP ID
      guest.canResendOtp = false;
      guest.startOtpTimer(notifyListeners);

      // Optionally clear the OTP field
      guest.otpController.clear(); // Uncomment if you want to clear it
      showSnackBar(context, "A new OTP has been sent");
    } else {
      showSnackBar(context, response?["message"] ?? "Failed to resend OTP");
    }

    notifyListeners();
  }

  void updateGuestPackage(
    Guest guest,
    String selectedPackage,
    String rate,
  ) {
    final idx = guests.indexOf(guest);
    if (idx != -1) {
      guests[idx]
        ..selectedPackage = selectedPackage
        ..selectedPackageRate = rate;
      notifyListeners();
    }
  }

  Future<void> ensureGuestToken() async {
    final accessToken = ApiService.authToken;
    if (accessToken == null || accessToken.isEmpty) {
      log('No access token found → logging in as guest...');
    } else {
      log('Guest token already exists.');
    }
  }

  void removeGuest(int index) {
    if (index < 0 || index >= guests.length) return;

    guests.removeAt(index);

    // Handle which guest to expand
    if (currentGuestIndex != null && currentGuestIndex! >= guests.length) {
      currentGuestIndex = guests.isEmpty ? null : guests.length - 1;
    } else {
      int nextIndex = (index >= guests.length) ? guests.length - 1 : index;
      if (nextIndex >= 0 && nextIndex < guests.length) {
        expandGuestForm(nextIndex);
      }
    }

    notifyListeners();
  }

  void processAvailableSlots(List<dynamic> data, Guest guest) {
    guest.morningSlots = [];
    guest.afternoonSlots = [];
    slotToTokenMap = {};

    final RegExp timeRegex = RegExp(r'^\d{1,2}:\d{2}\s[AP]M$');
    final DateTime today = DateTime.now();

    // What calendar day is the user looking at?
    final DateTime baseDate = guest.selectedDate;
    final bool isToday = DateUtils.isSameDay(baseDate, today);

    for (final slot in data) {
      if (slot['booked'] == true) continue; // ① skip booked

      final String rawStart = (slot['starttime'] ?? '').trim();
      if (!timeRegex.hasMatch(rawStart)) continue; // ② malformed string

      // ③ Parse "09:00 AM" → hour & minute, then stamp it on baseDate
      DateTime t;
      try {
        final tmp = _slotParser.parse(rawStart);
        t = DateTime(
          baseDate.year,
          baseDate.month,
          baseDate.day,
          tmp.hour,
          tmp.minute,
        );
      } on FormatException {
        // still safe‑guard
        debugPrint('Bad time from API: $rawStart');
        continue;
      }

      // ④ Hide past slots only when user is on *today*
      if (isToday && t.isBefore(today)) continue;

      // ⑤ Keep it
      slotToTokenMap[rawStart] = slot['tokenno']?.toString() ?? '';

      (t.hour < 12 ? guest.morningSlots : guest.afternoonSlots).add(rawStart);
    }

    notifyListeners();
  }

  final DateFormat _slotParser = DateFormat('hh:mm a', 'en_US');
  String selectedDateForSlot(DateTime? selectedDate) {
    final date = selectedDate ?? DateTime.now();
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> getAvailableSlots(int index, BuildContext context) async {
    final pref = await SharedPreferencesService.prefs;
    final guest = guests[index];

    log('Checking Slot Prerequisites: DoctorID: ${guest.selectedDoctorId}, Date: ${guest.selectedDate}');

    if (guest.selectedDoctorId == null) {
      log('Error: Doctor ID is null. Cannot fetch slots.');
      return; // Exit early if we don't have a doctor ID yet
    }
    String? branchDbptr = pref.getString(kSelectedBranchDbptr);

    if (branchDbptr == null || branchDbptr.isEmpty) {
      return;
    }

    log('Fetching branches with Dbptr: $branchDbptr');

    isAvailableSlotsLoading = true;
    notifyListeners();
    try {
      final slotUrl = Env().getAvailableSlots(
        doctorId: guest.selectedDoctorId!,
        startDate: selectedDateForSlot(guest.selectedDate),
        endDate: selectedDateForSlot(guest.selectedDate),
      );

     log('Slot URL: $slotUrl');
      log('Token: ${pref.getString('token')}');

      final response = await secureFetch(
        method: 'GET',
        endpoint: slotUrl,
        dbPtr: branchDbptr,
      );
      var json = response.data;
      log('Slots Json: $json');
      if (json != null) {
        if (json['status_code'] != 200) {
          availableSlots = [];
          guest.morningSlots = [];
          guest.afternoonSlots = [];

          showSnackBar(context, json['message'] ?? 'Failed to fetch slots');
        } else {
          availableSlotsModel = AvailableSlotsModel.fromJson(json);
          availableSlots = availableSlotsModel.data ?? [];

          processAvailableSlots(json['data'], guest);
        }
      }
    } catch (e, st) {
      log("Error fetching slots: $e\n$st");
      availableSlots = [];
    } finally {
      isAvailableSlotsLoading = false;
      notifyListeners();
    }
  }
}
