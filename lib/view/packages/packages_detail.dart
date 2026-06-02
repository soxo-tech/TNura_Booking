import 'dart:convert';
import 'package:booking/core/constants.dart';

import 'package:booking/core/colors.dart';
import 'package:booking/core/extensions.dart';
import 'package:booking/main.dart';
import 'package:booking/model/packages_list_model.dart';
import 'package:booking/provider/guests_provider.dart';
import 'package:booking/provider/package_provider.dart';
import 'package:booking/services/navigation_services.dart';
import 'package:booking/services/shared_preferences.dart';
import 'package:booking/widgets/refracted_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// The `Packages Detail` widget is a screen that displays a Detail of packages.
/// Users can view packages available
class PackageDetail extends StatefulWidget {
  /// The leading widget to be displayed on the AppBar.
  final Widget? leading;
  final bool isFromTab;
  final PackagesListModel package;
  final String currency;

  const PackageDetail(
    this.package, {
    super.key,
    this.leading,
    this.currency = "",
    this.isFromTab = true,
  });

  @override
  State<PackageDetail> createState() => _PackageDetailState();
}

class _PackageDetailState extends State<PackageDetail>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late PackagesListModel package;
  late List<Map<String, dynamic>> screenings;
  List<Question>? questions;

  // This widget represents the main scaffold of the home page with a custom app bar,
  // drawer, body content, and bottom navigation bar.
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  /// Flag indicating whether the user is logged in.
  bool isLogin = false;
  late Map<String, dynamic> itmOtherdet3;
  late String gradientString;

  @override
  void initState() {
    super.initState();
    package = widget.package;
    questions = package.questions;
    final String rawJson = widget.package.itmOtherdet3 ?? '{}';
    try {
      itmOtherdet3 =
          jsonDecode(rawJson.replaceAll('“', '"').replaceAll('”', '"'));
    } catch (e) {
      itmOtherdet3 = {};
    }
    gradientString = itmOtherdet3['background_gradient'] ?? '';
    screenings =
        (widget.package.packageDetails ?? []).map<Map<String, dynamic>>((e) {
      List<String> childrenList = [];

      // Convert "Details" to a proper List<String>
      if (e["Details"] is List) {
        childrenList = (e["Details"] as List)
            .expand((d) => d.toString().split(','))
            .map((d) => d.trim()) // Trim spaces after splitting
            .where((d) => d.isNotEmpty) // Remove empty strings
            .toList();
      } else if (e["Details"] != null &&
          e["Details"].toString().trim().isNotEmpty) {
        childrenList = e["Details"]
            .toString()
            .split(',') // Split by commas
            .map((d) => d.trim()) // Trim spaces
            .where((d) => d.isNotEmpty) // Remove empty values
            .toList();
      }

      // Prepare the final map
      final Map<String, dynamic> screeningMap = {"title": e["item"] ?? ""};

      if (childrenList.isNotEmpty) {
        screeningMap["children"] = childrenList;
      }

      return screeningMap;
    }).toList();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1.0), // Start off-screen at the bottom
      end: Offset.zero, // Move to normal position (top)
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();
    // Start animation when page opens
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // Key to control the scaffold state (e.g., opening the drawer).

        key: _key,
       

        ///Returns the start booking now button
        bottomNavigationBar: isBookingFlowEnabled
            ? // Wrap your button in a Consumer so it reacts to the loading state
            Consumer<PackagesProvider>(
                builder: (context, packageProvider, child) {
                  return InkWell(
                    onTap: packageProvider.isBookingNowButtonLoading
                        ? null // Disable tap while loading
                        : () async {
                            packageProvider.setBookingLoading(true);
                            try {
                              final gp = Provider.of<GuestProvider>(context,
                                  listen: false,);

                              // Reset state
                              gp.showConfirmAppointmentDetails = false;
                              if (gp.guests.isNotEmpty) {
                                gp.guests.first.step =
                                    GuestStep.appointmentScheduling;
                              }

                              // Run the async logic
                              await gp.selectPackageAndProceed(
                                  context, package,);

                              final prefs =
                                  await SharedPreferencesService.prefs;
                              final selectedIndex =
                                  prefs.getInt('selected_branch_index') ?? 0;
                              if (!context.mounted) return;
                              await packageProvider.handleBranchSelection(
                                context,
                                selectedIndex,
                                shouldNavigate: true,
                                isFromBranchList: false,
                              );
                            } finally {
                              // Always stop the loader, even if an error occurs
                              packageProvider.setBookingLoading(false);
                            }
                          },
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                        child: Container(
                          width: double.infinity,
                          height: 42,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: packageProvider.isBookingNowButtonLoading
                                ? AppColors.bookNowButtonColor.withValues(alpha: 0.7)
                                : AppColors.bookNowButtonColor,
                          ),
                          child: Center(
                            child: packageProvider.isBookingNowButtonLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.white,
                                    ),
                                  )
                                : const Text(
                                    'BOOK NOW',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              )
            : const SizedBox(),
        backgroundColor: AppColors.backgroundBlueLight,
        // Background color of the screen.,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundBlueLight,
          elevation: 2,
          shadowColor: const Color.fromARGB(157, 255, 255, 255),
        // Increased height for the app bar.
        toolbarHeight: kToolbarHeight + 20,
        leading: InkWell(
          onTap: () {
            pop(context);
          },
          child: const Icon(
            Icons.arrow_back,
            color: AppColors.packageHeadColor,
            size: 22,
          ),
        ),
        // Disable automatic leading widget.
        automaticallyImplyLeading: false,
        title: RefractedText(
          textColor: AppColors.packageHeadColor,
          text: 'Packages'.tr(),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ), // Default logo when not logged in.
        // Title is aligned to the left.
        centerTitle: true,
        titleTextStyle: Theme.of(context).textTheme.bodyLarge,
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ///Nura package name
                  RefractedText(
                    text: widget.package.itmDesc?.tr() ?? "",
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    textColor: AppColors.packageTextPrimary,
                  ),

                  ///Package Amount
                  RefractedText(
                    text: '${widget.currency} ${widget.package.irRate}',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    textColor: AppColors.packageTextPrimary,
                  ),
                  const SizedBox(
                    height: 15,
                  ),

                  ///Displays Package Image
                  Container(
                    padding: const EdgeInsets.only(
                      top: 20,
                    ),
                    height: 174,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: gradientString.parseGradient(),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        /// Image at the center
                        CachedNetworkImage(
                          imageUrl: itmOtherdet3['item_image'] ?? "",
                          height: double.infinity,
                          fit: BoxFit.fitHeight,
                          errorListener: (value) {},
                          errorWidget: (context, error, stackTrace) {
                            return const SizedBox();
                          },
                        ),

                        /// Left-side text container
                        Positioned(
                          left: 0,
                          top: 0,
                          child: Container(
                            width: 100,
                            height: 30,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(4.36),
                                bottomRight: Radius.circular(4.36),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  bookingAssetPath('assets/images/timer.png'),
                                  height: 16,
                                  width: 16,
                                ),
                                const SizedBox(width: 4),
                                RefractedText(
                                  textColor: AppColors.primaryDark,
                                  text: (widget.package.itmTime ?? "").tr(),
                                  fontWeight: FontWeight.w600,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 18,
                  ),

                  ///the points to remember before taking appointment
                  Container(
                    padding: const EdgeInsets.fromLTRB(9, 0, 9, 0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(0),
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                      ),
                      child: ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        backgroundColor: Colors.white,
                        collapsedBackgroundColor: Colors.white,
                        title: Padding(
                          padding: const EdgeInsets.only(left: 7, right: 5),
                          child: RefractedText(
                            text: 'Eligibility Criteria'.tr(),
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            textColor: AppColors.packageTextPrimary,
                          ),
                        ),
                        children: [
                          AnimatedSize(
                            duration: const Duration(
                                milliseconds: 300,), // smooth height animation
                            curve: Curves.easeInOut,
                            child: AnimatedSwitcher(
                              duration: const Duration(
                                  milliseconds: 400,), // fade + switch animation
                              switchInCurve: Curves.easeOut,
                              switchOutCurve: Curves.easeIn,

                              child: (questions != null &&
                                      questions!.isNotEmpty)
                                  ? Column(
                                      key: const ValueKey('expanded'),
                                      children: questions!
                                          .map(
                                            (q) => AnimatedPadding(
                                              duration:
                                                  const Duration(milliseconds: 200),
                                              padding: const EdgeInsets.only(
                                                  bottom: 6, left: 8, right: 8,),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text('• ',
                                                      style: TextStyle(
                                                          fontSize: 16,),),
                                                  Expanded(
                                                    child: RefractedText(
                                                      text: q.question.tr(),
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 14,
                                                      textColor: AppColors
                                                          .packageTextPrimary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),

                  ///Text to show what the screening really includes
                  RefractedText(
                    text: 'SCREENING INCLUDES'.tr(),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    textColor: AppColors.packagePrimarySubText,
                  ),
                  const SizedBox(height: 8), // Space between title and list

                  ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: screenings.map((screening) {
                      final hasChildren = screening.containsKey("children") &&
                          (screening["children"] as List).isNotEmpty;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(vertical: 3),
                        // padding: EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: hasChildren
                            ? Theme(
                                data: Theme.of(context).copyWith(
                                  dividerColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                ),
                                child: ExpansionTile(
                                  tilePadding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 0,),
                                  backgroundColor: AppColors.white,
                                  collapsedBackgroundColor: AppColors.white,
                                  title: Padding(
                                    padding: const EdgeInsets.only(
                                      left: 11,
                                    ),
                                    child: RefractedText(
                                      text:
                                          (screening["title"] as String? ?? "")
                                              .tr(),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      textColor: AppColors.packageTextPrimary,
                                    ),
                                  ),
                                  children:
                                      (screening["children"] as List<String>)
                                          .map(
                                    (subItem) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          left: 18,
                                          right: 12,
                                          bottom:
                                              10, // reduced spacing between points
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text("• ",
                                                style: TextStyle(fontSize: 14),),
                                            Expanded(
                                              child: RefractedText(
                                                text: subItem.tr(),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                textColor: AppColors
                                                    .packagePrimarySubText,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ).toList(),
                                ),
                              )
                            : Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(15, 15, 15, 15),
                                child: RefractedText(
                                  text: (screening["title"] as String? ?? "")
                                      .tr(),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  textColor: AppColors.packageTextPrimary,
                                ),
                              ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ),);
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
