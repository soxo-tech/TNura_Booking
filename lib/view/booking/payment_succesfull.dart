// ignore_for_file: prefer_const_constructors, unnecessary_brace_in_string_interps, must_be_immutable, unnecessary_null_comparison, unnecessary_string_interpolations
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:booking/core/colors.dart';
import 'package:booking/core/constants.dart';
import 'package:booking/provider/guests_provider.dart';
import 'package:booking/services/shared_preferences.dart';
import 'package:booking/widgets/custom_appbar.dart';
import 'package:booking/widgets/refracted_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class PaymentSuccessful extends StatefulWidget {
  String? totalAmount;
  String? transactionId;
  final Map<String, dynamic> appointmentJson;
  PaymentSuccessful(
      {super.key,
      required this.totalAmount,
      required this.transactionId,
      required this.appointmentJson,});

  @override
  State<PaymentSuccessful> createState() => _PaymentSuccessfulState();
}

class _PaymentSuccessfulState extends State<PaymentSuccessful> {
  String? packageDesc;
  String? packageAdr1;
  String? packageAdr2;
  String? packageAdr3;
  String? packagePin;
  late final List<Map<String, dynamic>> _appointments;
  bool showGif = true;
  dynamic staticFormattedDate;
  String selectedCurrency = "";

  @override
  void initState() {
    super.initState();
    // Hide the full‑screen loader after this page’s first frame
    staticFormattedDate =
        DateFormat('dd MMM yyyy, HH:mm:ss').format(DateTime.now());
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<GuestProvider>().setPaymentProcessing(false);
    });
    _appointments = (widget.appointmentJson['data'] as List<dynamic>)
        .cast<Map<String, dynamic>>();

    log("Appointments received: $_appointments");
    log("TransactionId: ${widget.transactionId}");
    log("TotalAmount: ${widget.totalAmount}");
    log("AppointmentJson: ${widget.appointmentJson}");
    Future.delayed(const Duration(seconds: 1), () {
      setState(() => showGif = false);
    });
    _loadPackageAddress();
  }

  Future<void> _loadPackageAddress() async {
    final pref = await SharedPreferencesService.prefs;
    setState(() {
      packageDesc = pref.getString(packageAddressDesc);
      packageAdr1 = pref.getString(packageAddress1);
      packageAdr2 = pref.getString(packageAddress2);
      packageAdr3 = pref.getString(packageAddress3);
      packagePin = pref.getString(packagePincode);
      selectedCurrency = pref.getString(currency) ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    final guestProvider = Provider.of<GuestProvider>(context);
    final String pdfBase64 = _appointments.isNotEmpty
        ? (_appointments.first['preview'] as String? ?? '')
        : '';

    return Scaffold(
      appBar: customAppBar(
        onBack: () {
          guestProvider.clearAddons();
          guestProvider.clearGuestData();
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        title: 'Checkout',
        elevation: 0,
        context: context,
      ),
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
        // Check showBillingUser flag
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: showGif
                  ? Image.asset(
                      bookingAssetPath('assets/gif/appointment_confirmed.gif'),
                      height: 90,
                      width: 90,
                    )
                  : SvgPicture.asset(
                    
                      bookingAssetPath('assets/svg/img_appointment_confirmed.svg'),
                      height: 90,
                      width: 90,
                    ),
            ),
            SizedBox(
              height: 10,
            ),
            const RefractedText(
              text: 'Appointment successfully booked!',
              fontSize: 24,
              fontWeight: FontWeight.w400,
              textColor: AppColors.packageTextPrimary,
            ),
            const SizedBox(height: 10),
            buildTransactionDetails(guestProvider, pdfBase64),
            buildAppointmentDetails(guestProvider),
          ],
        ),
      ),
    );
  }

  Widget buildTransactionDetails(
      GuestProvider guestProvider, String pdfBase64,) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppColors.containerBackgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    bookingAssetPath('assets/svg/img_transaction_succesfull.svg'),
                    height: 16.67,
                    width: 15,
                    colorFilter: ColorFilter.mode(
                      AppColors.guestsOptionalTextColor,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(
                    width: 7,
                  ),
                  const RefractedText(
                    text: 'Transaction Details',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    textColor: AppColors.incompleteTextColor,
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              const RefractedText(
                text: 'Date & Time',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                textColor: AppColors.incompleteTextColor,
              ),
              RefractedText(
                text: staticFormattedDate,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                textColor: AppColors.packageTextPrimary,
              ),
              SizedBox(
                height: 7,
              ),
              const RefractedText(
                text: 'Total Amount Paid',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                textColor: AppColors.incompleteTextColor,
              ),
              RefractedText(
                text: '$selectedCurrency ${widget.totalAmount}',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                textColor: AppColors.packageTextPrimary,
              ),
              SizedBox(
                height: 7,
              ),
              RefractedText(
                text: 'Transaction ID',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                textColor: AppColors.incompleteTextColor,
              ),
              RefractedText(
                text: '${widget.transactionId}',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                textColor: AppColors.packageTextPrimary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildAppointmentDetails(GuestProvider guestProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.containerBackgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    bookingAssetPath('assets/svg/img_transaction_succesfull.svg'),
                    height: 16.67,
                    width: 15,
                    colorFilter: ColorFilter.mode(
                      AppColors.guestsOptionalTextColor,
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(
                    width: 7,
                  ),
                  const RefractedText(
                    text: 'Appointment Details',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    textColor: AppColors.incompleteTextColor,
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _appointments.length,
                itemBuilder: (_, i) {
                  final appt = _appointments[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      color: AppColors.white,
                      padding: const EdgeInsets.fromLTRB(15, 12, 15, 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  RefractedText(
                                    text: '${appt['guest_name']}',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    textColor: AppColors.packageTextPrimary,
                                  ),
                                  SizedBox(
                                    height: 2,
                                  ),
                                  Row(
                                    children: [
                                      RefractedText(
                                        text:
                                            '${appt['gender'] == "M" ? "Male" : "Female"}',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        textColor: AppColors.textFieldHintColor,
                                      ),
                                    ],
                                  ),
                                  if ((appt['email'] ?? '')
                                      .toString()
                                      .isNotEmpty)
                                    RefractedText(
                                      text: appt['email'],
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      textColor: AppColors.textFieldHintColor,
                                    ),
                                  RefractedText(
                                    text: '${appt['mobile']}',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    textColor: AppColors.textFieldHintColor,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Transform.translate(
                            offset: const Offset(0, -2),
                            child: RefractedText(
                              text: appt['package'],
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              textColor: AppColors.packageTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Transform.translate(
                            offset: const Offset(-1, 0),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  bookingAssetPath('assets/svg/slot_calender.svg'),
                                  height: 20,
                                  width: 20,
                                  colorFilter: ColorFilter.mode(
                                    AppColors.textFieldHintColor,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                RefractedText(
                                  text:
                                      '${DateFormat('dd MMM, yyyy').format(DateTime.parse(appt['appointment_date']))} - '
                                      '${appt['appointment_time']}',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  textColor: AppColors.guestsOptionalTextColor,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buttons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Share details button
        GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.only(left: 40, right: 40),
            height: 45,
            width: 230,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: AppColors.white,
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.share_outlined,
                  color: AppColors.addGuestContinueButtonColor,
                ),
                SizedBox(width: 5),
                Center(
                  child: RefractedText(
                    text: 'SHARE DETAILS',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    textColor: AppColors.addGuestContinueButtonColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        /// Download confirmation button
        GestureDetector(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.only(left: 40, right: 40),
            height: 45,
            width: 291,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3),
              color: AppColors.addGuestContinueButtonColor,
            ),
            child: const Row(
              children: [
                Icon(Icons.file_download_outlined, color: AppColors.white),
                SizedBox(width: 5),
                Center(
                  child: RefractedText(
                    text: 'DOWNLOAD CONFIRMATION',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    textColor: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
                        child: const Center(
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

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

class DownloadConfirmationButton extends StatefulWidget {
  final String base64Pdf; // pass the base64 from appointment detail
  const DownloadConfirmationButton({required this.base64Pdf, super.key});

  @override
  State<DownloadConfirmationButton> createState() =>
      _DownloadConfirmationButtonState();
}

class _DownloadConfirmationButtonState
    extends State<DownloadConfirmationButton> {
  bool _isDownloading = false;

  Future<void> _downloadAndOpenPdf() async {
    if (widget.base64Pdf.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No PDF data to download.')),
      );
      return;
    }

    setState(() => _isDownloading = true);

    try {
      final cleaned = widget.base64Pdf.contains(',')
          ? widget.base64Pdf.split(',').last
          : widget.base64Pdf;

      final bytes = base64Decode(base64.normalize(cleaned));
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/confirmation.pdf');
      await file.writeAsBytes(bytes, flush: true);

      final result = await OpenFilex.open(file.path);
      debugPrint('Open result: ${result.type}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open PDF: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = _isDownloading ? 'Downloading …' : 'Download confirmation';

    return GestureDetector(
      onTap: _isDownloading ? null : _downloadAndOpenPdf,
      child: AnimatedContainer(
        height: 32,
        width: 184,
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.selectLocationButtonColor,
          borderRadius: BorderRadius.circular(25),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isDownloading) ...[
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(AppColors.white),
                ),
              ),
              const SizedBox(width: 8),
            ],
            RefractedText(
              text: text,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              textColor: AppColors.packageTextPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

