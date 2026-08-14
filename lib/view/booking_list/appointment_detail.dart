// ignore_for_file: deprecated_member_use, prefer_const_constructors, unnecessary_null_comparison, unused_field, prefer_const_literals_to_create_immutables
import 'package:booking/core/constants.dart';
import 'package:booking/core/extensions.dart';
import 'package:booking/model/booking_history_model.dart';
import 'package:booking/provider/guests_provider.dart';
import 'package:booking/provider/login_provider.dart';
import 'package:booking/provider/package_provider.dart';
import 'package:booking/services/navigation_services.dart';
import 'package:booking/view/booking/booking.dart';
import 'package:booking/widgets/appointment_detail_action.dart';
import 'package:booking/widgets/appointment_history_shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/colors.dart';
import '../../widgets/refracted_text.dart';

class AppointmentDetail extends StatefulWidget {
  final dynamic bookingId;
  final String packageName;
  final String? packageImage;
  final String? packageBackground;
  final dynamic packageDrId;
  final List<AddOnPackageDetails>? addonPackageList;
  const AppointmentDetail({
    super.key,
    required this.bookingId,
    required this.packageName,
    this.packageImage,
    this.packageBackground,
    this.packageDrId,
    this.addonPackageList,
  });

  @override
  State<AppointmentDetail> createState() => _AppointmentDetailState();
}

