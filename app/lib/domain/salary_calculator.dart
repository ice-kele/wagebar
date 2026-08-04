import '../data/models/salary_config.dart';
import '../data/models/attendance_record.dart';
import '../core/constants.dart';

/// 赚钱计算结果
class EarningResult {
  final double normalPay;     // 正常工时收入
  final double overtimePay;   // 加班收入
  final double total;          // 合计
  final bool isOvertime;       // 是否在加班中
  final double progress;       // 当日进度 0.0-1.0

  const EarningResult({
    required this.normalPay,
    required this.overtimePay,
    required this.total,
    required this.isOvertime,
    required this.progress,
  });

  factory EarningResult.zero() => const EarningResult(
        normalPay: 0,
        overtimePay: 0,
        total: 0,
        isOvertime: false,
        progress: 0,
      );
}

/// 加班结算结果
class OvertimeSettlement {
  final double hours;
  final double rate;
  final double hourlyPay;
  final double totalPay;

  const OvertimeSettlement({
    required this.hours,
    required this.rate,
    required this.hourlyPay,
    required this.totalPay,
  });

  factory OvertimeSettlement.zero() => const OvertimeSettlement(
        hours: 0,
        rate: 0,
        hourlyPay: 0,
        totalPay: 0,
      );
}

/// 判断日期类型，返回加班倍率
double _getOvertimeMultiplier(SalaryConfig config, DateTime date) {
  if (_isPublicHoliday(date)) {
    return config.overtimeRateHoliday;
  }
  if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
    return config.overtimeRateRestDay;
  }
  return config.overtimeRateWorkday;
}

/// 法定节假日判断（简化版，后续接入完整日历）
bool _isPublicHoliday(DateTime date) {
  // TODO: 接入国务院节假日表 API 或内置 2025-2030 日历
  return false;
}

/// 薪资计算引擎
///
/// 纯函数设计，所有方法无副作用，方便测试。
class SalaryCalculator {
  final SalaryConfig config;

  SalaryCalculator(this.config);

  /// 计算从上班到当前时刻的实时赚钱数据
  ///
  /// [clockIn] 实际上班打卡时间
  /// [now] 当前时间
  /// [scheduledClockOut] 计划下班时间
  EarningResult calculateRealtimeEarning({
    required DateTime clockIn,
    required DateTime now,
    required DateTime scheduledClockOut,
  }) {
    if (config.isEmpty) return EarningResult.zero();

    // ===== 正常工时收入 =====
    final normalEnd = now.isBefore(scheduledClockOut) ? now : scheduledClockOut;
    final normalDuration = normalEnd.difference(clockIn);
    final normalSeconds = normalDuration.inSeconds.clamp(0, 99999999);
    final normalPay = normalSeconds * config.perSecondSalary;

    // ===== 加班收入 =====
    double overtimePay = 0;
    if (now.isAfter(scheduledClockOut)) {
      final overtimeDuration = now.difference(scheduledClockOut);
      final overtimeSeconds = overtimeDuration.inSeconds.clamp(0, 99999999);
      final multiplier = _getOvertimeMultiplier(config, now);
      overtimePay = overtimeSeconds * config.perSecondSalary * multiplier;
    }

    // ===== 当日进度 =====
    final totalWorkDay = scheduledClockOut.difference(clockIn).inSeconds;
    final elapsed = now.difference(clockIn).inSeconds.clamp(0, totalWorkDay * 2);
    final progress = totalWorkDay > 0
        ? (elapsed / totalWorkDay).clamp(0.0, 1.0)
        : 0.0;

    return EarningResult(
      normalPay: _round2(normalPay),
      overtimePay: _round2(overtimePay),
      total: _round2(normalPay + overtimePay),
      isOvertime: now.isAfter(scheduledClockOut),
      progress: progress,
    );
  }

  /// 日终结算加班费
  ///
  /// [clockOut] 实际下班打卡时间
  OvertimeSettlement settleOvertime({
    required DateTime clockIn,
    required DateTime clockOut,
    required DateTime scheduledClockOut,
  }) {
    if (config.isEmpty || !clockOut.isAfter(scheduledClockOut)) {
      return OvertimeSettlement.zero();
    }

    final overtimeDuration = clockOut.difference(scheduledClockOut);
    var overtimeHours = overtimeDuration.inMinutes / 60.0;

    // 加班上限保护（防止忘打卡导致天价加班费）
    overtimeHours = overtimeHours.clamp(0, config.maxOvertimeHours);

    final rate = _getOvertimeMultiplier(config, clockIn);
    final hourlyRate = config.hourlySalary * rate;
    final totalPay = overtimeHours * hourlyRate;

    return OvertimeSettlement(
      hours: _round2(overtimeHours),
      rate: rate,
      hourlyPay: _round2(hourlyRate),
      totalPay: _round2(totalPay),
    );
  }

  /// 计算当前等级
  ({int level, String name, double current, double next, double progress}) {
    final earned = 0.0; // TODO: 从累计数据获取
    return _getLevelInfo(earned);
  }

  /// 根据累计金额计算等级信息
  static ({int level, String name, double current, double next, double progress})
      _getLevelInfo(double totalEarned) {
    final thresholds = WageBarConstants.levelThresholds;
    final names = WageBarConstants.levelNames;

    int level = 0;
    for (int i = 0; i < thresholds.length; i++) {
      if (totalEarned >= thresholds[i]) level = i;
    }

    final current = thresholds[level];
    final next = level < thresholds.length - 1 ? thresholds[level + 1] : current;
    final progress = next > current ? (totalEarned - current) / (next - current) : 1.0;

    return (
      level: level + 1,
      name: names[level],
      current: current,
      next: next,
      progress: progress.clamp(0.0, 1.0),
    );
  }

  /// 格式化金额为人民币字符串
  static String formatCNY(double amount) {
    if (amount >= 10000) {
      return '¥${(amount / 10000).toStringAsFixed(2)}万';
    }
    return '¥${amount.toStringAsFixed(2)}';
  }

  static double _round2(double v) => (v * 100).round() / 100;
}
