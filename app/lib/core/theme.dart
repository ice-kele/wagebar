import 'package:flutter/material.dart';

/// WageBar 主题配置
class WageBarTheme {
  static const _primary = Color(0xFF4CAF50); // 打工绿
  static const _overtime = Color(0xFFFF9800); // 加班金
  static const _danger = Color(0xFFEF5350); // 迟到红

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primary,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        extensions: [
          const WageBarColors(
            primary: _primary,
            overtime: _overtime,
            danger: _danger,
          ),
        ],
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _primary,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        extensions: [
          const WageBarColors(
            primary: _primary,
            overtime: _overtime,
            danger: _danger,
          ),
        ],
      );
}

/// WageBar 自定义颜色语义
class WageBarColors extends ThemeExtension<WageBarColors> {
  final Color primary;
  final Color overtime;
  final Color danger;

  const WageBarColors({
    required this.primary,
    required this.overtime,
    required this.danger,
  });

  @override
  WageBarColors copyWith({Color? primary, Color? overtime, Color? danger}) {
    return WageBarColors(
      primary: primary ?? this.primary,
      overtime: overtime ?? this.overtime,
      danger: danger ?? this.danger,
    );
  }

  @override
  WageBarColors lerp(WageBarColors? other, double t) {
    if (other == null) return this;
    return WageBarColors(
      primary: Color.lerp(primary, other.primary, t)!,
      overtime: Color.lerp(overtime, other.overtime, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}
