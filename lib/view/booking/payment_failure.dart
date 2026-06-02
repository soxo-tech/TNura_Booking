// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:developer';
import 'package:booking/core/constants.dart';
import 'package:booking/core/colors.dart';
import 'package:booking/main.dart';
import 'package:booking/provider/guests_provider.dart';
import 'package:booking/widgets/custom_appbar.dart';
import 'package:booking/widgets/refracted_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class PaymentFailure extends StatefulWidget {
  final String name;
  final int amount;
  final String? orderId;
  const PaymentFailure({
    super.key,
    required this.name,
    required this.amount,
    this.orderId,
  });

  @override
  State<PaymentFailure> createState() => _PaymentFailureState();
}

class _PaymentFailureState extends State<PaymentFailure> {
  bool loggedInFlag = false;

  @override
  void initState() {
    super.initState();
    // Hide the full‑screen loader after this page’s first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GuestProvider>().setPaymentProcessing(false);
      loggedInFlag = isAppLoggedIn;
      log('IsAppLoggedIn: $loggedInFlag');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(
        onBack: () {
          _showBackArrowDialog(context);
        },
        title: 'Checkout',

        // leading: ,
        elevation: 0,
        context: context,
      ),
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RefractedText(
              text: 'Payment failed!',
              fontSize: 24,
              fontWeight: FontWeight.w400,
              textColor: AppColors.packageTextPrimary,
            ),
            const SizedBox(height: 3),
            Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: AppColors.containerBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: AppColors.white,),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              bookingAssetPath('assets/svg/img_payment_failed.svg'),
                              height: 26.67,
                              width: 26.67,
                              colorFilter: ColorFilter.mode(
                                AppColors.paymentFailedIconColor,
                                BlendMode.srcIn,
                              ),
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              child: RefractedText(
                                overflow: TextOverflow.fade,
                                textAlign: TextAlign.start,
                                text:
                                    'Your appointment could not be confirmed. Please retry payment to book your screening. ',
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                textColor: AppColors.paymentFailedTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(13, 3, 13, 3),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: AppColors.selectLocationButtonColor,),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SvgPicture.asset(
                              bookingAssetPath('assets/svg/img_pay_at_the_center.svg'),
                              width: 12,
                              height: 12,
                              colorFilter: ColorFilter.mode(
                                AppColors.packageTextPrimary,
                                BlendMode.srcIn,
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            RefractedText(
                              text: 'Pay at the centre',
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              textColor: AppColors.packageTextPrimary,
                            ),
                          ],
                        ),
                      ),
                    ],),),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  void _showBackArrowDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          content: Column(
            mainAxisSize: MainAxisSize
                .min, // Ensures the column takes only required space
            children: [
              const RefractedText(
                textAlign: TextAlign.center,
                text: 'Want to go back? You might lose your progress',
                fontSize: 20,
                fontWeight: FontWeight.w400,
                textColor: AppColors.packageTextPrimary,
              ),
              const SizedBox(
                height: 10,
              ),
              const RefractedText(
                textAlign: TextAlign.center,
                text:
                    'Going back will remove your current selections. Make sure you'
                    're ready before continuing.',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                textColor: AppColors.packageTextPrimary,
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
                        decoration: BoxDecoration(
                          color: AppColors.bookNowButtonColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Center(
                          child: RefractedText(
                            textAlign: TextAlign.center,
                            text: 'Stay and continue',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            textColor: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
                        decoration: BoxDecoration(
                          color: AppColors.addNewGuestsButtonColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: RefractedText(
                            textAlign: TextAlign.center,
                            text: 'Go back anyway',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            textColor: AppColors.guestsOptionalTextColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
