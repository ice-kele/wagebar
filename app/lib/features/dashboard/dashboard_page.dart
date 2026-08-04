import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../../domain/salary_calculator.dart';
import '../../data/models/salary_config.dart';

/// 首页仪表盘 — 核心页面，展示实时赚钱进度条
class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    // 每秒刷新进度条
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: 从 Riverpod provider 获取实际配置
    final config = const SalaryConfig(
      monthlySalary: 8000,
      dailyHours: 8,
      lunchBreakHours: 1,
    );

    final calculator = SalaryCalculator(config);

    // 构造今日打卡时间（MVP 硬编码，后续接入实际打卡数据）
    final today = _now;
    final clockIn = DateTime(today.year, today.month, today.day, 9, 0);
    final scheduledClockOut = DateTime(today.year, today.month, today.day, 18, 0);

    final earning = calculator.calculateRealtimeEarning(
      clockIn: clockIn,
      now: _now,
      scheduledClockOut: scheduledClockOut,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('打工进度条')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== 实时赚钱进度条 =====
            _EarningProgressCard(
              earning: earning,
              config: config,
              now: _now,
            ),
            const SizedBox(height: 24),

            // ===== 打卡卡片 =====
            _ClockCard(isClockedIn: true, isOvertime: earning.isOvertime),
            const SizedBox(height: 24),

            // ===== 等级进度 =====
            _LevelCard(config: config),
            const SizedBox(height: 24),

            // ===== 快捷入口 =====
            Row(
              children: [
                _QuickAction(
                  icon: Icons.emoji_events,
                  label: '成就',
                  onTap: () => Navigator.pushNamed(context, '/achievements'),
                ),
                _QuickAction(
                  icon: Icons.history,
                  label: '打卡记录',
                  onTap: () => Navigator.pushNamed(context, '/attendance'),
                ),
                _QuickAction(
                  icon: Icons.settings,
                  label: '设置',
                  onTap: () => Navigator.pushNamed(context, '/settings'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 实时赚钱进度条卡片
class _EarningProgressCard extends StatelessWidget {
  final EarningResult earning;
  final SalaryConfig config;
  final DateTime now;

  const _EarningProgressCard({
    required this.earning,
    required this.config,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final wbColors = theme.extension<WageBarColors>()!;
    final isOvertime = earning.isOvertime;
    final accentColor = isOvertime ? wbColors.overtime : wbColors.primary;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 时间 + 状态标签
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${['周一','周二','周三','周四','周五','周六','周日'][now.weekday - 1]} '
                  '${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (isOvertime)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: wbColors.overtime.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '加班中 ×1.5',
                      style: TextStyle(color: wbColors.overtime, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // 大数字：已赚金额
            Text(
              SalaryCalculator.formatCNY(earning.total),
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '/ 今日 ${SalaryCalculator.formatCNY(config.dailySalary)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),

            // 进度条
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: earning.progress,
                minHeight: 12,
                backgroundColor: accentColor.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(accentColor),
              ),
            ),
            const SizedBox(height: 12),

            // 时薪信息
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _InfoChip(label: '时薪', value: SalaryCalculator.formatCNY(config.hourlySalary)),
                _InfoChip(label: '秒薪', value: '¥${(config.perSecondSalary * 100).toStringAsFixed(2)}分'),
                if (earning.overtimePay > 0)
                  _InfoChip(label: '加班费', value: SalaryCalculator.formatCNY(earning.overtimePay)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        )),
        Text(value, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

/// 打卡卡片
class _ClockCard extends StatelessWidget {
  final bool isClockedIn;
  final bool isOvertime;
  const _ClockCard({required this.isClockedIn, required this.isOvertime});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        leading: Icon(
          isOvertime ? Icons.access_time_filled : Icons.access_time_filled,
          color: isOvertime ? Colors.orange : Colors.green,
          size: 40,
        ),
        title: Text(isOvertime ? '加班中' : '工作中', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(isClockedIn ? '上班已打卡 09:00' : '尚未打卡'),
        trailing: FilledButton(
          onPressed: () {
            // TODO: 打卡逻辑
          },
          child: Text(isOvertime ? '下班打卡' : '上班打卡'),
        ),
      ),
    );
  }
}

/// 等级卡片
class _LevelCard extends StatelessWidget {
  final SalaryConfig config;
  const _LevelCard({required this.config});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber[700]),
                const SizedBox(width: 8),
                Text('Lv.3 资深搬砖工', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: 0.42,
                minHeight: 8,
                backgroundColor: Colors.amber.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(Colors.amber[700]!),
              ),
            ),
            const SizedBox(height: 8),
            Text('累计 ¥10,000 → ¥30,000（还差 ¥12,345）',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Icon(icon, size: 28, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 6),
                Text(label, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
