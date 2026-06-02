// Storage Keys
const String kIsOnboardingSeen = "onboard";
const String kSelectedCountry = "country";
const String kSelectedLanguage = "language";
const String kCurrentDbPtr = "dbptr";
const String kCurrentBaseUrl = "url";
const String kCurrentPdfUrl = "pdfUrl";
const String kCurrentChatUrl = "chatUrl";
const String kToken = "token";
const String kDeviceId = "device_id";
const String kRefresh = "refresh";
const String kSelectedBranch = "branch";
const String kSelectedBranchDbptr = "selected_branch_dbptr";
const String packageAddressDesc = 'pkgDesc';
const String packageAddress1 = 'pkgAdress1';
const String packageAddress2 = 'pkgAddress2';
const String packageAddress3 = 'pkgAddress3';
const String packagePincode = 'pkgPincode';
const String firmptr = 'firmPtr';
const String branchptr = 'branchptr';
const String session = 'session_id';
const String latitude = 'latitude';
const String longitude = 'longitude';
const String currency = 'currency';
const String privacyUrl = 'privacy_url';
const String kIsShareEnabled = "is_share_enabled";
const String kRazorpayKey = "razorpay_key";
const String kIsReferEnabled = "is_refer_enabled";
const String kIsHealthScoreEnabled = "is_scoring_enabled";
const String kIsBookingFlowEnabled = "is_booking_flow_enabled";
const String kIsSyncareLinkEnabled = "is_syncare_link_enabled";
const String kIsGuestBookingEnabled = "is_guest_booking_enabled";
const String kIsDetailedResultsEnabled = "is_detailedResults_enabled";
const String kIsHealthplanEnabled = "is_health_plan_enabled";
const String kIsEmailLoginEnabled = "is_email_login_enabled";
const String kIsMobileLoginEnabled = "is_mobile_login_enabled";
const String kIsUsernameLoginEnabled = "is_username_login_enabled";

/// Whether the booking module is running standalone (not embedded in a host
/// app). Set by `BookingFlowLauncher` from the host-supplied flag.
bool isStandalone = false;

/// Resolves a bundled asset to the path that exists in the current run mode.
///
/// Standalone, the root pubspec registers assets at their bare `assets/...`
/// key. As a dependency, the same assets live under `packages/booking/...`.
String bookingAssetPath(String path) =>
    isStandalone ? path : 'packages/booking/$path';
