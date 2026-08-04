/// 薪资配置模型
class SalaryConfig {
  final double monthlySalary;      // 月薪（税前）
  final double workDaysPerMonth;   // 月计薪天数
  final double dailyHours;         // 日工时
  final double lunchBreakHours;    // 午休时长
  final double maxOvertimeHours;   // 每日加班上限

  // 加班倍率（可自定义）
  final double overtimeRateWorkday;
  final double overtimeRateRestDay;
  final double overtimeRateHoliday;

  const SalaryConfig({
    required this.monthlySalary,
    this.workDaysPerMonth = 21.75,
    this.dailyHours = 8.0,
    this.lunchBreakHours = 1.0,
    this.maxOvertimeHours = 4.0,
    this.overtimeRateWorkday = 1.5,
    this.overtimeRateRestDay = 2.0,
    this.overtimeRateHoliday = 3.0,
  });

  /// 默认配置（未设置薪资时占位）
  factory SalaryConfig.empty() => const SalaryConfig(monthlySalary: 0);

  bool get isEmpty => monthlySalary <= 0;

  // ===== 衍生计算（纯函数，无副作用） =====

  /// 日薪
  double get dailySalary => monthlySalary / workDaysPerMonth;

  /// 时薪
  double get hourlySalary => dailySalary / dailyHours;

  /// 秒薪
  double get perSecondSalary => hourlySalary / 3600;

  /// 工作日加班时薪
  double get overtimeHourlyWorkday => hourlySalary * overtimeRateWorkday;

  /// 休息日加班时薪
  double get overtimeHourlyRestDay => hourlySalary * overtimeRateRestDay;

  /// 法定假日加班时薪
  double get overtimeHourlyHoliday => hourlySalary * overtimeRateHoliday;

  /// 实际工作秒薪（扣除午休）
  double get effectivePerSecondSalary =>
      dailySalary / ((dailyHours + lunchBreakHours) * 3600);

  Map<String, dynamic> toJson() => {
        'monthlySalary': monthlySalary,
        'workDaysPerMonth': workDaysPerMonth,
        'dailyHours': dailyHours,
        'lunchBreakHours': lunchBreakHours,
        'maxOvertimeHours': maxOvertimeHours,
        'overtimeRateWorkday': overtimeRateWorkday,
        'overtimeRateRestDay': overtimeRateRestDay,
        'overtimeRateHoliday': overtimeRateHoliday,
      };

  factory SalaryConfig.fromJson(Map<String, dynamic> json) => SalaryConfig(
        monthlySalary: (json['monthlySalary'] as num?)?.toDouble() ?? 0,
        workDaysPerMonth: (json['workDaysPerMonth'] as num?)?.toDouble() ?? 21.75,
        dailyHours: (json['dailyHours'] as num?)?.toDouble() ?? 8.0,
        lunchBreakHours: (json['lunchBreakHours'] as num?)?.toDouble() ?? 1.0,
        maxOvertimeHours: (json['maxOvertimeHours'] as num?)?.toDouble() ?? 4.0,
        overtimeRateWorkday: (json['overtimeRateWorkday'] as num?)?.toDouble() ?? 1.5,
        overtimeRateRestDay: (json['overtimeRateRestDay'] as num?)?.toDouble() ?? 2.0,
        overtimeRateHoliday: (json['overtimeRateHoliday'] as num?)?.toDouble() ?? 3.0,
      );

  SalaryConfig copyWith({
    double? monthlySalary,
    double? workDaysPerMonth,
    double? dailyHours,
    double? lunchBreakHours,
    double? maxOvertimeHours,
    double? overtimeRateWorkday,
    double? overtimeRateRestDay,
    double? overtimeRateHoliday,
  }) =>
      SalaryConfig(
        monthlySalary: monthlySalary ?? this.monthlySalary,
        workDaysPerMonth: workDaysPerMonth ?? this.workDaysPerMonth,
        dailyHours: dailyHours ?? this.dailyHours,
        lunchBreakHours: lunchBreakHours ?? this.lunchBreakHours,
        maxOvertimeHours: maxOvertimeHours ?? this.maxOvertimeHours,
        overtimeRateWorkday: overtimeRateWorkday ?? this.overtimeRateWorkday,
        overtimeRateRestDay: overtimeRateRestDay ?? this.overtimeRateRestDay,
        overtimeRateHoliday: overtimeRateHoliday ?? this.overtimeRateHoliday,
      );
}
