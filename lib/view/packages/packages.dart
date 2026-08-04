import 'package:booking/core/colors.dart';
import 'package:booking/core/constants.dart';
import 'package:booking/core/extensions.dart';
import 'package:booking/main.dart';
import 'package:booking/model/packages_list_model.dart';
import 'package:booking/provider/guests_provider.dart';
import 'package:booking/provider/login_provider.dart';
import 'package:booking/provider/package_provider.dart';
import 'package:booking/services/shared_preferences.dart';
import 'package:booking/view/booking/booking.dart';
import 'package:booking/view/packages/packages_detail.dart';
import 'package:booking/widgets/app_space_widget.dart';
import 'package:booking/widgets/custom_appbar.dart';
import 'package:booking/widgets/packages_shimmers.dart';
import 'package:booking/widgets/refracted_button.dart';
import 'package:booking/widgets/refracted_text.dart';
import 'package:booking/widgets/stacked_loader.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

/// The `Packages` widget shows a list of screening packages.  The bottom bar
/// behaves like this:
/// * When the page first appears the bar animates **upwards** from the bottom
///   with a subtle fade/slide.
/// * While the list remains at offset 0, the bar stays fixed (overlay).
/// * As soon as the user scrolls away from offset 0 the overlay bar animates
///   down + fades out, letting the list scroll normally.
/// * A second copy of the bar (inside the scroll view) slides into view when
///   the user reaches the end of the list.
class Packages extends StatefulWidget {
  final bool isFromTab;

  const Packages({super.key, this.isFromTab = true});

  @override
  State<Packages> createState() => _PackagesState();
}

class _PackagesState extends State<Packages> with TickerProviderStateMixin {
  late final AnimationController controller;

  // ──────────────────────────────────────────────────────────────────────────
  // Scroll‑handling for the sticky‑until‑scroll bottom bar
  // ──────────────────────────────────────────────────────────────────────────
  late final ScrollController _scrollController;
  static const double _bottomBarHeight = 140;
  bool _showFixedBottomBar = false; // start hidden, animate in after build
  String currency = "";
  final LoginProvider loginProvider = LoginProvider();
  int? loadingIndex;

