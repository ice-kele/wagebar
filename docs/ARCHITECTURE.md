# WageBar · 技术架构文档

## 一、整体架构

```
┌──────────────────────────────────────────────────────────┐
│                    Flutter UI 层                          │
│  Dashboard │ SalarySetup │ Attendance │ Achievements │  │
├──────────────────────────────────────────────────────────┤
│                   BLoC / Riverpod 状态层                  │
│  SalaryBloc │ AttendanceBloc │ GamificationBloc          │
├──────────────────────────────────────────────────────────┤
│                    领域服务层 (Domain)                     │
│  SalaryCalculator │ OvertimeEngine │ AchievementChecker  │
├──────────────────────────────────────────────────────────┤
│                    数据访问层 (Repository)                │
│  LocalRepository (SQLite/Hive)  │  SyncRepository (可选)  │
├──────────────────────────────────────────────────────────┤
│                    基础设施层                             │
│  SQLite │ AES加密 │ LocalNotification │ HTTP Client      │
└──────────────────────────────────────────────────────────┘
```

## 二、技术选型

### 前端：Flutter 3.22+

| 选择 | 理由 |
|------|------|
| Flutter | 一套代码覆盖 6 端，原生性能，动画能力强 |
| Riverpod | 类型安全的依赖注入 + 状态管理 |
| Hive | 轻量级 NoSQL 本地存储，比 SQLite 更快 |
| flutter_local_notifications | 本地推送通知 |
| fl_chart | 图表库（进度条、趋势图） |
| encrypt | AES 数据加密 |

### 后端（可选同步服务）：Go

| 选择 | 理由 |
|------|------|
| Go | 编译为单二进制，内存占用极小，适合自托管 |
| SQLite | 服务端也用 SQLite，零运维 |
| end-to-end encryption | 端到端加密，服务端无法解密用户数据 |

### 为什么不用 React Native / Electron？

| 方案 | 问题 |
|------|------|
| React Native + Electron | 两套代码库（移动端 RN + 桌面端 Electron），维护成本翻倍 |
| Tauri | 移动端支持尚不成熟（Tauri 2.0 刚稳定） |
|原生开发 | 6 端意味着 4 套代码（Swift/Kotlin/C++/JS），不可持续 |

Flutter 是当前唯一能用**单一代码库**覆盖 iOS/Android/Windows/macOS/Linux/Web 的成熟方案。

## 三、项目目录结构

```
wagebar/
├── app/                              # Flutter 应用
│   ├── pubspec.yaml                  # 依赖配置
│   ├── lib/
│   │   ├── main.dart                 # 应用入口
│   │   ├── core/                     # 核心层
│   │   │   ├── constants.dart        # 常量（加班倍率等）
│   │   │   ├── theme.dart            # 主题（亮/暗色）
│   │   │   ├── router.dart           # 路由配置
│   │   │   └── utils/               # 工具函数
│   │   ├── data/                     # 数据层
│   │   │   ├── models/              # 数据模型
│   │   │   │   ├── salary_config.dart
│   │   │   │   ├── attendance_record.dart
│   │   │   │   └── achievement.dart
│   │   │   ├── repositories/        # 仓库
│   │   │   └── database/            # 本地数据库
│   │   ├── domain/                   # 领域层
│   │   │   ├── salary_calculator.dart    # 薪资计算引擎
│   │   │   ├── overtime_engine.dart      # 加班引擎
│   │   │   └── achievement_checker.dart  # 成就检查器
│   │   ├── features/                 # 功能模块
│   │   │   ├── dashboard/            # 首页仪表盘
│   │   │   │   ├── widgets/
│   │   │   │   │   ├── earning_progress.dart  # 赚钱进度条
│   │   │   │   │   └── clock_card.dart         # 打卡卡片
│   │   │   │   └── dashboard_page.dart
│   │   │   ├── salary/              # 薪资设置
│   │   │   ├── attendance/          # 打卡模块
│   │   │   ├── achievements/        # 成就系统
│   │   │   └── settings/            # 设置
│   │   ├── l10n/                     # 国际化
│   │   │   ├── app_zh.arb           # 中文
│   │   │   └── app_en.arb           # 英文
│   │   └── shared/                   # 共享组件
│   ├── android/                      # Android 原生配置
│   ├── ios/                          # iOS 原生配置
│   ├── windows/                      # Windows 原生配置
│   ├── macos/                        # macOS 原生配置
│   ├── linux/                        # Linux 原生配置
│   └── web/                          # Web 配置
├── server/                           # 可选同步服务（Go）
│   ├── main.go
│   ├── go.mod
│   └── README.md
├── docs/                             # 文档
│   ├── PRD.md
│   ├── ARCHITECTURE.md
│   └── ROADMAP.md
├── .github/
│   └── workflows/
│       └── ci.yml                    # CI/CD
├── README.md
├── LICENSE                           # AGPL-3.0
└── CONTRIBUTING.md
```

