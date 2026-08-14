// ignore_for_file: prefer_const_constructors, unnecessary_null_comparison, unused_field

import 'dart:convert';

import 'package:booking/core/extensions.dart';
import 'package:booking/main.dart';
import 'package:booking/provider/guests_provider.dart';
import 'package:booking/provider/login_provider.dart';
import 'package:booking/provider/package_provider.dart';
import 'package:booking/services/navigation_services.dart';
import 'package:booking/view/booking_list/appointment_detail.dart';
import 'package:booking/widgets/appointment_history_shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/colors.dart';
import '../../widgets/refracted_text.dart';

class AppointmentHistory extends StatefulWidget {
  const AppointmentHistory({super.key});

  @override
  State<AppointmentHistory> createState() => _AppointmentHistoryState();
}

class _AppointmentHistoryState extends State<AppointmentHistory>
    with TickerProviderStateMixin {
  /// Provider to manage login-related functionalities and data.
  LoginProvider loginProvider = LoginProvider();
  double opacity = 1;
  double scale = 1;
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  bool hasAnimated = false;

  /// Re-exposes the booking module's providers on a route pushed from here.
  ///
  /// [push] lands the route on the host's navigator, which sits ABOVE the
  /// module's MultiProvider scope, so [AppointmentDetail] would otherwise throw
  /// `ProviderNotFoundException`. Re-provide the in-scope instances by value.
  Widget _withModuleProviders(BuildContext context, Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LoginProvider>.value(
          value: Provider.of<LoginProvider>(context, listen: false),
        ),
        ChangeNotifierProvider<PackagesProvider>.value(
          value: Provider.of<PackagesProvider>(context, listen: false),
        ),
        ChangeNotifierProvider<GuestProvider>.value(
          value: Provider.of<GuestProvider>(context, listen: false),
        ),
      ],
      child: child,
    );
  }

  // Triggers a simple scale and opacity animation.
  void triggerAnimation() {
    setState(() {
      opacity = 0;
      scale = 2;
    });
  }

  @override
  void dispose() {
    bookingListRefreshTick.removeListener(_onBookingChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );

    _scaleAnim = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
      ),
    );
    // Refetch whenever a booking is created elsewhere (e.g. the package flow,
    // which runs in a separate provider scope and pops back without
    // rebuilding this screen). See [bookingListRefreshTick].
    bookingListRefreshTick.addListener(_onBookingChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData().then((value) {
        _controller.forward();
      });
    });
  }

  void _onBookingChanged() {
    if (!mounted) return;
    // Refresh the user's bookings so the newly created appointment appears.
    Provider.of<LoginProvider>(context, listen: false).getBookingList();
  }

  Future<void> _loadInitialData() async {
    final login = Provider.of<LoginProvider>(context, listen: false);
    final packages = Provider.of<PackagesProvider>(context, listen: false);

    try {
      await Future.wait([packages.getPackagesList(), login.getBookingList()]);
    } finally {
      if (mounted) {
        setState(() {
          opacity = 1;
          scale = 1;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access providers to update and retrieve data.
    loginProvider = Provider.of<LoginProvider>(context);
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
          text: 'Appointment History'.tr(),
          textColor: AppColors.primaryDark,
        ),
      ),
      body: Consumer<LoginProvider>(
        builder: (context, provider, child) {
          final results = provider.bookinghistoryModel?.result;

          final isLoading =
              provider.isBookingLoading ||
              packagesProvider.isPackagesListLoading ||
              packagesProvider.packagesList.isEmpty;

          final hasError = provider.isBookingFailed || results == null;
          final isEmpty = results != null && results.isEmpty;

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: isLoading
                ? const AppointmentHistoryShimmer()
                : hasError || isEmpty
                ? const SizedBox()
                : AnimatedOpacity(
                    opacity: opacity,
                    duration: const Duration(milliseconds: 400),
                    child: ScaleTransition(
                      scale: _scaleAnim,
                      child: Builder(
                        builder: (context) {
                          // Only render bookings with a usable date and a
                          // matching package; otherwise the ListView's
                          // separators still add spacing for the empty
                          // placeholder rows, leaving large visual gaps.
                          final validResults = results.where((booking) {
                            return booking.daDate != null &&
                                packagesProvider.getPackageByCode(
                                      booking.daPackagetypevalue,
                                    ) !=
                                    null;
                          }).toList();

                          return ListView.separated(
                            key: PageStorageKey("appointment_list"),
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                            itemCount: validResults.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final booking = validResults[index];

                              DateTime dt = booking.daDate!;

                              final formattedDate = loginProvider
                                  .formatHistoryDate(dt);
                              final package = packagesProvider.getPackageByCode(
                                booking.daPackagetypevalue,
                              )!;

                              final packageName =
                                  booking.packageDetails?.description ?? 'N/A';
                              final packageDrId =
                                  booking.packageDetails?.slotDoctorPtr;
                              Map<String, dynamic> extraData = {};
                              try {
                                extraData = jsonDecode(
                                  package.itmOtherdet3 ?? '{}',
                                );
                              } catch (_) {}

                              final packageImage =
                                  booking.packageDetails?.image;
                              final hasValidImage =
                                  packageImage != null &&
                                  packageImage.toString().isNotEmpty;

                              final String? packageBackground =
                                  extraData['background_gradient'];
                              final delayIndex = index.clamp(0, 5);

                              /// STAGGERED ANIMATION
                              return TweenAnimationBuilder(
                                duration: Duration(
                                  milliseconds: 400 + (delayIndex * 80),
                                ),
                                tween: Tween<double>(begin: 0, end: 1),
                                builder: (context, double value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: Transform.translate(
                                      offset: Offset(
                                        0,
                                        20 * (1 - value),
                                      ), // reduced movement
                                      child: child,
                                    ),
                                  );
                                },

                                /// CARD
                                child: GestureDetector(
                                  onTap: () {
                                    push(
                                      context,
                                      _withModuleProviders(
                                        context,
                                        AppointmentDetail(
                                          addonPackageList:
                                              booking.addOnPackageDetails,
                                          bookingId: booking.daId,
                                          packageName: packageName,
                                          packageImage: packageImage,
                                          packageBackground: packageBackground,
                                          packageDrId: packageDrId,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.08),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 64,
                                          width: 64,
                                          decoration: BoxDecoration(
                                            gradient:
                                                packageBackground
                                                    ?.parseGradient() ??
                                                AppColors
                                                    .defaultPackageGradient,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: hasValidImage
                                                ? CachedNetworkImage(
                                                    imageUrl: packageImage,
                                                    fit: BoxFit.contain,
                                                  )
                                                : const Icon(Icons.image),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            RefractedText(
                                              text:
                                                  '${booking.daFname} ${booking.daLname}',
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              textColor:
                                                  AppColors.packageTextPrimary,
                                            ),
                                            const SizedBox(height: 10),
                                            RefractedText(
                                              text: packageName,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              textColor:
                                                  AppColors.textFieldHintColor,
                                            ),
                                            Row(
                                              children: [
                                                RefractedText(
                                                  text: formattedDate,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  textColor: AppColors
                                                      .packageTextPrimary,
                                                ),
                                                RefractedText(
                                                  text: ', ${booking.daAptime}',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  textColor: AppColors
                                                      .packageTextPrimary,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
