import '../data/models/achievement.dart';

/// 预设成就定义
///
/// 采用快照重算模式：每次用户数据变更时，对所有成就重新执行 checker，
/// 幂等写入，避免事件状态机的漏触发问题。
final List<Achievement> predefinedAchievements = [
  // ===== 打卡类 =====
  Achievement(
    id: 'attendance_7_days',
    name: '打工魂觉醒',
    description: '连续打卡 7 天',
    icon: '🏆',
    category: AchievementCategory.attendance,
    checker: (s) => s.consecutiveDays >= 7,
  ),
  Achievement(
    id: 'attendance_100_days',
    name: '打工百日',
    description: '累计使用 100 天',
    icon: '💯',
    category: AchievementCategory.attendance,
    checker: (s) => s.totalDays >= 100,
  ),

  // ===== 加班类 =====
  Achievement(
    id: 'overtime_month_20',
    name: '卷王之王',
    description: '单月加班超过 20 小时',
    icon: '👑',
    category: AchievementCategory.overtime,
    checker: (s) => s.monthlyOvertimeHours >= 20,
  ),
  Achievement(
    id: 'overtime_total_100',
    name: '加班达人',
    description: '累计加班超过 100 小时',
    icon: '🔥',
    category: AchievementCategory.overtime,
    checker: (s) => s.totalOvertimeHours >= 100,
  ),

  // ===== 收入类 =====
  Achievement(
    id: 'earning_hourly_100',
    name: '时薪玩家',
    description: '时薪突破 ¥100/h',
    icon: '💎',
    category: AchievementCategory.earning,
    checker: (s) => s.hourlySalary >= 100,
  ),
  Achievement(
    id: 'earning_100k',
    name: '十万哥',
    description: '累计赚够 ¥100,000',
    icon: '🎊',
    category: AchievementCategory.earning,
    checker: (s) => s.totalEarned >= 100000,
  ),

  // ===== 生活类 =====
  Achievement(
    id: 'punctual_5_days',
    name: '反卷先锋',
    description: '连续 5 天准时下班',
    icon: '✊',
    category: AchievementCategory.lifestyle,
    checker: (s) => s.punctualDaysThisWeek >= 5,
  ),
  Achievement(
    id: 'weekend_free_4',
    name: '周末自由人',
    description: '连续 4 周周末零加班',
    icon: '🏖️',
    category: AchievementCategory.lifestyle,
    checker: (s) => s.noOvertimeWeeks >= 4,
  ),
  Achievement(
    id: 'weekly_40h',
    name: '生活家',
    description: '单周工作不超过 40 小时',
    icon: '🌿',
    category: AchievementCategory.lifestyle,
    checker: (s) => s.weeklyWorkHours > 0 && s.weeklyWorkHours <= 40,
  ),
  Achievement(
    id: 'anti_overtime_hero',
    name: '准时下班侠',
    description: '连续 5 天准时下班',
    icon: '🦸',
    category: AchievementCategory.lifestyle,
    checker: (s) => s.punctualDaysThisWeek >= 5,
  ),
];

/// 成就检查器
class AchievementChecker {
  /// 检查所有成就，返回新解锁的成就列表
  ///
  /// [snapshot] 当前用户数据快照
  /// [alreadyUnlockedIds] 已经解锁过的成就 ID 集合
  List<Achievement> check({
    required UserSnapshot snapshot,
    required Set<String> alreadyUnlockedIds,
  }) {
    final newlyUnlocked = <Achievement>[];

    for (final achievement in predefinedAchievements) {
      if (alreadyUnlockedIds.contains(achievement.id)) continue;

      if (achievement.checker(snapshot)) {
        newlyUnlocked.add(achievement.copyWith(unlockedAt: DateTime.now()));
      }
    }

    return newlyUnlocked;
  }
}