class _AppointmentDetailState extends State<AppointmentDetail>
    with TickerProviderStateMixin {
  LoginProvider loginProvider = LoginProvider();
  GuestProvider guestProvider = GuestProvider();
  List<AppointmentDetailAction> actions = [];
  @override
  void initState() {
    actions = [
      AppointmentDetailAction(
        title: 'Reschedule',
        icon: bookingAssetPath('assets/svg/img_Appointment_date.svg'),
        backgroundColor: AppColors.calenderbackgroundColor,
        iconColor: AppColors.textFieldHintColor,
      ),

      // AppointmentDetailAction(
      //   title: 'Download Receipt',
      //   icon: Icons.file_download,
      // ),
      AppointmentDetailAction(
        title: 'Cancel',

        icon: bookingAssetPath('assets/svg/img_cancel_appointment.svg'),

        backgroundColor: AppColors.cancelBackgroundColor,
        iconColor: AppColors.paymentFailedIconColor,
      ),
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    loginProvider = Provider.of<LoginProvider>(context);
    guestProvider = Provider.of<GuestProvider>(context);

    final packagesProvider = context.watch<PackagesProvider>();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 244, 248),
      appBar: AppBar(
        toolbarHeight: kToolbarHeight + 20,
        leading: IconButton(
          onPressed: () {
            pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        automaticallyImplyLeading: false,
        title: RefractedText(
          text: 'Appointment'.tr(),
          textColor: AppColors.primaryDark,
        ),
      ),
      body: Consumer<LoginProvider>(
        builder: (context, provider, child) {
          final booking = provider.bookinghistoryModel?.result?.firstWhere(
            (b) => b.daId == widget.bookingId,
          );
          final results = provider.bookinghistoryModel?.result;

          final updatedBooking = results?.firstWhere(
            (b) => b.daId == widget.bookingId,
            orElse: () => booking ?? widget.bookingId,
          );
          final isLoading =
              provider.isBookingLoading ||
              packagesProvider.isPackagesListLoading ||
              packagesProvider.packagesList.isEmpty;

          final hasError = provider.isBookingFailed || results == null;
          final isEmpty = results != null && results.isEmpty;
          DateTime dt = updatedBooking!.daDate!;

          // Reschedule/Cancel are only offered up to 2 days before the
          // appointment date (e.g. an appointment on Jan 10th can be
          // rescheduled/cancelled through Jan 8th, and not on/after Jan 9th).
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final appointmentDate = DateTime(dt.year, dt.month, dt.day);
          final modificationCutoff = appointmentDate.subtract(
            const Duration(days: 2),
          );
          final canModifyBooking = !today.isAfter(modificationCutoff);
          final visibleActions = canModifyBooking
              ? actions
              : <AppointmentDetailAction>[];

          final formattedDate = loginProvider.formatHistoryDate(dt);
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: isLoading
                ? const AppointmentHistoryShimmer()
                : hasError || isEmpty
                ? const SizedBox()
                : SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RefractedText(
                          textColor: AppColors.packageTextPrimary,
                          text: widget.packageName,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.only(top: 20),
                          height: 160,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(8),
                            ),
                            gradient: widget.packageBackground?.parseGradient(),
                          ),
                          child: CachedNetworkImage(
                            imageUrl: widget.packageImage ?? '',
                            height: double.infinity,
                            fit: BoxFit.fitHeight,
                          ),
                        ),
                        SizedBox(height: 10),
                        widget.addonPackageList != null &&
                                widget.addonPackageList!.isNotEmpty
                            ? RefractedText(
                                textColor: AppColors.packageTextPrimary,
                                text: 'Add-Ons Package',
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                textAlign: TextAlign.center,
                              )
                            : const SizedBox(),
                        SizedBox(height: 10),
                        widget.addonPackageList != null &&
                                widget.addonPackageList!.isNotEmpty
                            ? Container(
                                padding: const EdgeInsets.fromLTRB(
                                  15,
                                  15,
                                  15,
                                  15,
                                ),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                  border: Border.all(
                                    color:
                                        AppColors.slotDateContainerBorderColor,
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  children:
                                      widget.addonPackageList
                                          ?.map(
                                            (addOnPackage) => Container(
                                              width: double.infinity,
                                              padding: EdgeInsets.all(13),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xFFE6E4E4),
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    padding: EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      boxShadow: [
                                                        BoxShadow(
                                                          offset: Offset(
                                                            0,
                                                            1.53,
                                                          ),
                                                          color: Colors.black12,
                                                        ),
                                                      ],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                                    child: (() {
                                                      final imageUrl =
                                                          addOnPackage.image
                                                              ?.trim();

                                                      if (imageUrl == null ||
                                                          imageUrl.isEmpty) {
                                                        return const Icon(
                                                          Icons
                                                              .image_not_supported_outlined,
                                                          size: 26,
                                                          color: Colors.grey,
                                                        );
                                                      }

                                                      return CachedNetworkImage(
                                                        imageUrl: imageUrl,
                                                        height: 26,
                                                        fit: BoxFit.fitHeight,
                                                        errorWidget:
                                                            (
                                                              context,
                                                              url,
                                                              error,
                                                            ) => const Icon(
                                                              Icons
                                                                  .image_not_supported_outlined,
                                                              size: 26,
                                                              color:
                                                                  Colors.grey,
                                                            ),
                                                      );
                                                    })(),
                                                  ),
                                                  SizedBox(width: 10),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        RefractedText(
                                                          textColor:
                                                              AppColors.black,
                                                          text:
                                                              addOnPackage
                                                                  .description ??
                                                              '',
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                        RefractedText(
                                                          textColor: AppColors
                                                              .packageTextPrimary,
                                                          text:
                                                              addOnPackage.rate
                                                                  ?.toString() ??
                                                              '',
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          overflow:
                                                              TextOverflow.fade,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                          .toList() ??
                                      [],
                                ),
                              )
                            : SizedBox(),
                        SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.fromLTRB(15, 13, 15, 11),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10),
                            ),
                            border: Border.all(
                              color: AppColors.slotDateContainerBorderColor,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Transform.translate(
                                offset: Offset(8, 0),
                                child: Row(
                                  children: [
                                    Transform.translate(
                                      offset: Offset(0, -1),
                                      child: SvgPicture.asset(
                                        bookingAssetPath(
                                          'assets/svg/img_guest.svg',
                                        ),
                                        height: 11,
                                        width: 11,
                                        color: const Color.fromRGBO(
                                          25,
                                          55,
                                          78,
                                          1,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    RefractedText(
                                      text:
                                          '${updatedBooking.daFname} ${updatedBooking.daLname}',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      textColor: AppColors.packageTextPrimary,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.calenderbackgroundColor,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: SvgPicture.asset(
                                      bookingAssetPath(
                                        'assets/svg/img_Appointment_date.svg',
                                      ),
                                      height: 14,
                                      width: 14,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        RefractedText(
                                          textColor:
                                              AppColors.textFieldHintColor,
                                          text: 'Date & Time'.tr(),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: 2),
                                        Row(
                                          children: [
                                            RefractedText(
                                              text: formattedDate,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              textColor:
                                                  AppColors.packageTextPrimary,
                                            ),
                                            RefractedText(
                                              text:
                                                  ', ${updatedBooking.daAptime}',
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              textColor:
                                                  AppColors.packageTextPrimary,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 6),
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Divider(
                                  color:
                                      AppColors.appointmentDetailDividerColor,
                                  thickness: 1,
                                ),
                              ),
                              SizedBox(height: 4),
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: RefractedText(
                                  textColor: AppColors.textFieldHintColor,
                                  text: 'Appointment ID',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(height: 1),
                              Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: RefractedText(
                                  text: '[${updatedBooking.daId}]',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  textColor: AppColors.packageTextPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (visibleActions.isNotEmpty) SizedBox(height: 8),
                        if (visibleActions.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              borderRadius: const BorderRadius.all(
                                Radius.circular(10),
                              ),
                              border: Border.all(
                                color: AppColors.slotDateContainerBorderColor,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RefractedText(
                                  textColor: AppColors.textFieldHintColor,
                                  text: 'Quick Actions',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 15),
                                ListView.builder(
                                  itemCount: visibleActions.length,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom:
                                            index == visibleActions.length - 1
                                            ? 0
                                            : 10,
                                      ),
                                      child: GestureDetector(
                                        onTap: () async {
                                          if (visibleActions[index].title
                                                  .toLowerCase() ==
                                              "cancel") {
                                            showCancelDialog(context);
                                          } else if (visibleActions[index].title
                                                  .toLowerCase() ==
                                              "reschedule") {
                                            final gp = context
                                                .read<GuestProvider>();

                                            showDialog(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (_) => Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            );

                                            await gp.prepareGuestFromBooking(
                                              context: context,
                                              booking: updatedBooking,
                                              packageName: widget.packageName,
                                              packageDrId: widget.packageDrId,
                                            );

                                            if (!context.mounted) return;
                                            // Dismiss the loading dialog.
                                            Navigator.pop(context);
                                            gp.isFromReschedule = true;
                                            gp.rescheduleAppointmentId =
                                                updatedBooking.daId.toString();
                                            if (context.mounted) {
                                              // The host's Navigator sits
                                              // above the booking module's
                                              // MultiProvider, so forward
                                              // the existing instances or
                                              // AddGuestsDetail throws
                                              // ProviderNotFoundException.
                                              final packagesProvider = context
                                                  .read<PackagesProvider>();
                                              final loginProvider = context
                                                  .read<LoginProvider>();
                                              final result = await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => MultiProvider(
                                                    providers: [
                                                      ChangeNotifierProvider<
                                                        GuestProvider
                                                      >.value(value: gp),
                                                      ChangeNotifierProvider<
                                                        PackagesProvider
                                                      >.value(
                                                        value: packagesProvider,
                                                      ),
                                                      ChangeNotifierProvider<
                                                        LoginProvider
                                                      >.value(
                                                        value: loginProvider,
                                                      ),
                                                    ],
                                                    child: AddGuestsDetail(),
                                                  ),
                                                  settings: const RouteSettings(
                                                    name: '/AddGuestsDetail',
                                                  ),
                                                ),
                                              );

                                              if (result == true) {}
                                            }
                                          }
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    color: visibleActions[index]
                                                        .backgroundColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          100,
                                                        ),
                                                  ),
                                                  child: SvgPicture.asset(
                                                    visibleActions[index].icon,
                                                    height: 14,
                                                    width: 14,
                                                  ),
                                                ),
                                                SizedBox(width: 8),
                                                RefractedText(
                                                  textColor: AppColors
                                                      .packageTextPrimary,
                                                  text: visibleActions[index]
                                                      .title,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ],
                                            ),
                                            Icon(
                                              Icons.arrow_forward_ios,
                                              size: 12,
                                              color:
                                                  AppColors.textFieldHintColor,
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
                    ),
                  ),
          );
        },
      ),
    );
  }

  void showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 20,
          ),
          content: Column(
            mainAxisSize: MainAxisSize
                .min, // Ensures the column takes only required space
            children: [
              SizedBox(height: 8),
              const RefractedText(
                textAlign: TextAlign.center,
                text:
                    'Kindly contact our customer care team for support with cancellation and refund requests. If an advance payment has been made, they will assist you with the refund process',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                textColor: AppColors.packageTextPrimary,
                overflow: TextOverflow.fade,
              ),
              const SizedBox(height: 10),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Nura Call Center",
                      style: TextStyle(
                        color: AppColors.callCenterTextColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          launchUrl(Uri.parse("tel:7310494949"));
                        },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 100,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.selectLocationButtonColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: RefractedText(
                          textAlign: TextAlign.center,
                          text: 'OK',
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          textColor: AppColors.packageTextPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
