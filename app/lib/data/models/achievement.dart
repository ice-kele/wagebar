/// 成就模型
class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon; // emoji
  final AchievementCategory category;
  final AchievementChecker checker;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.checker,
    this.unlockedAt,
  });

  bool get isUnlocked => unlockedAt != null;

  Achievement copyWith({DateTime? unlockedAt}) => Achievement(
        id: id,
        name: name,
        description: description,
        icon: icon,
        category: category,
        checker: checker,
        unlockedAt: unlockedAt ?? this.unlockedAt,
      );
}

enum AchievementCategory {
  attendance,  // 打卡类
  overtime,    // 加班类
  earning,     // 收入类
  lifestyle,   // 生活类
}

extension AchievementCategoryX on AchievementCategory {
  String get label {
    switch (this) {
      case AchievementCategory.attendance: return '打卡';
      case AchievementCategory.overtime: return '加班';
      case AchievementCategory.earning: return '收入';
      case AchievementCategory.lifestyle: return '生活';
    }
  }
}

/// 成就检查函数类型
/// 接收用户快照数据，返回是否满足解锁条件
typedef AchievementChecker = bool Function(UserSnapshot snapshot);

/// 用户数据快照（用于成就检查）
class UserSnapshot {
  final int consecutiveDays;        // 连续打卡天数
  final int totalDays;               // 累计使用天数
  final double totalEarned;          // 累计已赚
  final double hourlySalary;         // 当前时薪
  final double monthlyOvertimeHours; // 本月加班时长
  final double totalOvertimeHours;   // 累计加班时长
  final int punctualDaysThisWeek;    // 本周准时下班天数
  final int noOvertimeWeeks;         // 连续无加班周数
  final int weeklyWorkHours;         // 本周工时

  const UserSnapshot({
    this.consecutiveDays = 0,
    this.totalDays = 0,
    this.totalEarned = 0,
    this.hourlySalary = 0,
    this.monthlyOvertimeHours = 0,
    this.totalOvertimeHours = 0,
    this.punctualDaysThisWeek = 0,
    this.noOvertimeWeeks = 0,
    this.weeklyWorkHours = 0,
  });
}
