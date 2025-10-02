import 'package:equatable/equatable.dart';

/// 提交/撤销出库任务明细返回结果
class CommitTaskItemResult extends Equatable {
  final bool success;
  final int processedCount;
  final String action;

  const CommitTaskItemResult({
    required this.success,
    required this.processedCount,
    required this.action,
  });

  factory CommitTaskItemResult.fromJson(Map<String, dynamic> json) {
    return CommitTaskItemResult(
      success: json['success'] == true,
      processedCount: int.tryParse(json['processedCount']?.toString() ?? '0') ?? 0,
      action: json['action']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [success, processedCount, action];
}
