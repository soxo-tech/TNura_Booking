// ignore_for_file: unused_import, library_private_types_in_public_api, prefer_const_constructors

import 'dart:convert';
import 'package:booking/core/constants.dart';
import 'dart:math' as math;
import 'package:booking/core/colors.dart';
import 'package:booking/model/add_on_test_model.dart';
import 'package:booking/model/packages_list_model.dart';
import 'package:booking/provider/guests_provider.dart';
import 'package:booking/services/shared_preferences.dart';
import 'package:booking/widgets/guests_textfields.dart';
import 'package:booking/widgets/delete_guest.dart';
import 'package:booking/widgets/refracted_text.dart';
import 'package:booking/widgets/string_extension.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class GuestDetail extends StatefulWidget {
  final bool isAppLoggedIn;
  final Guest guest;
  final int index;
  final GuestProvider guestProvider;

  const GuestDetail({
    super.key,
    required this.isAppLoggedIn,
    required this.guest,
    required this.index,
    required this.guestProvider,
  });

  @override
  _GuestDetailState createState() => _GuestDetailState();
}

class _GuestDetailState extends State<GuestDetail>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late AnimationController _addonController;
  late Animation<double> _addonAnimation;

  bool _isFirstBuild = true;
  String currency = "";
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      if (!mounted) return;
      Provider.of<GuestProvider>(context, listen: false).initRazorpayIfNeeded();
      Provider.of<GuestProvider>(context, listen: false).getAvailableAddOnTest(
          widget.guest.packageTypeValue.toString(), context);
      final pref = await SharedPreferencesService.prefs;
      if (!mounted) return;
      currency = pref.getString("currency") ?? "";
    });
    controller = BottomSheet.createAnimationController(this as TickerProvider);
    controller.duration = Duration(milliseconds: 600);
    _addonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _addonController.value = widget.guestProvider.isAddonExpanded ? 1.0 : 0.0;
    _addonAnimation = CurvedAnimation(
      parent: _addonController,
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    _addonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 0.2,
          color: AppColors.containerBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 15, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.isAppLoggedIn &&
                        widget.guest.step == GuestStep.appointmentScheduling ||
                    widget.guestProvider.continueAsGuest) ...[
                  RefractedText(
                    text:
                        '${widget.guest.firstNameController.text.capitalize()} ${widget.guest.secondNameController.text}',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    textColor: AppColors.packageTextPrimary,
                  ),
                  SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      RefractedText(
                        text: '${widget.guest.ageController.text}, ',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        textColor: AppColors.textFieldHintColor,
                      ),
                      RefractedText(
                        text:
                            (widget.guest.selectedGender?.toUpperCase() == 'M')
                                ? 'Male, '
                                : (widget.guest.selectedGender?.toUpperCase() ==
                                        'F')
                                    ? 'Female, '
                                    : '${widget.guest.selectedGender ?? ''}, ',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        textColor: AppColors.textFieldHintColor,
                      ),
                      RefractedText(
                        text: widget.guest.emailController.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        textColor: AppColors.textFieldHintColor,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      RefractedText(
                        text: widget.guest.countryCode,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        textColor: AppColors.textFieldHintColor,
                      ),
                      SizedBox(
                        width: 2,
                      ),
                      RefractedText(
                        text: widget.guest.phoneController.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        textColor: AppColors.textFieldHintColor,
                      ),
                    ],
                  ),
                ],
                widget.guest.step == GuestStep.confirmation
                    ? SizedBox()
                    : RefractedText(
                        text: widget.guest.selectedPackage,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        textColor: AppColors.textFieldHintColor,
                      ),
                SizedBox(height: 8),
                if (widget.guest.showOtp)
                  _buildOtpInput()
                else if (widget.guest.step == GuestStep.appointmentScheduling)
                  _buildSelectAppointment(widget.index)
                else if (widget.guest.step == GuestStep.confirmation)
                  _buildConfirmationSummary(widget.guestProvider),
              ],
            ),
          ),
        ),
        if (widget.guest.step == GuestStep.confirmation) ...[
          SizedBox(height: 5),
          Consumer<GuestProvider>(
            builder: (context, guestProvider, _) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_isFirstBuild) {
                  _isFirstBuild = false;

                  _addonController.value =
                      guestProvider.isAddonExpanded ? 1.0 : 0.0;

                  return;
                }
                if (guestProvider.isAddonExpanded) {
                  if (!_addonController.isCompleted) {
                    _addonController.forward();
                  }
                } else {
                  if (!_addonController.isDismissed) {
                    _addonController.reverse();
                  }
                }
              });
              return Card(
                elevation: 0.2,
                color: AppColors.containerBackgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 15, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RefractedText(
                        text: 'Add Ons',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        textColor: AppColors.packageTextPrimary,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: RefractedText(
                              text:
                                  'Add specialised add-on packages to complement your main booking.',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              textColor: AppColors.textFieldHintColor,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                            onTap: () {
                              guestProvider.toggleAddonExpand();
                            },
                            child: Transform.translate(
                              offset: Offset(0, -5),
                              child: SvgPicture.asset(
                                guestProvider.isAddonExpanded
                                    ? bookingAssetPath('assets/svg/img_add_on_hide.svg')
                                    : bookingAssetPath('assets/svg/img_show_add_on.svg'),
                                height: 30,
                                width: 30,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizeTransition(
                          sizeFactor: _addonAnimation,
                          axisAlignment: -1.0,
                          child: FadeTransition(
                              opacity: _addonAnimation,
                              child: Column(children: [
                                if (guestProvider.addOnTestModel.data == null)
                                  Padding(
                                    padding: EdgeInsets.all(10),
                                    child: CircularProgressIndicator(),
                                  )
                                else if (guestProvider
                                    .addOnTestModel.data!.isEmpty)
                                  Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Text("No add-ons available"),
                                  )
                                else
                                  ...(guestProvider.addOnTestModel.data ??
                                          <AddOns>[])
                                      .map<Widget>((AddOns addon) {
                                    final isSelected =
                                        guestProvider.isAddonSelected(addon);

                                    String getCaption(AddOns addon) {
                                      final raw = addon.itmOtherdet1;

                                      if (raw == null) return '';

                                      if (raw is Map<String, dynamic>) {
                                        return raw['caption']?.toString() ?? '';
                                      }

                                      if (raw is String) {
                                        return raw;
                                      }

                                      return '';
                                    }

                                    final caption = getCaption(addon);
                                    final price =
                                        addon.irRate ?? addon.itmCost ?? 0;

                                    return GestureDetector(
                                      onTap: () => guestProvider
                                          .toggleAddonSelection(addon),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(height: 10),
                                          Container(
                                            // margin: const EdgeInsets.symmetric(
                                            //     vertical: 2),
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: isSelected
                                                    ? AppColors
                                                        .bookNowButtonColor
                                                    : AppColors.white,
                                                width: 2,
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                RefractedText(
                                                  text: addon.itmDesc ?? '',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  textColor: AppColors
                                                      .guestsOptionalTextColor,
                                                ),
                                                SizedBox(
                                                  height: 2,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Wrap(
                                                        alignment:
                                                            WrapAlignment.start,
                                                        crossAxisAlignment:
                                                            WrapCrossAlignment
                                                                .start,
                                                        spacing: 0,
                                                        runSpacing: 0,
                                                        children: caption
                                                            .replaceAll(
                                                                RegExp(r',\s*'),
                                                                ', ')
                                                            .split(' ')
                                                            .map((word) =>
                                                                RefractedText(
                                                                  text: word
                                                                          .isEmpty
                                                                      ? ''
                                                                      : '$word ',
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  textColor:
                                                                      AppColors
                                                                          .selectedSlotTextColor,
                                                                ))
                                                            .toList(),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Transform.translate(
                                                      offset: Offset(0, -8),
                                                      child: RefractedText(
                                                        text: '$currency$price',
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        textColor: AppColors
                                                            .addOnTestPrice,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 3,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    RefractedText(
                                                      text: '',
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      textColor: AppColors
                                                          .bookNowButtonColor,
                                                    ),
                                                    SvgPicture.asset(
                                                      isSelected
                                                          ? bookingAssetPath('assets/svg/package_selected.svg')
                                                          : bookingAssetPath('assets/svg/package_unselected.svg'),
                                                      height: 20,
                                                      width: 20,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                              ]))),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 5),
          Card(
            elevation: 0.2,
            color: AppColors.containerBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 15, 20, 20),
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
                      color: widget.guestProvider.isCouponApplied
                          ? AppColors.offersAndCouponsBottomsheetColor
                          : AppColors.containerBackgroundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () =>
                              widget.guestProvider.toggleCouponExpand(),
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
                                    scale: Tween<double>(begin: 0.9, end: 1.0)
                                        .animate(animation),
                                    child: FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                  );
                                },
                                child: widget.guestProvider.isCouponApplied
                                    ? Column(
                                        key: ValueKey("success"),
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade50,
                                              borderRadius: BorderRadius.only(
                                                bottomLeft: Radius.circular(8),
                                                bottomRight: Radius.circular(
                                                  8,
                                                ),
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.05),
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
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () => widget
                                                      .guestProvider
                                                      .removeCoupon(),
                                                  child: Text(
                                                    "Remove",
                                                    style: TextStyle(
                                                      color: Colors.red,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    : SizedBox.shrink(
                                        key: ValueKey("empty"),
                                      ),
                              ),
                              if (widget.guestProvider.isCouponExpanded &&
                                  !widget.guestProvider.isCouponApplied)
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
                                            controller: widget.guestProvider
                                                .offersAndCouponController,
                                            labelText: 'Enter coupon code',
                                            textfieldBorderColor: widget
                                                    .guestProvider
                                                    .couponError
                                                    .isNotEmpty
                                                ? AppColors.errorRed
                                                : AppColors
                                                    .textFieldBorderColor,
                                            onChanged: (value) {
                                              if (widget.guestProvider
                                                  .couponError.isNotEmpty) {
                                                widget.guestProvider
                                                    .couponError = '';
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
                                              if (widget
                                                  .guestProvider
                                                  .offersAndCouponController
                                                  .text
                                                  .trim()
                                                  .isEmpty) {
                                                widget.guestProvider
                                                        .couponError =
                                                    "Please enter a coupon code";
                                                setState(() {});
                                                return;
                                              }

                                              if (!widget.guestProvider
                                                  .isCouponValidating) {
                                                widget.guestProvider
                                                    .applyCoupon(context);
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
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  3,
                                                ),
                                              ),
                                              child: Center(
                                                child: widget.guestProvider
                                                        .isCouponValidating
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
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        textColor: AppColors
                                                            .bookNowButtonColor,
                                                      ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (widget
                                        .guestProvider.couponError.isNotEmpty)
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 3),
                                          child: Text(
                                            widget.guestProvider.couponError,
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
          ),
        ],
      ],
    );
  }

  Widget _buildConfirmationSummary(GuestProvider guestProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RefractedText(
              text: 'Appointment Details',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              textColor: AppColors.textFieldHintColor,
            ),
            GestureDetector(
              onTap: () {
                guestProvider.editFromConfirmation(0);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Builder(
                    builder: (context) {
                      final gender =
                          widget.guest.selectedGender?.toLowerCase() ?? '';
                      final pType = int.tryParse(
                            widget.guest.packageTypeValue.toString(),
                          ) ??
                          0;

                      bool isMismatch = ((gender == 'male' || gender == 'm') &&
                              pType != 16) ||
                          ((gender == 'female' || gender == 'f') &&
                              pType != 17);

                      // If there is a mismatch, we hide the edit icon (or return empty space)
                      // so they are forced to click 'Continue' which triggers the validation snackbar
                      return isMismatch
                          ? const SizedBox.shrink()
                          : SvgPicture.asset(
                              bookingAssetPath('assets/svg/edit_slot.svg'),
                              height: 20,
                              width: 20,
                            );
                    },
                  ),
                  SizedBox(width: 5),
                  RefractedText(
                    text: 'Edit',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    textColor: AppColors.bookNowButtonColor,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(
          height: 8,
        ),
        Column(
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
                              '${widget.guest.firstNameController.text.capitalize()} ${widget.guest.secondNameController.text}',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          textColor: AppColors.packageTextPrimary,
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    RefractedText(
                      text: '${widget.guest.ageController.text}, ',
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      textColor: AppColors.textFieldHintColor,
                    ),
                    RefractedText(
                      text: '${widget.guest.selectedGender}  ',
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      textColor: AppColors.textFieldHintColor,
                    ),
                    RefractedText(
                      text: widget.guest.emailController.text,
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
                        text: widget.guest.countryCode,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        textColor: AppColors.selectedSlotTextColor,
                      ),
                      SizedBox(width: 2),
                      RefractedText(
                        text: widget.guest.phoneController.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        textColor: AppColors.selectedSlotTextColor,
                      ),
                    ],
                  ),
                ),
                RefractedText(
                  text: widget.guest.selectedPackage,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  textColor: AppColors.selectedSlotTextColor,
                ),
                RefractedText(
                  text:
                      '${guestProvider.formatSelectedDate(widget.guest.selectedDate)} - ${widget.guest.selectedSlot}',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  textColor: AppColors.guestsOptionalTextColor,
                ),
                SizedBox(height: 5),
                if (guestProvider.selectedAddons.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                    child: Divider(
                      color: AppColors.confirmationBorderColor,
                      thickness: 1.5,
                    ),
                  ),
                ]
              ],
            ),

            // Conditional Divider
            if (guestProvider.guests.length > 1 &&
                0 !=
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
        ),
        if (guestProvider.guests.length > 2)
          Transform.translate(
            offset: Offset(0, -8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  guestProvider.isListExpanded = !guestProvider.isListExpanded;
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
        if (guestProvider.selectedAddons.isNotEmpty) ...[
          const SizedBox(height: 5),
          RefractedText(
            text:
                'Add on Packages: (${guestProvider.selectedAddons.length} selected)',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            textColor: AppColors.textFieldHintColor,
          ),
          const SizedBox(height: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: guestProvider.selectedAddons.map((addon) {
              String extractCaption(dynamic raw) {
                if (raw == null) return '';

                if (raw is Map<String, dynamic>) {
                  return raw['caption']?.toString() ?? '';
                }

                if (raw is String) {
                  final trimmed = raw.trim();

                  if (trimmed.startsWith('{')) {
                    try {
                      final decoded = jsonDecode(trimmed);
                      return decoded['caption']?.toString() ?? '';
                    } catch (_) {
                      return raw;
                    }
                  }

                  return raw;
                }

                return '';
              }

              final caption = extractCaption(addon.itmOtherdet1);
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RefractedText(
                      text: addon.itmDesc ?? '',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      textColor: AppColors.guestsOptionalTextColor,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Wrap(
                            alignment: WrapAlignment.start,
                            crossAxisAlignment: WrapCrossAlignment.start,
                            spacing: 0,
                            runSpacing: 0,
                            children: caption
                                .replaceAll(RegExp(r',\s*'), ', ')
                                .split(' ')
                                .map((word) => RefractedText(
                                      text: word.isEmpty ? '' : '$word ',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      textColor:
                                          AppColors.selectedSlotTextColor,
                                    ))
                                .toList(),
                          ),
                        ),
                        SizedBox(width: 10),
                        RefractedText(
                          text:
                              '$currency${addon.irRate ?? addon.itmCost ?? 0}',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          textColor: AppColors.addOnPriceColor,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            widget.guestProvider.removeAddon(addon);
                          },
                          child: Container(
                            width: 27,
                            height: 27,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.white,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.delete,
                                color: AppColors.primaryDark,
                                size: 17,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  /// OTP Input UI
  Widget _buildOtpInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RefractedText(
          text:
              'We have sent a one-time password (OTP) to your mobile number for verification',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          textColor: AppColors.guestsOptionalTextColor,
        ),
        SizedBox(height: 15),
        if (widget.guest.otpVerified)
          RefractedText(
            text: 'Your phone number has been verified successfully',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            textColor: Colors.green,
          ),
        SizedBox(height: widget.guest.otpVerified ? 13 : 0),

        if (widget.guest.isOtpError)
          RefractedText(
            text: 'Invalid OTP. Please try again.',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            textColor: Colors.red,
          ),

        SizedBox(height: widget.guest.isOtpError ? 13 : 0),

        GuestsTextfield(
          keyboardType: TextInputType.number,
          controller: widget.guest.otpController,
          labelText: 'Enter OTP',
          maxLength: 6,
          otpVerified: widget.guest.otpVerified == true
              ? true
              : null, // Only show check if verified
          textfieldBorderColor: widget.guest.otpVerified == true
              ? Colors.green
              : widget.guest.isOtpError
                  ? Colors.red
                  : AppColors.white,
          onChanged: (value) {
            if (value.length == 6 && widget.guest.otpTimer > 0) {
              widget.guestProvider.verifyGuestOTP(context, widget.index);
            }
          },
        ),
        SizedBox(height: 10),

        /// Resend OTP & Timer
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            InkWell(
              // Disable tap if timer is running
              onTap: widget.guest.canResendOtp
                  ? () => widget.guestProvider.resendOTP(context, widget.index)
                  : null,
              child: RefractedText(
                text: 'Resend',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                textColor: widget.guest.canResendOtp
                    ? AppColors.bookNowButtonColor
                    : AppColors.textFieldBorderColor,
              ),
            ),
            SizedBox(width: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  bookingAssetPath('assets/images/timer.png'),
                  height: 14,
                  width: 14,
                  color: AppColors.textFieldHintColor,
                ),
                SizedBox(width: 4),
                RefractedText(
                  text: widget.guest.otpTimer > 0
                      ? '${widget.guest.otpTimer}s'
                      : '00s',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  textColor: AppColors.textFieldHintColor,
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 5),

        /// Continue Button for OTP Verification

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (widget.guestProvider.guests.length > 1)
              GestureDetector(
                onTap: () {
                  _showDeleteConfirmationDialog(context, widget.index);
                },
                child: RefractedText(
                  text: 'Delete Guest',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  textColor: AppColors.bookNowButtonColor,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Shimmer slotsShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.backgroundBlueLight,
      highlightColor: Colors.white,
      child: Column(
        children: List.generate(
          4, // Number of shimmer placeholders
          (index) => Container(
            width: double.infinity,
            // Reduce height to avoid overflow
            height: 20,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: AppColors.backgroundBlueLight,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectAppointment(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            widget.guestProvider.selectDate(context, index);
          },
          child: IntrinsicWidth(
            child: Container(
              padding: EdgeInsets.fromLTRB(7, 4, 15, 5),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.white),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RefractedText(
                    text: widget.guestProvider.formatSelectedDate(
                      widget.guestProvider.guests[index].selectedDate,
                    ),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    textColor: AppColors.packageTextPrimary,
                  ),
                  Transform.translate(
                    offset: Offset(8, -2),
                    child: SvgPicture.asset(
                      bookingAssetPath('assets/svg/calender.svg'),
                      height: 16.67,
                      width: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Consumer<GuestProvider>(
          builder: (context, provider, child) {
            if (provider.isAvailableSlotsLoading) {
              return slotsShimmer();
            }

            if (provider.guests[index].morningSlots.isEmpty &&
                provider.guests[index].afternoonSlots.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 25, bottom: 20),
                  child: RefractedText(
                    text: 'No Slots Available'.tr(),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    textColor: AppColors.packageTextPrimary,
                  ),
                ),
              );
            }
            return DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorPadding:
                        EdgeInsets.symmetric(horizontal: 2, vertical: 8),
                    labelPadding: EdgeInsets.zero,
                    padding: EdgeInsets.only(bottom: 2),
                    indicatorColor: AppColors.bookNowButtonColor,
                    labelColor: AppColors.packageHeadColor,
                    unselectedLabelColor:
                        AppColors.slotSelectingDeactiveTabColor,
                    dividerColor: Colors.transparent,
                    dividerHeight: 0,
                    tabs: [
                      Tab(text: "MORNING"),
                      Tab(text: "AFTERNOON"),
                    ],
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final maxWidth = constraints.maxWidth;
                      const crossAxisCount = 3;
                      const crossAxisSpacing = 18.0;
                      const mainAxisSpacing = 14.0;
                      const verticalPadding = 16.0;

                      final morningCount =
                          provider.guests[index].morningSlots.length;
                      final afternoonCount =
                          provider.guests[index].afternoonSlots.length;
                      final maxSlotCount =
                          math.max(morningCount, afternoonCount);
                      final rowCount = (maxSlotCount / crossAxisCount)
                          .ceil()
                          .clamp(1, double.infinity)
                          .toInt();
                      final itemWidth =
                          (maxWidth - crossAxisSpacing * (crossAxisCount - 1)) /
                              crossAxisCount;
                      final itemHeight = itemWidth / 2.6;
                      final contentHeight = rowCount * itemHeight +
                          (rowCount - 1) * mainAxisSpacing +
                          verticalPadding;

                      final tabBarView = TabBarView(
                        physics: NeverScrollableScrollPhysics(),
                        children: [
                          _buildTimeSlots(
                            provider.guests[index].morningSlots,
                            index,
                          ),
                          _buildTimeSlots(
                            provider.guests[index].afternoonSlots,
                            index,
                          ),
                        ],
                      );

                      return SizedBox(
                        height: contentHeight,
                        child: tabBarView,
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  ///GridView of slots
  Widget _buildTimeSlots(List<String> slots, int guestIndex) {
    if (slots.isEmpty) {
      return Center(
        child: Text(
          'No Slots Available'.tr(),
          style: TextStyle(fontSize: 14),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.6,
        crossAxisSpacing: 18,
        mainAxisSpacing: 14,
      ),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final guest = widget.guestProvider.guests[guestIndex];
        final slot = slots[index];
        final isSelected = guest.selectedSlot == slot;

        return GestureDetector(
          onTap: () {
            setState(() {
              guest.selectedSlot = slot;
              guest.tokenNo = widget.guestProvider.slotToTokenMap[slot] ?? '';
            });
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(2, 3, 2, 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: isSelected
                    ? AppColors.packageDetailColor
                    : AppColors.containerBackgroundColor,
                width: 1.5,
              ),
              color: isSelected
                  ? AppColors.white
                  : AppColors.containerBackgroundColor,
            ),
            alignment: Alignment.center,
            child: RefractedText(
              text: slot,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              textColor: AppColors.incompleteTextColor,
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => DeleteGuestDialog(
        onDelete: () {
          widget.guestProvider.removeGuest(index);
        },
      ),
    );
  }
}
