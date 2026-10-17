import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settingsTitle => 'Settings';

  @override
  String get sectionCustomize => 'CUSTOMIZE';

  @override
  String get sectionDigitalWellbeing => 'DIGITAL WELLBEING';

  @override
  String get sectionDigitalHealth => 'DIGITAL HEALTH';

  @override
  String get sectionSupport => 'SUPPORT';

  @override
  String get language => 'Language';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSubtitle => 'Display language of the app';

  @override
  String get languagePickerTitle => 'Language';

  @override
  String get languagePickerSubtitle => 'Choose the language you want to use';

  @override
  String get languageVietnamese => 'Vietnamese';

  @override
  String get languageEnglish => 'English';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeTitle => 'Appearance';

  @override
  String get themeSubtitle => 'Choose light or dark mode';

  @override
  String get themePickerTitle => 'Appearance';

  @override
  String get themePickerSubtitle => 'Choose the appearance that suits you';

  @override
  String get appearanceSubtitle => 'Choose light or dark mode';

  @override
  String get appearancePickerSubtitle => 'Choose the appearance that suits you';

  @override
  String get themeSystem => 'System default';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get reminderTitle => 'Reminder at 21:00';

  @override
  String get reminderSubtitle => 'Get your total screen time notification every evening';

  @override
  String get dailyReminderTitle => 'Reminder at 21:00';

  @override
  String get dailyReminderSubtitle => 'Get your total screen time notification every evening';

  @override
  String get surroundingWatchTitle => 'Look around';

  @override
  String get surroundingWatchSubtitle => 'Reminds you to look away from the screen';

  @override
  String get lookAroundTitle => 'Look around';

  @override
  String get lookAroundSubtitle => 'Reminds you to look away from the screen';

  @override
  String get sleepModeTitle => 'Bedtime mode';

  @override
  String get sleepModeSubtitle => 'Create a break before bedtime';

  @override
  String get bedtimeTitle => 'Bedtime mode';

  @override
  String get bedtimeSubtitle => 'Create a break before bedtime';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get comingSoonBadge => 'Coming soon';

  @override
  String get comingSoonMessage => 'This feature is being polished and will be available in an upcoming update.';

  @override
  String get understood => 'Got it';

  @override
  String get gotIt => 'Got it';

  @override
  String get contactUsTitle => 'Contact us';

  @override
  String get contactUsSubtitle => 'Send feedback or report an issue';

  @override
  String get contactTitle => 'Contact us';

  @override
  String get contactSubtitle => 'Send feedback or report an issue';

  @override
  String get privacyPolicyTitle => 'Privacy policy';

  @override
  String get privacyPolicySubtitle => 'How Brainrot protects your data';

  @override
  String get privacyTitle => 'Privacy policy';

  @override
  String get privacySubtitle => 'How Brainrot protects your data';

  @override
  String get version => 'Version';

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String get navHome => 'Home';

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navBlock => 'Block';

  @override
  String get navSettings => 'Settings';

  @override
  String get blockingRulesTitle => 'Blocking Rules';

  @override
  String get blockAppFab => 'Block App';

  @override
  String rulesListLabel(int count) {
    return '$count rules';
  }

  @override
  String get noAvailableApps => 'No available apps found';

  @override
  String addedBlockRule(String appName) {
    return 'Added block rule for $appName';
  }

  @override
  String get blockTypeAllDay => 'All Day Block';

  @override
  String get blockTypeTimeLimit => 'Time Limit';

  @override
  String get blockTypeSchedule => 'Schedule';

  @override
  String get blockTypeFocusMode => 'Focus Mode';

  @override
  String get confirmDeleteTitle => 'Delete Rule';

  @override
  String confirmDeleteMessage(String ruleName) {
    return 'Are you sure you want to delete \"$ruleName\"?';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get permissionBannerTitle => 'Accessibility Permission Required';

  @override
  String get permissionBannerSubtitle => 'Enable Accessibility Service to block apps when they are opened.';

  @override
  String get permissionBannerButton => 'Enable';

  @override
  String appsApplied(int count) {
    return '$count apps';
  }

  @override
  String get deleteTooltip => 'Delete rule';

  @override
  String get emptyRulesTitle => 'No Rules Yet';

  @override
  String get emptyRulesSubtitle => 'Tap the button below to block your first app and regain focus.';

  @override
  String get addFirstApp => 'Block an App';

  @override
  String get appPickerTitle => 'Choose an App';

  @override
  String get appPickerSubtitle => 'Select an app to block';

  @override
  String get searchAppsHint => 'Search apps...';

  @override
  String get noAppsFound => 'No apps found';

  @override
  String get calendarReportTitle => 'Usage Report';

  @override
  String get usageStats => 'App Usage';

  @override
  String get totalTime => 'Total time';

  @override
  String get noUsageData => 'No usage data for this day';

  @override
  String get topAppsTitle => 'TOP APPS';

  @override
  String todayLabel(int day, int month) {
    return 'Today, $day/$month';
  }

  @override
  String get loadingUsage => 'Loading usage data...';

  @override
  String get retry => 'Retry';

  @override
  String get homeScoreSubtitle => 'Brain health score';

  @override
  String get totalScreenTime => 'Total Screen Time';

  @override
  String get appsLabel => 'Apps';

  @override
  String get applicationsLabel => 'Applications';

  @override
  String get reminderScreenTitle => 'Daily Reminder';

  @override
  String get todayPhoneUsage => 'Today\'s phone usage';

  @override
  String get noPermission => 'No Permission';

  @override
  String get permissionWarning => 'Usage permission not granted. Grant permission to track your screen time.';

  @override
  String get grantPermission => 'Grant';

  @override
  String get notificationPermissionRequest => 'Notification permission is required to send reminders.';

  @override
  String get notificationPermissionDenied => 'Notification permission denied.';

  @override
  String get testNotificationSuccess => 'Test notification sent!';

  @override
  String get dailyReminderToggleTitle => 'Reminder at 21:00';

  @override
  String get dailyReminderToggleSubtitle => 'Get your total screen time notification every evening';

  @override
  String get testNotificationButton => 'Send Test Notification';

  @override
  String get batteryTipTitle => 'Battery Optimization';

  @override
  String get batteryTipBody => 'For reliable background reminders, disable battery optimization for Brainrot. This ensures notifications are delivered even when the app is in the background.';

  @override
  String get batteryOptimizationLink => 'Disable battery optimization';
}
