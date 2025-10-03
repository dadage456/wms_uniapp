import 'package:equatable/equatable.dart';
import 'package:wms_app/modules/floor_inventory/task_details/models/inventory_task_detail.dart';

enum InventoryTaskDetailStatus { initial, loading, success, failure }

class InventoryTaskDetailState extends Equatable {
  const InventoryTaskDetailState({
    this.status = InventoryTaskDetailStatus.initial,
    this.details = const [],
    this.errorMessage,
    this.taskComment = '',
    this.taskNo = '',
  });

  final InventoryTaskDetailStatus status;
  final List<InventoryTaskDetail> details;
  final String? errorMessage;
  final String taskComment;
  final String taskNo;

  InventoryTaskDetailState copyWith({
    InventoryTaskDetailStatus? status,
    List<InventoryTaskDetail>? details,
    String? errorMessage,
    String? taskComment,
    String? taskNo,
  }) {
    return InventoryTaskDetailState(
      status: status ?? this.status,
      details: details ?? this.details,
      errorMessage: errorMessage,
      taskComment: taskComment ?? this.taskComment,
      taskNo: taskNo ?? this.taskNo,
    );
  }

  @override
  List<Object?> get props => [status, details, errorMessage, taskComment, taskNo];
}