## 四、核心算法

### 4.1 实时赚钱计算

```dart
/// 计算从上班到当前时刻的已赚金额
EarningResult calculateEarning({
  required SalaryConfig config,
  required DateTime clockIn,
  required DateTime now,
  required DateTime scheduledClockOut,
}) {
  // 正常工作时间赚的
  final workDuration = now.isBefore(scheduledClockOut)
      ? now.difference(clockIn)
      : scheduledClockOut.difference(clockIn);
  final normalPay = workDuration.inSeconds * config.perSecondSalary;

  // 加班时间赚的
  double overtimePay = 0;
  if (now.isAfter(scheduledClockOut)) {
    final overtimeDuration = now.difference(scheduledClockOut);
    final multiplier = getOvertimeMultiplier(now); // 1.5 / 2.0 / 3.0
    overtimePay = overtimeDuration.inSeconds * config.perSecondSalary * multiplier;
  }

  return EarningResult(
    normalPay: normalPay,
    overtimePay: overtimePay,
    total: normalPay + overtimePay,
    isOvertime: now.isAfter(scheduledClockOut),
  );
}
```

### 4.2 加班费结算

```dart
/// 日终结算加班费
OvertimeSettlement settleOvertime({
  required SalaryConfig config,
  required DateTime clockIn,
  required DateTime clockOut,
  required DateTime scheduledClockOut,
}) {
  if (clockOut.isBefore(scheduledClockOut)) {
    return OvertimeSettlement.zero(); // 没加班
  }

  final overtimeStart = scheduledClockOut;
  final overtimeEnd = clockOut;
  final overtimeHours = overtimeEnd.difference(overtimeStart).inHours;

  // 加班上限保护
  final cappedHours = min(overtimeHours, config.maxOvertimeHours);

  // 判断日期类型确定倍率
  final rate = getOvertimeMultiplier(overtimeStart); // 工作日1.5/休息日2.0/法定3.0
  final hourlyRate = config.hourlySalary * rate;
  final totalPay = cappedHours * hourlyRate;

  return OvertimeSettlement(
    hours: cappedHours,
    rate: rate,
    hourlyPay: hourlyRate,
    totalPay: totalPay,
  );
}
```

### 4.3 成就检查（快照重算模式）

```dart
/// 每次状态变更时重新检查所有成就
List<Achievement> checkAchievements(UserSnapshot snapshot) {
  final results = <Achievement>[];

  for (final achievement in predefinedAchievements) {
    final unlocked = achievement.checker(snapshot);
    if (unlocked && !achievement.isAlreadyUnlocked) {
      results.add(achievement..unlock());
    }
  }

  return results;
}
```

## 五、数据安全

### 本地加密
- 薪资配置、打卡记录使用 AES-256 加密存储
- 加密密钥存储在系统 Keychain (iOS/macOS) / Keystore (Android)

### 同步加密（可选服务）
- 客户端生成 ECDH 密钥对
- 数据加密后上传，服务端只存储密文
- 服务端零知识（zero-knowledge）架构

## 六、CI/CD

```yaml
# GitHub Actions
on: [push, pull_request]
jobs:
  test:
    - flutter test                    # 单元测试 + Widget 测试
    - flutter analyze                 # 静态分析
  build:
    - flutter build apk              # Android
    - flutter build ios              # iOS (需 macOS runner)
    - flutter build windows          # Windows
    - flutter build macos            # macOS
    - flutter build linux            # Linux
    - flutter build web              # Web
```
