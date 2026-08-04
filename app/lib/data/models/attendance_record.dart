import 'package:flutter/material.dart';

/// 打卡记录
class AttendanceRecord {
  final DateTime date;
  final DateTime? clockIn;
  final DateTime? clockOut;
  final double overtimeHours;
  final double overtimePay;
  final AttendanceStatus status;

  const AttendanceRecord({
    required this.date,
    this.clockIn,
    this.clockOut,
    this.overtimeHours = 0,
    this.overtimePay = 0,
    this.status = AttendanceStatus.normal,
  });

  bool get isClockedIn => clockIn != null;
  bool get isClockedOut => clockOut != null;
  bool get isOvertime => overtimeHours > 0;

  AttendanceRecord copyWith({
    DateTime? clockIn,
    DateTime? clockOut,
    double? overtimeHours,
    double? overtimePay,
    AttendanceStatus? status,
  }) =>
      AttendanceRecord(
        date: date,
        clockIn: clockIn ?? this.clockIn,
        clockOut: clockOut ?? this.clockOut,
        overtimeHours: overtimeHours ?? this.overtimeHours,
        overtimePay: overtimePay ?? this.overtimePay,
        status: status ?? this.status,
      );
}

enum AttendanceStatus {
  normal,    // 正常
  late,      // 迟到
  earlyLeave, // 早退
  overtime,  // 加班
  absent,    // 缺勤
  leave,     // 请假
}

extension AttendanceStatusX on AttendanceStatus {
  String get label {
    switch (this) {
      case AttendanceStatus.normal: return '正常';
      case AttendanceStatus.late: return '迟到';
      case AttendanceStatus.earlyLeave: return '早退';
      case AttendanceStatus.overtime: return '加班';
      case AttendanceStatus.absent: return '缺勤';
      case AttendanceStatus.leave: return '请假';
    }
  }

  Color get color {
    switch (this) {
      case AttendanceStatus.normal: return Colors.green;
      case AttendanceStatus.late: return Colors.orange;
      case AttendanceStatus.earlyLeave: return Colors.red;
      case AttendanceStatus.overtime: return Colors.amber;
      case AttendanceStatus.absent: return Colors.red;
      case AttendanceStatus.leave: return Colors.blue;
    }
  }
}
