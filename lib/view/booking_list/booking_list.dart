// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';

import 'package:booking/core/colors.dart';
import 'package:booking/core/constants.dart';
import 'package:booking/core/extensions.dart';
import 'package:booking/main.dart';
import 'package:booking/provider/guests_provider.dart';
import 'package:booking/provider/login_provider.dart';
import 'package:booking/provider/package_provider.dart';
import 'package:booking/view/booking_list/appointment_detail.dart';
import 'package:booking/view/booking_list/appointment_history.dart';
import 'package:booking/widgets/app_space_widget.dart';
import 'package:booking/widgets/refracted_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

/// Booking-list entry point of the booking module.
///
/// Intended to be mounted by the host app on its **home page** via
/// [BookingFlowLauncher] with `destination: BookingDestination.bookingList`.
///
/// This is currently a placeholder shell: it shares the module's providers,
/// auth token and environment config (set up by the launcher) so that the real
/// UI + API wiring can be filled in later without touching the host
/// integration.
class BookingListScreen extends StatefulWidget {
  /// Whether the screen is hosted inside a tab/home body (vs. a pushed route).
  ///
  /// When embedded in the host's home page this is typically `true`, which
  /// hides the back button so it doesn't fight the host's own navigation.
  final bool isFromTab;

  /// When true the screen is mounted inline inside a host screen (e.g. above a
  /// card on the home page). In this mode it renders no [Scaffold] and sizes
  /// itself to its content, collapsing to zero height while loading / on
  /// failure / when there are no appointments, so it never reserves space or
  /// shows a loader on the host. The appointments simply appear once the API
  /// responds.
  final bool embedded;

