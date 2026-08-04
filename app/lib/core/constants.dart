/// WageBar 全局常量
class WageBarConstants {
  WageBarConstants._();

  /// 法定月计薪天数
  static const double legalWorkDaysPerMonth = 21.75;

  /// 标准日工时
  static const double standardDailyHours = 8.0;

  /// 加班倍率（中国劳动法）
  static const double overtimeRateWorkday = 1.5;   // 工作日延时
  static const double overtimeRateRestDay = 2.0;    // 休息日
  static const double overtimeRateHoliday = 3.0;    // 法定节假日

  /// 默认加班上限（小时/天）
  static const double defaultMaxOvertimeHours = 4.0;

  /// 打卡提醒偏移量（分钟）
  static const int clockInReminderOffset = 10;   // 上班前 10 分钟
  static const int overtimeDetectOffset = 30;     // 下班后 30 分钟检测加班

  /// 等级体系
  static const List<double> levelThresholds = [
    0,         // Lv.1 职场萌新
    3000,      // Lv.2 初级搬砖工
    10000,     // Lv.3 资深搬砖工
    30000,     // Lv.4 打工达人
    60000,     // Lv.5 职场老手
    100000,    // Lv.6 资深专家
    200000,    // Lv.7 打工皇帝
    500000,    // Lv.8 财务自由预备军
  ];

  static const List<String> levelNames = [
    '职场萌新',
    '初级搬砖工',
    '资深搬砖工',
    '打工达人',
    '职场老手',
    '资深专家',
    '打工皇帝',
    '财务自由预备军',
  ];
}
