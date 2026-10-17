import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi')
  ];

  /// No description provided for @settingsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get settingsTitle;

  /// No description provided for @sectionCustomize.
  ///
  /// In vi, this message translates to:
  /// **'TÙY CHỈNH'**
  String get sectionCustomize;

  /// No description provided for @sectionDigitalWellbeing.
  ///
  /// In vi, this message translates to:
  /// **'SỨC KHỎE SỐ'**
  String get sectionDigitalWellbeing;

  /// No description provided for @sectionDigitalHealth.
  ///
  /// In vi, this message translates to:
  /// **'SỨC KHỎE SỐ'**
  String get sectionDigitalHealth;

  /// No description provided for @sectionSupport.
  ///
  /// In vi, this message translates to:
  /// **'HỖ TRỢ'**
  String get sectionSupport;

  /// No description provided for @language.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ'**
  String get language;

  /// No description provided for @languageTitle.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ'**
  String get languageTitle;

  /// No description provided for @languageSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ hiển thị trong ứng dụng'**
  String get languageSubtitle;

  /// No description provided for @languagePickerTitle.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ'**
  String get languagePickerTitle;

  /// No description provided for @languagePickerSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ngôn ngữ bạn muốn sử dụng'**
  String get languagePickerSubtitle;

  /// No description provided for @languageVietnamese.
  ///
  /// In vi, this message translates to:
  /// **'Tiếng Việt'**
  String get languageVietnamese;

  /// No description provided for @languageEnglish.
  ///
  /// In vi, this message translates to:
  /// **'Tiếng Anh'**
  String get languageEnglish;

  /// No description provided for @appearance.
  ///
  /// In vi, this message translates to:
  /// **'Giao diện'**
  String get appearance;

  /// No description provided for @themeTitle.
  ///
  /// In vi, this message translates to:
  /// **'Giao diện'**
  String get themeTitle;

  /// No description provided for @themeSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Chọn chế độ sáng hoặc tối'**
  String get themeSubtitle;

  /// No description provided for @themePickerTitle.
  ///
  /// In vi, this message translates to:
  /// **'Giao diện'**
  String get themePickerTitle;

  /// No description provided for @themePickerSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Chọn giao diện phù hợp với bạn'**
  String get themePickerSubtitle;

  /// No description provided for @appearanceSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Chọn chế độ sáng hoặc tối'**
  String get appearanceSubtitle;

  /// No description provided for @appearancePickerSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Chọn giao diện phù hợp với bạn'**
  String get appearancePickerSubtitle;

  /// No description provided for @themeSystem.
  ///
  /// In vi, this message translates to:
  /// **'Theo hệ thống'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In vi, this message translates to:
  /// **'Sáng'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In vi, this message translates to:
  /// **'Tối'**
  String get themeDark;

  /// No description provided for @reminderTitle.
  ///
  /// In vi, this message translates to:
  /// **'Nhắc nhở lúc 21:00'**
  String get reminderTitle;

  /// No description provided for @reminderSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Thông báo tổng thời gian dùng điện thoại mỗi tối'**
  String get reminderSubtitle;

  /// No description provided for @dailyReminderTitle.
  ///
  /// In vi, this message translates to:
  /// **'Nhắc nhở lúc 21:00'**
  String get dailyReminderTitle;

  /// No description provided for @dailyReminderSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Thông báo tổng thời gian dùng điện thoại mỗi tối'**
  String get dailyReminderSubtitle;

  /// No description provided for @surroundingWatchTitle.
  ///
  /// In vi, this message translates to:
  /// **'Quan sát xung quanh'**
  String get surroundingWatchTitle;

  /// No description provided for @surroundingWatchSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Nhắc bạn rời mắt khỏi màn hình'**
  String get surroundingWatchSubtitle;

  /// No description provided for @lookAroundTitle.
  ///
  /// In vi, this message translates to:
  /// **'Quan sát xung quanh'**
  String get lookAroundTitle;

  /// No description provided for @lookAroundSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Nhắc bạn rời mắt khỏi màn hình'**
  String get lookAroundSubtitle;

  /// No description provided for @sleepModeTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chế độ đi ngủ'**
  String get sleepModeTitle;

  /// No description provided for @sleepModeSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Tạo khoảng nghỉ trước giờ ngủ'**
  String get sleepModeSubtitle;

  /// No description provided for @bedtimeTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chế độ đi ngủ'**
  String get bedtimeTitle;

  /// No description provided for @bedtimeSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Tạo khoảng nghỉ trước giờ ngủ'**
  String get bedtimeSubtitle;

  /// No description provided for @comingSoon.
  ///
  /// In vi, this message translates to:
  /// **'Sắp có'**
  String get comingSoon;

  /// No description provided for @comingSoonBadge.
  ///
  /// In vi, this message translates to:
  /// **'Sắp có'**
  String get comingSoonBadge;

  /// No description provided for @comingSoonMessage.
  ///
  /// In vi, this message translates to:
  /// **'Tính năng này đang được hoàn thiện và sẽ sớm có mặt trong bản cập nhật tiếp theo.'**
  String get comingSoonMessage;

  /// No description provided for @understood.
  ///
  /// In vi, this message translates to:
  /// **'Đã hiểu'**
  String get understood;

  /// No description provided for @gotIt.
  ///
  /// In vi, this message translates to:
  /// **'Đã hiểu'**
  String get gotIt;

  /// No description provided for @contactUsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Liên hệ với chúng tôi'**
  String get contactUsTitle;

  /// No description provided for @contactUsSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Góp ý hoặc báo cáo sự cố'**
  String get contactUsSubtitle;

  /// No description provided for @contactTitle.
  ///
  /// In vi, this message translates to:
  /// **'Liên hệ với chúng tôi'**
  String get contactTitle;

  /// No description provided for @contactSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Góp ý hoặc báo cáo sự cố'**
  String get contactSubtitle;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chính sách quyền riêng tư'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicySubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Cách Brainrot bảo vệ dữ liệu của bạn'**
  String get privacyPolicySubtitle;

  /// No description provided for @privacyTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chính sách quyền riêng tư'**
  String get privacyTitle;

  /// No description provided for @privacySubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Cách Brainrot bảo vệ dữ liệu của bạn'**
  String get privacySubtitle;

  /// No description provided for @version.
  ///
  /// In vi, this message translates to:
  /// **'Phiên bản'**
  String get version;

  /// No description provided for @appVersion.
  ///
  /// In vi, this message translates to:
  /// **'Phiên bản {version}'**
  String appVersion(String version);

  /// No description provided for @navHome.
  ///
  /// In vi, this message translates to:
  /// **'Trang chủ'**
  String get navHome;

  /// No description provided for @navCalendar.
  ///
  /// In vi, this message translates to:
  /// **'Lịch'**
  String get navCalendar;

  /// No description provided for @navBlock.
  ///
  /// In vi, this message translates to:
  /// **'Chặn'**
  String get navBlock;

  /// No description provided for @navSettings.
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get navSettings;

  /// No description provided for @blockingRulesTitle.
  ///
  /// In vi, this message translates to:
  /// **'Quy tắc chặn'**
  String get blockingRulesTitle;

  /// No description provided for @blockAppFab.
  ///
  /// In vi, this message translates to:
  /// **'Chặn ứng dụng'**
  String get blockAppFab;

  /// No description provided for @rulesListLabel.
  ///
  /// In vi, this message translates to:
  /// **'{count} quy tắc'**
  String rulesListLabel(int count);

  /// No description provided for @noAvailableApps.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy ứng dụng nào'**
  String get noAvailableApps;

  /// No description provided for @addedBlockRule.
  ///
  /// In vi, this message translates to:
  /// **'Đã thêm quy tắc chặn cho {appName}'**
  String addedBlockRule(String appName);

  /// No description provided for @blockTypeAllDay.
  ///
  /// In vi, this message translates to:
  /// **'Chặn cả ngày'**
  String get blockTypeAllDay;

  /// No description provided for @blockTypeTimeLimit.
  ///
  /// In vi, this message translates to:
  /// **'Giới hạn thời gian'**
  String get blockTypeTimeLimit;

  /// No description provided for @blockTypeSchedule.
  ///
  /// In vi, this message translates to:
  /// **'Lịch trình'**
  String get blockTypeSchedule;

  /// No description provided for @blockTypeFocusMode.
  ///
  /// In vi, this message translates to:
  /// **'Chế độ tập trung'**
  String get blockTypeFocusMode;

  /// No description provided for @confirmDeleteTitle.
  ///
  /// In vi, this message translates to:
  /// **'Xóa quy tắc'**
  String get confirmDeleteTitle;

  /// No description provided for @confirmDeleteMessage.
  ///
  /// In vi, this message translates to:
  /// **'Bạn có chắc muốn xóa \"{ruleName}\" không?'**
  String confirmDeleteMessage(String ruleName);

  /// No description provided for @cancel.
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In vi, this message translates to:
  /// **'Xóa'**
  String get delete;

  /// No description provided for @permissionBannerTitle.
  ///
  /// In vi, this message translates to:
  /// **'Cần quyền Trợ năng'**
  String get permissionBannerTitle;

  /// No description provided for @permissionBannerSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Bật dịch vụ Trợ năng để chặn ứng dụng khi được mở.'**
  String get permissionBannerSubtitle;

  /// No description provided for @permissionBannerButton.
  ///
  /// In vi, this message translates to:
  /// **'Bật'**
  String get permissionBannerButton;

  /// No description provided for @appsApplied.
  ///
  /// In vi, this message translates to:
  /// **'{count} ứng dụng'**
  String appsApplied(int count);

  /// No description provided for @deleteTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Xóa quy tắc'**
  String get deleteTooltip;

  /// No description provided for @emptyRulesTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có quy tắc nào'**
  String get emptyRulesTitle;

  /// No description provided for @emptyRulesSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Nhấn nút bên dưới để chặn ứng dụng đầu tiên và lấy lại sự tập trung.'**
  String get emptyRulesSubtitle;

  /// No description provided for @addFirstApp.
  ///
  /// In vi, this message translates to:
  /// **'Chặn ứng dụng'**
  String get addFirstApp;

  /// No description provided for @appPickerTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ứng dụng'**
  String get appPickerTitle;

  /// No description provided for @appPickerSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ứng dụng bạn muốn chặn'**
  String get appPickerSubtitle;

  /// No description provided for @searchAppsHint.
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm ứng dụng...'**
  String get searchAppsHint;

  /// No description provided for @noAppsFound.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy ứng dụng'**
  String get noAppsFound;

  /// No description provided for @calendarReportTitle.
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo sử dụng'**
  String get calendarReportTitle;

  /// No description provided for @usageStats.
  ///
  /// In vi, this message translates to:
  /// **'Thời gian dùng ứng dụng'**
  String get usageStats;

  /// No description provided for @totalTime.
  ///
  /// In vi, this message translates to:
  /// **'Tổng thời gian'**
  String get totalTime;

  /// No description provided for @noUsageData.
  ///
  /// In vi, this message translates to:
  /// **'Không có dữ liệu sử dụng ngày này'**
  String get noUsageData;

  /// No description provided for @topAppsTitle.
  ///
  /// In vi, this message translates to:
  /// **'ỨNG DỤNG NHIỀU NHẤT'**
  String get topAppsTitle;

  /// No description provided for @todayLabel.
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay, {day}/{month}'**
  String todayLabel(int day, int month);

  /// No description provided for @loadingUsage.
  ///
  /// In vi, this message translates to:
  /// **'Đang tải dữ liệu...'**
  String get loadingUsage;

  /// No description provided for @retry.
  ///
  /// In vi, this message translates to:
  /// **'Thử lại'**
  String get retry;

  /// No description provided for @homeScoreSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Điểm sức khỏe não bộ'**
  String get homeScoreSubtitle;

  /// No description provided for @totalScreenTime.
  ///
  /// In vi, this message translates to:
  /// **'Tổng thời gian màn hình'**
  String get totalScreenTime;

  /// No description provided for @appsLabel.
  ///
  /// In vi, this message translates to:
  /// **'Ứng dụng'**
  String get appsLabel;

  /// No description provided for @applicationsLabel.
  ///
  /// In vi, this message translates to:
  /// **'Ứng dụng'**
  String get applicationsLabel;

  /// No description provided for @reminderScreenTitle.
  ///
  /// In vi, this message translates to:
  /// **'Nhắc nhở hàng ngày'**
  String get reminderScreenTitle;

  /// No description provided for @todayPhoneUsage.
  ///
  /// In vi, this message translates to:
  /// **'Thời gian dùng điện thoại hôm nay'**
  String get todayPhoneUsage;

  /// No description provided for @noPermission.
  ///
  /// In vi, this message translates to:
  /// **'Chưa cấp quyền'**
  String get noPermission;

  /// No description provided for @permissionWarning.
  ///
  /// In vi, this message translates to:
  /// **'Chưa cấp quyền theo dõi sử dụng. Hãy cấp quyền để theo dõi thời gian màn hình.'**
  String get permissionWarning;

  /// No description provided for @grantPermission.
  ///
  /// In vi, this message translates to:
  /// **'Cấp quyền'**
  String get grantPermission;

  /// No description provided for @notificationPermissionRequest.
  ///
  /// In vi, this message translates to:
  /// **'Cần quyền thông báo để gửi nhắc nhở.'**
  String get notificationPermissionRequest;

  /// No description provided for @notificationPermissionDenied.
  ///
  /// In vi, this message translates to:
  /// **'Quyền thông báo bị từ chối.'**
  String get notificationPermissionDenied;

  /// No description provided for @testNotificationSuccess.
  ///
  /// In vi, this message translates to:
  /// **'Đã gửi thông báo thử nghiệm!'**
  String get testNotificationSuccess;

  /// No description provided for @dailyReminderToggleTitle.
  ///
  /// In vi, this message translates to:
  /// **'Nhắc nhở lúc 21:00'**
  String get dailyReminderToggleTitle;

  /// No description provided for @dailyReminderToggleSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Thông báo tổng thời gian dùng điện thoại mỗi tối'**
  String get dailyReminderToggleSubtitle;

  /// No description provided for @testNotificationButton.
  ///
  /// In vi, this message translates to:
  /// **'Gửi thông báo thử'**
  String get testNotificationButton;

  /// No description provided for @batteryTipTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tối ưu hóa pin'**
  String get batteryTipTitle;

  /// No description provided for @batteryTipBody.
  ///
  /// In vi, this message translates to:
  /// **'Để nhận thông báo nền ổn định, hãy tắt tối ưu hóa pin cho Brainrot. Điều này đảm bảo thông báo được gửi ngay cả khi ứng dụng chạy nền.'**
  String get batteryTipBody;

  /// No description provided for @batteryOptimizationLink.
  ///
  /// In vi, this message translates to:
  /// **'Tắt tối ưu hóa pin'**
  String get batteryOptimizationLink;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'vi': return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