  @override
  void initState() {
    super.initState();

    controller = BottomSheet.createAnimationController(this)
      ..duration = const Duration(milliseconds: 600);

    _scrollController = ScrollController()..addListener(_onScroll);

    // Boot‑strap provider
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final provider = Provider.of<PackagesProvider>(context, listen: false);
      await provider.init(context);
      // provider.getPackagesList();
      final prefs = await SharedPreferencesService.prefs;
      final isBookingFlowEnabled =
          prefs.getBool(kIsBookingFlowEnabled) ?? false;
      currency = prefs.getString('currency') ?? "";
      // Trigger the entrance animation for the bottom bar
      if (isBookingFlowEnabled) {
        setState(() => _showFixedBottomBar = true);
      }
    });
  }

  void _onScroll() {
    if (!isBookingFlowEnabled) return;

    final atTop = _scrollController.positions.isNotEmpty &&
        _scrollController.position.pixels <= 0;

    if (atTop != _showFixedBottomBar) {
      setState(() => _showFixedBottomBar = atTop);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.isFromTab
          ? null
          : customAppBar(
              title: 'Packages'.tr(),
              context: context,
              onBack: () {
                Navigator.pop(context);
              },
            ),
      backgroundColor: AppColors.backgroundBlueLight,
      body: Stack(
        children: [
          Consumer<PackagesProvider>(
            builder: (context, packageProvider, _) {
              if ((packageProvider.isInitializing ||
                  packageProvider.isBranchListLoadingInitial)) {
                return const PackagesShimmer(); /* const Center(child: CircularProgressIndicator()) */
              }

              return CustomScrollView(
                controller: _scrollController,
                slivers: [
                  _buildSelectLocationButton(packageProvider),
                  _buildPackagesList(packageProvider),

                  // Bottom padding so the last item isn't covered by the bar
                  SliverToBoxAdapter(child: setHeight(20)),

                  // Scroll-with-content copy of the bar at the bottom
                  // if (_isBookingEnabled)
                  //   SliverToBoxAdapter(
                  //     child: bottomBar(packageProvider),
                  //   ),
                ],
              );
            },
          ),

          // The Animated Overlay Bottom Bar
          // if (_isBookingEnabled)
          //   Consumer<PackagesProvider>(
          //     builder: (context, packageProvider, _) => Positioned(
          //       left: 0, right: 0, bottom: 0,
          //       child: AnimatedSlide(
          //         duration: const Duration(milliseconds: 400),
          //         curve: Curves.easeInOut,
          //         offset: _showFixedBottomBar ? Offset.zero : const Offset(0, 1),
          //         child: AnimatedOpacity(
          //           duration: const Duration(milliseconds: 300),
          //           opacity: _showFixedBottomBar ? 1 : 0,
          //           child: bottomBar(packageProvider),
          //         ),
          //       ),
          //     ),
          //   ),

          // Branch Loading Overlay
          Consumer<PackagesProvider>(
            builder: (context, provider, _) => provider.isBranchListLoading
                ? const StackedLoader()
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildSelectLocationButton(PackagesProvider provider) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
        child: GestureDetector(
          onTap: () => selectBranches(context, provider),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: AppColors.selectLocationButtonColor,
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  bookingAssetPath('assets/svg/select_location.svg'),
                  height: 17,
                  width: 17,
                ),
                const SizedBox(width: 10),
                RefractedText(
                  text: (provider.selectedCountry?.isNotEmpty ?? false) &&
                          (provider.selectedBranch?.isNotEmpty ?? false)
                      ? '${provider.selectedCountry}, ${provider.selectedBranch}'
                      : 'Select Location'.tr(),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  textColor: AppColors.selectedLocationColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SliverPadding _buildPackagesList(PackagesProvider provider) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
      sliver: Builder(
        builder: (context) {
          if ((provider.selectedBranch == null ||
                  provider.selectedBranch!.isEmpty) &&
              provider.selectedCountry != null &&
              provider.bookingFlowBranches.isNotEmpty) {
            return SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('Please choose a branch'.tr())),
            );
          }

          if (provider.isPackagesListLoading) {
            return const SliverToBoxAdapter(child: PackagesShimmer());
          }

          if (provider.packagesList.isEmpty) {
            return SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text('No Packages Available'.tr())),
            );
          }

          final total = provider.packagesList.length;
          return AnimationLimiter(
            child: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index.isOdd) return setHeight(16);
                  final itemIndex = index ~/ 2;
                  final package = provider.packagesList[itemIndex];
                  return InkWell(
                    onTap: () =>
                        pushPackageDetail(context, package, currency),
                    child: AnimationConfiguration.staggeredList(
                      position: itemIndex,
                      delay: const Duration(milliseconds: 200),
                      child: SlideAnimation(
                        verticalOffset: 200,
                        child: FadeInAnimation(
                          duration: const Duration(milliseconds: 500),
                          child: packageCard(itemIndex, package, provider),
                        ),
                      ),
                    ),
                  );
                },
                childCount: total * 2 - 1,
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> selectBranches(BuildContext context, PackagesProvider provider) {
    return showModalBottomSheet(
      transitionAnimationController: controller,
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 35),
              child: provider.bookingFlowBranches.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RefractedText(
                              text: 'SELECT BRANCH'.tr(),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              textColor: AppColors.packageHeadColor,
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: SvgPicture.asset(
                                bookingAssetPath('assets/svg/close_icon.svg'),
                                height: 18,
                                width: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: provider.bookingFlowBranches.length,
                          separatorBuilder: (_, __) => setHeight(10),
                          itemBuilder: (_, index) => GestureDetector(
                            onTap: () async {
                              await provider.handleBranchSelection(
                                context,
                                index,
                                isFromBranchList: true,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: AppColors.buttonBlueLight,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  RefractedText(
                                    text: provider
                                            .bookingFlowBranches[index].desc ??
                                        '',
                                    fontSize: 18,
                                    fontWeight:
                                        provider.selectedBranchIndex == index
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                    textColor: AppColors.packageHeadColor,
                                  ),
                                  if (provider.selectedBranchIndex == index)
                                    SvgPicture.asset(
                                      bookingAssetPath('assets/svg/selected_country.svg'),
                                    ),
                                ],
                              ),
                            ),
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

  // The host Navigator sits above the launcher's MultiProvider, so forward
  // the booking providers onto the pushed route or PackageDetail throws
  // ProviderNotFoundError (its "BOOK NOW" flow reads all three).
  void pushPackageDetail(
    BuildContext context,
    PackagesListModel package,
    String currency,
  ) {
    final guestProvider = context.read<GuestProvider>();
    final packagesProviderRef = context.read<PackagesProvider>();
    final loginProvider = context.read<LoginProvider>();
    pushWithAnimation(
      context,
      MultiProvider(
        providers: [
          ChangeNotifierProvider<GuestProvider>.value(value: guestProvider),
          ChangeNotifierProvider<PackagesProvider>.value(
            value: packagesProviderRef,
          ),
          ChangeNotifierProvider<LoginProvider>.value(value: loginProvider),
        ],
        child: PackageDetail(package, currency: currency),
      ),
    );
  }

  void pushWithAnimation(BuildContext context, Widget page) {
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        // CHANGE THIS TO TRUE
        opaque: true,
        barrierDismissible: false,
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final slideAnimation = Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          );

          final fadeAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeIn,
          );

          return SlideTransition(
            position: slideAnimation,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: child,
            ),
          );
        },
      ),
    );
  }

  void push(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  Widget bottomBar(PackagesProvider packageProvider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
      height: _bottomBarHeight,
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
        color: AppColors.startBookingButtonTabColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RefractedText(
            text: 'Step into a future of sustained health and wellbeing!'.tr(),
            fontSize: 16,
            fontWeight: FontWeight.w500,
            textColor: AppColors.white,
          ),
          const SizedBox(height: 15),
          RefractedButton(
            fontWeight: FontWeight.w600,
            textColor: AppColors.primaryLight,
            fontSize: 14,
            label: 'BOOK NOW',
            backGroundColor: AppColors.white,
            onTap: () async {
              final prefs = await SharedPreferencesService.prefs;
              final selectedIndex = prefs.getInt('selected_branch_index') ?? 0;

              await packageProvider.handleBranchSelection(
                context,
                selectedIndex,
                isFromBranchList: false,
              );

              if (!mounted) return;
              // The host Navigator sits above the launcher's MultiProvider, so
              // forward the booking providers onto the pushed route or
              // AddGuestsDetail throws ProviderNotFoundError.
              final guestProvider = context.read<GuestProvider>();
              final packagesProviderRef = context.read<PackagesProvider>();
              final loginProvider = context.read<LoginProvider>();
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MultiProvider(
                    providers: [
                      ChangeNotifierProvider<GuestProvider>.value(
                          value: guestProvider),
                      ChangeNotifierProvider<PackagesProvider>.value(
                          value: packagesProviderRef),
                      ChangeNotifierProvider<LoginProvider>.value(
                          value: loginProvider),
                    ],
                    child: AddGuestsDetail(),
                  ),
                  settings: const RouteSettings(name: '/AddGuestsDetail'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget packageCard(
    int index,
    PackagesListModel package,
    PackagesProvider provider,
  ) {
    final data =
        jsonDecode(package.itmOtherdet3 ?? '{}') as Map<String, dynamic>;
    final String gradientString =
        (data['background_gradient'] as String?) ?? '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 20),
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              gradient: gradientString.parseGradient(),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                CachedNetworkImage(
                  imageUrl: data['item_image'] ?? '',
                  height: double.infinity,
                  fit: BoxFit.fitHeight,
                ),
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
                          text: (package.itmTime ?? '').tr(),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 10, 20, 17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RefractedText(
                  text: package.itmDesc?.tr() ?? '',
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  textColor: AppColors.packageTextPrimary,
                ),
                const SizedBox(height: 2),
                if (package.irRate != null && package.irRate! > 0)
                  RefractedText(
                    text: /* ${_getCurrencySymbol(context)} */
                        '$currency ${package.irRate}',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    textColor: AppColors.packageTextPrimary,
                  ),
                const SizedBox(height: 11),
                if (package.itmMobdesc != null)
                  RefractedText(
                    text: (package.itmMobdesc ?? '').tr(),
                    fontSize: 14,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.w400,
                    textColor: AppColors.packageTextPrimary,
                  ),
                const SizedBox(
                  height: 10,
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () =>
                            pushPackageDetail(context, package, currency),
                        child: Transform.translate(
                          offset: const Offset(0, 1),
                          child: Column(
                            children: [
                              RefractedText(
                                text: 'LEARN MORE'.tr(),
                                fontSize: 12,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                fontWeight: FontWeight.w500,
                                textColor: AppColors.packageTextPrimary,
                                // decoration: TextDecoration.underline,
                              ),
                              Container(
                                height: 1,
                                width: 70,
                                color: Colors.grey.shade300,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      // The host passes this flag into the launcher, which sets
                      // the module-level [isBookingFlowEnabled] global. Booking's
                      // RemoteConfigService is never registered as a Provider
                      // (embedded or standalone), so reading it here crashed with
                      // ProviderNotFoundError once a package card rendered.
                      if (isBookingFlowEnabled)
                        InkWell(
                          onTap: () async {
                            provider.setBookingLoading(true);
                            setState(() {
                              loadingIndex = index;
                            });
                            try {
                              final gp = Provider.of<GuestProvider>(
                                context,
                                listen: false,
                              );
                              gp.showConfirmAppointmentDetails = false;

                              if (gp.guests.isNotEmpty) {
                                gp.guests.first.step =
                                    GuestStep.appointmentScheduling;
                              }

                              await gp.selectPackageAndProceed(
                                context,
                                package,
                              );

                              final prefs =
                                  await SharedPreferencesService.prefs;
                              final selectedIndex =
                                  prefs.getInt('selected_branch_index') ?? 0;

                              await provider.handleBranchSelection(
                                context,
                                selectedIndex,
                                isFromBranchList: false,
                              );

                              if (!mounted) return;
                              // The host Navigator sits above the launcher's
                              // MultiProvider, so forward the booking providers
                              // onto the pushed route or AddGuestsDetail throws
                              // ProviderNotFoundError.
                              final guestProvider =
                                  context.read<GuestProvider>();
                              final packagesProviderRef =
                                  context.read<PackagesProvider>();
                              final loginProvider =
                                  context.read<LoginProvider>();
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MultiProvider(
                                    providers: [
                                      ChangeNotifierProvider<GuestProvider>
                                          .value(value: guestProvider),
                                      ChangeNotifierProvider<PackagesProvider>
                                          .value(value: packagesProviderRef),
                                      ChangeNotifierProvider<LoginProvider>
                                          .value(value: loginProvider),
                                    ],
                                    child: AddGuestsDetail(),
                                  ),
                                  settings: const RouteSettings(
                                    name: '/AddGuestsDetail',
                                  ),
                                ),
                              );
                            } finally {
                              provider.setBookingLoading(false);
                            }
                          },
                          child: Container(
                            width: 80,
                            height: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: provider.isBookingNowButtonLoading &&
                                      loadingIndex == index
                                  ? const Color(0xFFF1B426).withOpacity(0.4)
                                  : const Color(0xFFF1B426),
                            ),
                            child: Center(
                              child: provider.isBookingNowButtonLoading &&
                                      loadingIndex == index
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primaryDark,
                                      ),
                                    )
                                  : const Text(
                                      'Book Now',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryDark,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
