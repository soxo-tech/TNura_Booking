class Env {
  //Branches List
  String branchListAPI = '/bookings/branches';
  String bookingFlowBranchersAPI =
      '/branch-master/get-records?includes=address';
  String migrateAccountAPI = '/bookings/migrate-account';
  String packagesListAPI = '/bookings/packages';
  String getPaymentStatus({required String paymentId}) {
    return '/bookings/payment-status?payment_id=$paymentId';
  }

  String applyCoupon = '/bookings/validate-coupon';
  String profileAPI = '/auth/profile';
  String saveOrder = '/bookings/save-order';
  String addGuest = '/accounts/guest-cache/create';
  String proceedPayment = '/bookings/proceed-payment';
  String initiatePaymentV2 = '/bookings/initiate-payment-v2';
  String validateCoupon = '/campgndiscountcoupons/validate';
  //Booking history
  String bookingList = '/bookings/booking-list';
  String resheduleAppointment({required String appointmentId}) {
    return '/bookings/reschedule-booking/$appointmentId';
  }

  String getAddOnTests({required String packageTypeValue}) {
    return '/item/get-all-items/$packageTypeValue';
  }

  String initiateOrder =
      'https://payment-demo.onedesk.app/payment/initiate-order';
  String appointmentDetails = '/bookings/active-appointment';
  String generateOtpForGuestsUser = '/bookings/generate-otp';
  String verifyOtpForGuestUser = '/bookings/verify-otp';
  String getAvailableSlots({
    required int doctorId,
    required String startDate,
    required String endDate,
  }) {
    return '/bookings/available-slots?doctor=$doctorId&start_date=$startDate&end_date=$endDate';
  }
}
