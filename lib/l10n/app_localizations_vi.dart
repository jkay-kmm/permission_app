import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get sectionCustomize => 'TÙY CHỈNH';

  @override
  String get sectionDigitalWellbeing => 'SỨC KHỎE SỐ';

  @override
  String get sectionDigitalHealth => 'SỨC KHỎE SỐ';

  @override
  String get sectionSupport => 'HỖ TRỢ';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get languageTitle => 'Ngôn ngữ';

  @override
  String get languageSubtitle => 'Ngôn ngữ hiển thị trong ứng dụng';

  @override
  String get languagePickerTitle => 'Ngôn ngữ';

  @override
  String get languagePickerSubtitle => 'Chọn ngôn ngữ bạn muốn sử dụng';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String get languageEnglish => 'Tiếng Anh';

  @override
  String get appearance => 'Giao diện';

  @override
  String get themeTitle => 'Giao diện';

  @override
  String get themeSubtitle => 'Chọn chế độ sáng hoặc tối';

  @override
  String get themePickerTitle => 'Giao diện';

  @override
  String get themePickerSubtitle => 'Chọn giao diện phù hợp với bạn';

  @override
  String get appearanceSubtitle => 'Chọn chế độ sáng hoặc tối';

  @override
  String get appearancePickerSubtitle => 'Chọn giao diện phù hợp với bạn';

  @override
  String get themeSystem => 'Theo hệ thống';

  @override
  String get themeLight => 'Sáng';

  @override
  String get themeDark => 'Tối';

  @override
  String get reminderTitle => 'Nhắc nhở lúc 21:00';

  @override
  String get reminderSubtitle => 'Thông báo tổng thời gian dùng điện thoại mỗi tối';

  @override
  String get dailyReminderTitle => 'Nhắc nhở lúc 21:00';

  @override
  String get dailyReminderSubtitle => 'Thông báo tổng thời gian dùng điện thoại mỗi tối';

  @override
  String get surroundingWatchTitle => 'Quan sát xung quanh';

  @override
  String get surroundingWatchSubtitle => 'Nhắc bạn rời mắt khỏi màn hình';

  @override
  String get lookAroundTitle => 'Quan sát xung quanh';

  @override
  String get lookAroundSubtitle => 'Nhắc bạn rời mắt khỏi màn hình';

  @override
  String get sleepModeTitle => 'Chế độ đi ngủ';

  @override
  String get sleepModeSubtitle => 'Tạo khoảng nghỉ trước giờ ngủ';

  @override
  String get bedtimeTitle => 'Chế độ đi ngủ';

  @override
  String get bedtimeSubtitle => 'Tạo khoảng nghỉ trước giờ ngủ';

  @override
  String get comingSoon => 'Sắp có';

  @override
  String get comingSoonBadge => 'Sắp có';

  @override
  String get comingSoonMessage => 'Tính năng này đang được hoàn thiện và sẽ sớm có mặt trong bản cập nhật tiếp theo.';

  @override
  String get understood => 'Đã hiểu';

  @override
  String get gotIt => 'Đã hiểu';

  @override
  String get contactUsTitle => 'Liên hệ với chúng tôi';

  @override
  String get contactUsSubtitle => 'Góp ý hoặc báo cáo sự cố';

  @override
  String get contactTitle => 'Liên hệ với chúng tôi';

  @override
  String get contactSubtitle => 'Góp ý hoặc báo cáo sự cố';

  @override
  String get privacyPolicyTitle => 'Chính sách quyền riêng tư';

  @override
  String get privacyPolicySubtitle => 'Cách Brainrot bảo vệ dữ liệu của bạn';

  @override
  String get privacyTitle => 'Chính sách quyền riêng tư';

  @override
  String get privacySubtitle => 'Cách Brainrot bảo vệ dữ liệu của bạn';

  @override
  String get version => 'Phiên bản';

  @override
  String appVersion(String version) {
    return 'Phiên bản $version';
  }

  @override
  String get navHome => 'Trang chủ';

  @override
  String get navCalendar => 'Lịch';

  @override
  String get navBlock => 'Chặn';

  @override
  String get navSettings => 'Cài đặt';

  @override
  String get blockingRulesTitle => 'Quy tắc chặn';

  @override
  String get blockAppFab => 'Chặn ứng dụng';

  @override
  String rulesListLabel(int count) {
    return '$count quy tắc';
  }

  @override
  String get noAvailableApps => 'Không tìm thấy ứng dụng nào';

  @override
  String addedBlockRule(String appName) {
    return 'Đã thêm quy tắc chặn cho $appName';
  }

  @override
  String get blockTypeAllDay => 'Chặn cả ngày';

  @override
  String get blockTypeTimeLimit => 'Giới hạn thời gian';

  @override
  String get blockTypeSchedule => 'Lịch trình';

  @override
  String get blockTypeFocusMode => 'Chế độ tập trung';

  @override
  String get confirmDeleteTitle => 'Xóa quy tắc';

  @override
  String confirmDeleteMessage(String ruleName) {
    return 'Bạn có chắc muốn xóa \"$ruleName\" không?';
  }

  @override
  String get cancel => 'Hủy';

  @override
  String get delete => 'Xóa';

  @override
  String get permissionBannerTitle => 'Cần quyền Trợ năng';

  @override
  String get permissionBannerSubtitle => 'Bật dịch vụ Trợ năng để chặn ứng dụng khi được mở.';

  @override
  String get permissionBannerButton => 'Bật';

  @override
  String appsApplied(int count) {
    return '$count ứng dụng';
  }

  @override
  String get deleteTooltip => 'Xóa quy tắc';

  @override
  String get emptyRulesTitle => 'Chưa có quy tắc nào';

  @override
  String get emptyRulesSubtitle => 'Nhấn nút bên dưới để chặn ứng dụng đầu tiên và lấy lại sự tập trung.';

  @override
  String get addFirstApp => 'Chặn ứng dụng';

  @override
  String get appPickerTitle => 'Chọn ứng dụng';

  @override
  String get appPickerSubtitle => 'Chọn ứng dụng bạn muốn chặn';

  @override
  String get searchAppsHint => 'Tìm kiếm ứng dụng...';

  @override
  String get noAppsFound => 'Không tìm thấy ứng dụng';

  @override
  String get calendarReportTitle => 'Báo cáo sử dụng';

  @override
  String get usageStats => 'Thời gian dùng ứng dụng';

  @override
  String get totalTime => 'Tổng thời gian';

  @override
  String get noUsageData => 'Không có dữ liệu sử dụng ngày này';

  @override
  String get topAppsTitle => 'ỨNG DỤNG NHIỀU NHẤT';

  @override
  String todayLabel(int day, int month) {
    return 'Hôm nay, $day/$month';
  }

  @override
  String get loadingUsage => 'Đang tải dữ liệu...';

  @override
  String get retry => 'Thử lại';

  @override
  String get homeScoreSubtitle => 'Điểm sức khỏe não bộ';

  @override
  String get totalScreenTime => 'Tổng thời gian màn hình';

  @override
  String get appsLabel => 'Ứng dụng';

  @override
  String get applicationsLabel => 'Ứng dụng';

  @override
  String get reminderScreenTitle => 'Nhắc nhở hàng ngày';

  @override
  String get todayPhoneUsage => 'Thời gian dùng điện thoại hôm nay';

  @override
  String get noPermission => 'Chưa cấp quyền';

  @override
  String get permissionWarning => 'Chưa cấp quyền theo dõi sử dụng. Hãy cấp quyền để theo dõi thời gian màn hình.';

  @override
  String get grantPermission => 'Cấp quyền';

  @override
  String get notificationPermissionRequest => 'Cần quyền thông báo để gửi nhắc nhở.';

  @override
  String get notificationPermissionDenied => 'Quyền thông báo bị từ chối.';

  @override
  String get testNotificationSuccess => 'Đã gửi thông báo thử nghiệm!';

  @override
  String get dailyReminderToggleTitle => 'Nhắc nhở lúc 21:00';

  @override
  String get dailyReminderToggleSubtitle => 'Thông báo tổng thời gian dùng điện thoại mỗi tối';

  @override
  String get testNotificationButton => 'Gửi thông báo thử';

  @override
  String get batteryTipTitle => 'Tối ưu hóa pin';

  @override
  String get batteryTipBody => 'Để nhận thông báo nền ổn định, hãy tắt tối ưu hóa pin cho Brainrot. Điều này đảm bảo thông báo được gửi ngay cả khi ứng dụng chạy nền.';

  @override
  String get batteryOptimizationLink => 'Tắt tối ưu hóa pin';
}
