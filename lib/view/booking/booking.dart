// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:booking/core/constants.dart';

import 'package:booking/core/colors.dart';
import 'package:booking/main.dart';
import 'package:booking/provider/guests_provider.dart';
import 'package:booking/provider/login_provider.dart';
import 'package:booking/provider/package_provider.dart';
import 'package:booking/services/shared_preferences.dart';
import 'package:booking/widgets/guest_detail.dart';
import 'package:booking/widgets/guests_textfields.dart';
import 'package:booking/widgets/new_guest_form.dart';
import 'package:booking/widgets/custom_appbar.dart';
import 'package:booking/widgets/refracted_button.dart';
import 'package:booking/widgets/refracted_text.dart';
import 'package:booking/widgets/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class AddGuestsDetail extends StatefulWidget {
  const AddGuestsDetail({super.key});

  @override
  State<AddGuestsDetail> createState() => _AddGuestsDetailState();
}

class _AddGuestsDetailState extends State<AddGuestsDetail>
    with TickerProviderStateMixin {
  late AnimationController offersAndCouponsController;
  late AnimationController viewDetailsController;
  late AnimationController referalCodeController;
  LoginProvider loginProvider = LoginProvider();
  bool loggedInFlag = false;
  String currency = "";
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      if (!mounted) return;
      final gp = Provider.of<GuestProvider>(context, listen: false);
      final pp = Provider.of<PackagesProvider>(context, listen: false);

      pp.setBookingLoading(false); // Stop the button spinner

      final pref = await SharedPreferencesService.prefs;
      if (!mounted) return;
      loggedInFlag = isAppLoggedIn;
      currency = pref.getString("currency") ?? "";
      if (loggedInFlag) {
        if (gp.guests.isEmpty) {
          await gp.initializeGuest(context, loggedInFlag, forceRefresh: true);
        } else {
          // Just ensure the profile is filled if it was empty
          await gp.initializeGuest(context, loggedInFlag);
        }
      } else {
        if (gp.guests.isEmpty) {
          await gp.initializeGuest(context, loggedInFlag);
        }
      }

      // Final safety check to kill any stuck loaders
      gp.setInitialLoading(false);
    });
    // Animation controllers
    offersAndCouponsController = BottomSheet.createAnimationController(
      this as TickerProvider,
    );
    offersAndCouponsController.duration = Duration(milliseconds: 600);

    referalCodeController = BottomSheet.createAnimationController(
      this as TickerProvider,
    );
    referalCodeController.duration = Duration(milliseconds: 600);

    viewDetailsController = BottomSheet.createAnimationController(
      this as TickerProvider,
    );
    viewDetailsController.duration = Duration(milliseconds: 600);
  }

  bool isGestureNavigation(BuildContext context) {
    final bottom = MediaQuery.of(context).viewPadding.bottom;
    return bottom < 30;
  }

  @override
  void dispose() {
    offersAndCouponsController.dispose();
    viewDetailsController.dispose();
    referalCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GuestProvider>(
      builder: (context, guestProvider, _) {
        return PopScope(
          canPop: false, // Prevents automatic pop
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            guestProvider.handleBackNavigation(
              context,
              isAppLoggedIn: loggedInFlag,
            );
          },
          child: Scaffold(
            // bottomNavigationBar: allGuestsReachedPackageDetail(guestProvider.guests) ||
            //         guestProvider.isReturningFromBillingUser
            //     ? ,
            // : SizedBox(),
            backgroundColor: AppColors.white,
            appBar: customAppBar(
              onBack: () => guestProvider.handleBackNavigation(
                context,
                isAppLoggedIn: loggedInFlag,
              ),
              title: 'Checkout',
              // leading: ,
              elevation: 1,
              context: context,
            ),
            extendBody: true,
            bottomNavigationBar: guestProvider.guests.isNotEmpty
                ? guestProvider.isPaymentProcessing ||
                          guestProvider.isFetchingPaymentDetails
                      ? SizedBox()
                      : bottomTab(
                          guestProvider,
                          guestProvider.guests.length - 1,
                          loggedInFlag,
                        )
                : SizedBox.shrink(),
            body: SizedBox.expand(
              child: Stack(
                children: [
                  guestProvider.isMembersLoading
                      ? Center(child: Loader())
                      : SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(20, 25, 20, 25),
                          // Check showBillingUser flag
                          child:
                              // guestProvider.showConfirmAppointmentDetails
                              //     ? buildAppointmentDetails(guestProvider)
                              //     :
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  guestProvider.guests.isNotEmpty &&
                                          (guestProvider.guests[0].step ==
                                              GuestStep.appointmentScheduling)
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                            left: 5,
                                            right: 5,
                                          ),
                                          child: RefractedText(
                                            text:
                                                'Choose a time that works for you',
                                            fontSize: 22,
                                            fontWeight: FontWeight.w400,
                                            textColor:
                                                AppColors.packageTextPrimary,
                                          ),
                                        )
                                      : guestProvider.guests.isNotEmpty &&
                                            (guestProvider.guests[0].step ==
                                                GuestStep.confirmation)
                                      ? RefractedText(
                                          text:
                                              'Almost done — confirm details and pay',
                                          fontSize: 24,
                                          fontWeight: FontWeight.w400,
                                          textColor:
                                              AppColors.packageTextPrimary,
                                        )
                                      : SizedBox(),
                                  SizedBox(height: 10),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: guestProvider.guests.length,
                                    itemBuilder: (context, index) {
                                      final guest = guestProvider.guests[index];

                                      // Logic: Show Form ONLY if we are in the 'addGuest' step AND continueAsGuest is true.
                                      // Otherwise, show GuestDetail (which handles OTP and Confirmation).
                                      if (guestProvider.continueAsGuest &&
                                          guest.step == GuestStep.addGuest) {
                                        return GuestForm(
                                          index: index,
                                          guest: guest,
                                        );
                                      } else {
                                        return GuestDetail(
                                          isAppLoggedIn: loggedInFlag,
                                          guestProvider: guestProvider,
                                          index: index,
                                          guest: guest,
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                        ),
                  // Payment processing overlay
                  if (guestProvider.isPaymentProcessing)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.5),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text(
                                "Processing your payment...",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Confirming appointment overlay
                  if (guestProvider.isFetchingPaymentDetails)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.5),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text(
                                "Confirming your appointment...",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildAppointmentDetails(GuestProvider guestProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RefractedText(
          text: 'Almost done — confirm details and pay',
          fontSize: 24,
          fontWeight: FontWeight.w400,
          textColor: AppColors.packageTextPrimary,
        ),
        SizedBox(height: 10),
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppColors.containerBackgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.fromLTRB(20, 15, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RefractedText(
                text: 'Appointment Details',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                textColor: AppColors.textFieldHintColor,
              ),
              SizedBox(height: 8),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: Alignment.topCenter,
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: guestProvider.isListExpanded
                      ? guestProvider.guests.length
                      : guestProvider.guests.length > 2
                      ? 2
                      : guestProvider.guests.length,
                  itemBuilder: (context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main content for each guest
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Transform.translate(
                                      offset: Offset(0, -1),
                                      child: SvgPicture.asset(
                                        bookingAssetPath('assets/svg/img_guest.svg'),
                                        colorFilter: ColorFilter.mode(
                                          AppColors.packageTextPrimary,
                                          BlendMode.srcIn,
                                        ),
                                        height: 11,
                                        width: 11,
                                      ),
                                    ),
                                    SizedBox(width: 9),
                                    RefractedText(
                                      text:
                                          '${guestProvider.guests[index].firstNameController.text.capitalize()} ${guestProvider.guests[index].secondNameController.text}',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      textColor: AppColors.packageTextPrimary,
                                    ),
                                  ],
                                ),
                                Builder(
                                  builder: (context) {
                                    final guest = guestProvider.guests[index];
                                    final gender =
                                        guest.selectedGender?.toLowerCase() ??
                                        '';
                                    final pType =
                                        int.tryParse(
                                          guest.packageTypeValue.toString(),
                                        ) ??
                                        0;

                                    bool isMismatch =
                                        ((gender == 'male' || gender == 'm') &&
                                            pType != 16) ||
                                        ((gender == 'female' ||
                                                gender == 'f') &&
                                            pType != 17);

                                    // If there is a mismatch, we hide the edit icon (or return empty space)
                                    // so they are forced to click 'Continue' which triggers the validation snackbar
                                    return isMismatch
                                        ? const SizedBox.shrink()
                                        : GestureDetector(
                                            onTap: () {
                                              guestProvider
                                                  .editFromConfirmation(index);
                                            },
                                            child: SvgPicture.asset(
                                              bookingAssetPath('assets/svg/edit_slot.svg'),
                                              height: 18,
                                              width: 18,
                                            ),
                                          );
                                  },
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                RefractedText(
                                  text:
                                      '${guestProvider.guests[index].ageController.text}, ',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  textColor: AppColors.textFieldHintColor,
                                ),
                                RefractedText(
                                  text:
                                      '${guestProvider.guests[index].selectedGender}  ',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  textColor: AppColors.textFieldHintColor,
                                ),
                                RefractedText(
                                  text: guestProvider
                                      .guests[index]
                                      .emailController
                                      .text,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  textColor: AppColors.selectedSlotTextColor,
                                ),
                              ],
                            ),
                            Transform.translate(
                              offset: Offset(0, -2),
                              child: Row(
                                children: [
                                  RefractedText(
                                    text:
                                        guestProvider.guests[index].countryCode,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    textColor: AppColors.selectedSlotTextColor,
                                  ),
                                  SizedBox(width: 2),
                                  RefractedText(
                                    text: guestProvider
                                        .guests[index]
                                        .phoneController
                                        .text,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    textColor: AppColors.selectedSlotTextColor,
                                  ),
                                ],
                              ),
                            ),
                            RefractedText(
                              text: guestProvider.guests[index].selectedPackage,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              textColor: AppColors.selectedSlotTextColor,
                            ),
                            RefractedText(
                              text:
                                  '${guestProvider.formatSelectedDate(guestProvider.guests[index].selectedDate)} - ${guestProvider.guests[index].selectedSlot}',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              textColor: AppColors.guestsOptionalTextColor,
                            ),
                          ],
                        ),

                        // Conditional Divider
                        if (guestProvider.guests.length > 1 &&
                            index !=
                                (guestProvider.isListExpanded
                                        ? guestProvider.guests.length
                                        : (guestProvider.guests.length > 2
                                              ? 2
                                              : guestProvider.guests.length)) -
                                    1)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(2, 7, 2, 5),
                            child: Divider(
                              color: Colors.grey[300],
                              thickness: 1,
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              if (guestProvider.guests.length > 2)
                Transform.translate(
                  offset: Offset(0, -8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        guestProvider.isListExpanded =
                            !guestProvider.isListExpanded;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          guestProvider.isListExpanded
                              ? "Show less"
                              : "Show all guests",
                          style: TextStyle(
                            color: AppColors.bookNowButtonColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(width: 5),
                        Icon(
                          guestProvider.isListExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: AppColors.bookNowButtonColor,
                          size: 19,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 2),
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppColors.containerBackgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: EdgeInsets.fromLTRB(20, 15, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RefractedText(
                text: 'Savings Corner',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                textColor: AppColors.textFieldHintColor,
              ),
              SizedBox(height: 8),

              // OUTER COUPON CONTAINER
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: guestProvider.isCouponApplied
                      ? AppColors.offersAndCouponsBottomsheetColor
                      : AppColors.containerBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ------- HEADER (Tap to Expand/Collapse) ----------
                    GestureDetector(
                      onTap: () => guestProvider.toggleCouponExpand(),
                      child: Container(
                        padding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              bookingAssetPath('assets/svg/img_offers_and_coupons.svg'),
                              height: 18,
                              width: 18,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: RefractedText(
                                text: "Offers and Coupons",
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                textColor: AppColors.packageTextPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // -------- EXPAND AREA --------
                    AnimatedSize(
                      duration: Duration(milliseconds: 300),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AnimatedSwitcher(
                            duration: Duration(milliseconds: 300),
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(
                                scale: Tween<double>(
                                  begin: 0.9,
                                  end: 1.0,
                                ).animate(animation),
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              );
                            },
                            child: guestProvider.isCouponApplied
                                ? Column(
                                    key: ValueKey("success"),
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade50,
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(8),
                                            bottomRight: Radius.circular(8),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.05,
                                              ),
                                              blurRadius: 1,
                                              spreadRadius: 0.5,
                                              offset: Offset(0, 1),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "Coupon Applied Successfully!",
                                                style: TextStyle(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () =>
                                                  guestProvider.removeCoupon(),
                                              child: Text(
                                                "Remove",
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : SizedBox.shrink(key: ValueKey("empty")),
                          ),
                          if (guestProvider.isCouponExpanded &&
                              !guestProvider.isCouponApplied)
                            Column(
                              children: [
                                SizedBox(height: 12),
                                Row(
                                  children: [
                                    // SHAKE ANIMATION ON INVALID
                                    Expanded(
                                      flex: 5,
                                      child: GuestsTextfield(
                                        keyboardType: TextInputType.text,
                                        controller: guestProvider
                                            .offersAndCouponController,
                                        labelText: 'Enter coupon code',
                                        textfieldBorderColor:
                                            guestProvider.couponError.isNotEmpty
                                            ? AppColors.errorRed
                                            : AppColors.textFieldBorderColor,
                                        onChanged: (value) {
                                          if (guestProvider
                                              .couponError
                                              .isNotEmpty) {
                                            guestProvider.couponError = '';
                                            setState(() {});
                                          }
                                        },
                                      ),
                                    ),

                                    SizedBox(width: 10),

                                    Expanded(
                                      flex: 2,
                                      child: GestureDetector(
                                        onTap: () {
                                          if (guestProvider
                                              .offersAndCouponController
                                              .text
                                              .trim()
                                              .isEmpty) {
                                            guestProvider.couponError =
                                                "Please enter a coupon code";
                                            setState(() {});
                                            return;
                                          }

                                          if (!guestProvider
                                              .isCouponValidating) {
                                            guestProvider.applyCoupon(context);
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.fromLTRB(
                                            5,
                                            9,
                                            5,
                                            9,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.white,
                                            borderRadius: BorderRadius.circular(
                                              3,
                                            ),
                                          ),
                                          child: Center(
                                            child:
                                                guestProvider.isCouponValidating
                                                ? SizedBox(
                                                    height: 18,
                                                    width: 18,
                                                    child:
                                                        CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                        ),
                                                  )
                                                : RefractedText(
                                                    text: 'APPLY CODE',
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    textColor: AppColors
                                                        .bookNowButtonColor,
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (guestProvider.couponError.isNotEmpty)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 3),
                                      child: Text(
                                        guestProvider.couponError,
                                        style: TextStyle(
                                          color: AppColors.errorRed,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  ///widget which returns the bottomtab with price details and continue button
  Widget bottomTab(GuestProvider provider, int index, bool loggedIn) {
    bool shouldShowTimer =
        provider.remainingTime.inSeconds > 0 &&
        provider.guests.any((guest) => guest.selectedSlot != null);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (shouldShowTimer)
          Container(
            height: 42,
            padding: EdgeInsets.fromLTRB(25, 3, 25, 3),
            color: AppColors.sessionTimeoutContainerColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RefractedText(
                  text: 'Session timeout in',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  textColor: AppColors.sessionTextColor,
                ),
                Row(
                  children: [
                    Transform.translate(
                      offset: Offset(0, -1),
                      child: Image.asset(
                        bookingAssetPath('assets/images/timer.png'),
                        height: 18,
                        width: 18,
                        color: AppColors.sessionTextColor,
                      ),
                    ),
                    SizedBox(width: 4),
                    RefractedText(
                      text:
                          '${provider.remainingTime.inMinutes}:${(provider.remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      textColor: AppColors.sessionTextColor,
                    ),
                  ],
                ),
              ],
            ),
          ),

        /// Bottom tab content
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
          decoration: BoxDecoration(
            borderRadius: shouldShowTimer
                ? BorderRadius.circular(0)
                : BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
            color: AppColors.bottomTabColor,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RefractedText(
                    text: provider.couponValue == 0
                        ? '$currency ${provider.totalAmount}'
                        : '$currency ${provider.payableAmount}',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    textColor: AppColors.white,
                  ),
                  SizedBox(height: 2),
                  GestureDetector(
                    onTap: () {
                      viewDetailsBottomSheet(context, provider);
                    },
                    child: const RefractedText(
                      decoration: TextDecoration.underline,
                      text: 'View details',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      textColor: AppColors.white,
                      decorationColor: AppColors.white,
                    ),
                  ),
                ],
              ),

              /// Continue Button
              GestureDetector(
                onTap: () {
                  // Prevent multiple taps if already loading
                  if (!provider.isBillingLoading) {
                    provider.handleContinue(context, 0, loggedIn);
                  }
                },
                child: Container(
                  width: 139,
                  height: 38,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: AppColors.selectLocationButtonColor,
                  ),
                  child: Center(
                    child: AnimatedCrossFade(
                      // The loader appears when isBillingLoading is true
                      secondChild: const Loader(
                        scale: 0.6,
                      ), // Scaled down to fit height 38
                      crossFadeState: provider.isBillingLoading
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 300),
                      firstChild: RefractedText(
                        text: 'Continue',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        textColor: AppColors.packageTextPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  ///view/price details Bottomsheet
  Future<dynamic> viewDetailsBottomSheet(
    BuildContext context,
    GuestProvider provider,
  ) {
    return showModalBottomSheet(
      transitionAnimationController: viewDetailsController,
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return FractionallySizedBox(
              // heightFactor: 0.88, // 88% of screen height
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// **Main Scrollable Content**
                  Flexible(
                    fit: FlexFit.loose,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// **Row with Title and Close Icon**
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              RefractedText(
                                text: 'Price Details',
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                textColor: AppColors.packageTextPrimary,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: SvgPicture.asset(
                                  bookingAssetPath('assets/svg/close_icon.svg'),
                                  height: 24,
                                  width: 24,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 15),
                          provider.totalAmount == 0
                              ? Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.fromLTRB(
                                      18,
                                      12,
                                      20,
                                      15,
                                    ),
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.05),
                                          blurRadius: 1,
                                          spreadRadius: 0.5,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                      color: AppColors.backgroundBlueLight,
                                      borderRadius: BorderRadius.circular(9),
                                    ),
                                    child: RefractedText(
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.fade,
                                      text:
                                          'Add packages to view price details',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                      textColor:
                                          AppColors.selectedSlotTextColor,
                                    ),
                                  ),
                                )
                              : Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.fromLTRB(18, 12, 20, 5),
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 1,
                                        spreadRadius: 0.5,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                    color: AppColors.backgroundBlueLight,
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      RefractedText(
                                        text: 'Packages',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        textColor: AppColors.packageTextPrimary,
                                      ),
                                      const SizedBox(height: 7),

                                      /// ListView.builder with guests and their selected package
                                      ListView.builder(
                                        padding: EdgeInsets.zero,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: provider
                                            .guests
                                            .length, // Assuming provider.guests is a list
                                        itemBuilder: (context, index) {
                                          return Container(
                                            color:
                                                AppColors.backgroundBlueLight,
                                            padding: EdgeInsets.fromLTRB(
                                              0,
                                              5,
                                              0,
                                              8,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Transform.translate(
                                                        offset: const Offset(
                                                          0,
                                                          -2,
                                                        ),
                                                        child: RefractedText(
                                                          overflow:
                                                              TextOverflow.fade,
                                                          text: provider
                                                              .guests[index]
                                                              .selectedPackage,
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          textColor: AppColors
                                                              .selectedSlotTextColor,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 10),
                                                    RefractedText(
                                                      text:
                                                          '$currency${provider.guests[index].selectedPackageRate}',
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      textColor: AppColors
                                                          .addOnPriceColor,
                                                    ),
                                                  ],
                                                ),
                                                Transform.translate(
                                                  offset: Offset(0, -2),
                                                  child: Row(
                                                    children: [
                                                      RefractedText(
                                                        text: 'x1',
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        textColor: AppColors
                                                            .selectedSlotTextColor,
                                                      ),
                                                      // SVG Icon widget
                                                      SvgPicture.asset(
                                                        bookingAssetPath('assets/svg/price_details.svg'),
                                                        height: 18,
                                                        width: 18,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                          SizedBox(height: 10),
                          provider.couponValue == 0
                              ? SizedBox()
                              : Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.fromLTRB(18, 12, 20, 15),
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.05),
                                        blurRadius: 1,
                                        spreadRadius: 0.5,
                                        offset: Offset(0, 1),
                                      ),
                                    ],
                                    color: AppColors.backgroundBlueLight,
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      RefractedText(
                                        text: 'Offers & Discounts',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        textColor: AppColors.packageTextPrimary,
                                      ),
                                      const SizedBox(height: 7),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Transform.translate(
                                              offset: const Offset(0, -2),
                                              child: RefractedText(
                                                overflow: TextOverflow.fade,
                                                text: provider
                                                    .offersAndCouponController
                                                    .text,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w400,
                                                textColor: AppColors
                                                    .selectedSlotTextColor,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          RefractedText(
                                            text: provider.couponType == 'A'
                                                ? '-  ${provider.couponValue}'
                                                : '-  ${provider.couponValue}%',
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            textColor:
                                                AppColors.selectedSlotTextColor,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                          if (provider.selectedAddons.isNotEmpty) ...[
                            SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.fromLTRB(18, 12, 20, 5),
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 1,
                                    spreadRadius: 0.5,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                                color: AppColors.backgroundBlueLight,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RefractedText(
                                    text: 'Add Ons',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    textColor: AppColors.packageTextPrimary,
                                  ),
                                  const SizedBox(height: 7),
                                  ...provider.selectedAddons.map((addon) {
                                    final price =
                                        addon.irRate ?? addon.itmCost ?? 0;

                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 6),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: RefractedText(
                                              text: addon.itmDesc ?? '',
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              textColor: AppColors
                                                  .selectedSlotTextColor,
                                              overflow: TextOverflow.fade,
                                            ),
                                          ),
                                          RefractedText(
                                            text: '$currency$price',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            textColor:
                                                AppColors.addOnPriceColor,
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  /// **Fixed Bottom Button**
                  Container(
                    padding: EdgeInsets.fromLTRB(25, 10, 25, 10),
                    height: 88,
                    width: double.infinity,
                    color: AppColors.addNewGuestsButtonColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RefractedText(
                          text: 'Total Price',
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          textColor: AppColors.packageTextPrimary,
                        ),
                        provider.totalAmount == 0
                            ? RefractedText(
                                text: '$currency 0',
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                textColor: AppColors.packageTextPrimary,
                              )
                            : provider.totalAmount == 0
                            ? RefractedText(
                                text: '$currency 0',
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                textColor: AppColors.packageTextPrimary,
                              )
                            : provider.couponValue == 0
                            ? RefractedText(
                                text: '$currency ${provider.totalAmount}',
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                textColor: AppColors.packageTextPrimary,
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  RefractedText(
                                    text:
                                        '$currency ${provider.payableAmount}',
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    textColor: AppColors.packageTextPrimary,
                                  ),
                                  SizedBox(height: 1),
                                  RefractedText(
                                    decoration: TextDecoration.lineThrough,
                                    text:
                                        '$currency ${provider.totalAmount}',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    textColor: AppColors.packageTextPrimary,
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