  const BookingListScreen({
    super.key,
    this.isFromTab = true,
    this.embedded = false,
  });

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> with TickerProviderStateMixin {
  double opacity = 1;
  double scale = 1;
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

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

    _scaleAnim = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
      ),
    );
    _controller.forward();
    // Refetch whenever a booking is created elsewhere (e.g. the package flow,
    // which runs in a separate provider scope and pops back to this screen
    // without rebuilding it). See [bookingListRefreshTick].
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

  /// Re-exposes the booking module's providers on a route pushed from here.
  ///
  /// Pushes go onto the host's navigator, which sits ABOVE the
  /// [BookingFlowLauncher]'s MultiProvider scope, so pushed screens like
  /// [AppointmentDetail]/[AppointmentHistory] would otherwise throw
  /// `ProviderNotFoundException`. We grab the in-scope provider instances and
  /// re-provide them by value on the new route.
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
    final packagesProvider = context.watch<PackagesProvider>();
    final loginProvider = Provider.of<LoginProvider>(context);

    final content = Consumer<LoginProvider>(
        builder: (context, provider, child) {
          final results = provider.bookinghistoryModel?.result;
          if (provider.isBookingLoading ||
              packagesProvider.isPackagesListLoading ||
              packagesProvider.packagesList.isEmpty) {
            return SizedBox(); // or shimmer
          }

          // FAILED OR NULL RESPONSE
          if (provider.isBookingFailed || results == null) {
            return SizedBox(); // DO NOT SHOW APPOINTMENTS
          }

          // EMPTY LIST
          if (results.isEmpty) {
            return SizedBox(); // DO NOT SHOW APPOINTMENTS
          }

          // Only bookings with a date and a resolvable package actually render
          // as a card below; filter here so the count badge and the
          // scrollable list agree on how many appointments there are.
          final validResults = results
              .where(
                (booking) =>
                    booking.daDate != null &&
                    packagesProvider.getPackageByCode(
                          booking.daPackagetypevalue,
                        ) !=
                        null,
              )
              .toList();

          if (validResults.isEmpty) {
            return SizedBox();
          }

          // VALID DATA
          return Column(
            // Size to content so the screen can be embedded as an inline item
            // (e.g. a host's home ListView) without an unbounded-height error.
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              setHeight(17),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      RefractedText(
                        text: 'Your appointments',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        textColor: AppColors.bottomTabColor,
                      ),
                      SizedBox(width: 5),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: AppColors.bookNowButtonColor,
                        ),
                        child: Center(
                          child: RefractedText(
                            text: '${validResults.length}',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            textColor: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  validResults.length == 1
                      ? SizedBox()
                      : GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) =>
                                    _withModuleProviders(
                                        context, AppointmentHistory()),
                                transitionDuration: Duration.zero,
                              ),
                            );
                          },
                          child: RefractedText(
                            text: 'View all',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            textColor: AppColors.bottomTabColor,
                          ),
                        ),
                ],
              ),
              setHeight(12),
              SizedBox(
                height: 90,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                    // When there's only a single booking, the card fits the
                    // full available width; otherwise it keeps the peeking
                    // 85%-width card so adjacent cards hint at horizontal scroll.
                    final bool isSingle = validResults.length == 1;
                    final double cardWidth = isSingle
    ? constraints.maxWidth
    : constraints.maxWidth - 8;
                    return ListView.separated(
  scrollDirection: Axis.horizontal,
  physics: isSingle
      ? const NeverScrollableScrollPhysics()
      : const BouncingScrollPhysics(),
  padding: EdgeInsets.zero, // No padding at start/end
  itemCount: validResults.length,
  separatorBuilder: (_, __) => const SizedBox(width: 15),
  itemBuilder: (context, index) {
                      final booking = validResults[index];
                      DateTime dt = booking.daDate!;

                      final formattedDate = loginProvider.formatHistoryDate(dt);
                      final formattedTime = loginProvider.formatTime(
                        dt,
                        context,
                      );
                      final package = packagesProvider.getPackageByCode(
                        booking.daPackagetypevalue,
                      )!;

                      final packageName =
                          booking.packageDetails?.description ?? 'N/A';
                      final packageDrId = booking.packageDetails?.slotDoctorPtr;

                      Map<String, dynamic> extraData = {};
                      try {
                        extraData = jsonDecode(package.itmOtherdet3 ?? '{}');
                      } catch (e) {
                        extraData = {};
                      }
                      final packageImage = booking.packageDetails?.image ?? "";

                      final hasValidImage =
                          packageImage != null &&
                          packageImage.toString().isNotEmpty;
                      final String? packageBackground =
                          extraData['background_gradient'];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration: Duration(milliseconds: 400),
                              pageBuilder: (_, __, ___) => _withModuleProviders(
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
                              transitionsBuilder: (_, animation, __, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: ScaleTransition(
                                    scale: Tween(
                                      begin: 0.95,
                                      end: 1.0,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        child: IntrinsicWidth(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.85,
                            padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 1,
                                  spreadRadius: 0.5,
                                  offset: Offset(0, 1),
                                ),
                              ],
                              border: Border.all(
                                color: AppColors.slotDateContainerBorderColor,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  height: 64,
                                  width: 64,
                                  padding: EdgeInsets.only(top: 8),
                                  decoration: BoxDecoration(
                                    gradient:
                                        packageBackground?.parseGradient() ??
                                        AppColors.defaultPackageGradient,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: hasValidImage
                                        ? CachedNetworkImage(
                                            imageUrl: packageImage,
                                            fit: BoxFit.contain,
                                            placeholder: (context, url) => Center(
                                              child: SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white.withOpacity(
                                                    0.5,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            errorWidget: (context, url, error) =>
                                                Icon(Icons.image, size: 30),
                                          )
                                        : Icon(Icons.image, size: 30), // fallback
                                  ),
                                ),
                                SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        SvgPicture.asset(
                                          bookingAssetPath('assets/svg/img_guest.svg'),
                                          height: 10,
                                          width: 10,
                                          color: const Color.fromRGBO(
                                            25,
                                            55,
                                            78,
                                            1,
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        RefractedText(
                                          text:
                                              '${booking?.daFname} ${booking?.daLname}',
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          textColor: AppColors.packageTextPrimary,
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    RefractedText(
                                      text: packageName,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      textColor: AppColors.textFieldHintColor,
                                    ),
                                    Row(
                                      children: [
                                        RefractedText(
                                          text: formattedDate,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          textColor: AppColors.packageTextPrimary,
                                        ),
                                        RefractedText(
                                          text: ', ${booking.daAptime}',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          textColor: AppColors.packageTextPrimary,
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
              setHeight(3),
            ],
          );
        },
      );

    // Inline (host home) mounts have no Scaffold so they collapse to zero
    // height and size to content; full-page mounts keep the Scaffold.
    return widget.embedded ? content : Scaffold(body: content);
  }
}
