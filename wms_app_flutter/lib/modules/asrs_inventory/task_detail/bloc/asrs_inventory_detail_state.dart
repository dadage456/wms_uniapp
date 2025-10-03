import 'package:equatable/equatable.dart';
import 'package:wms_app/modules/asrs_inventory/models/asrs_inventory_models.dart';

enum AsrsInventoryDetailStatus { initial, loading, success, failure }

class AsrsInventoryDetailState extends Equatable {
  const AsrsInventoryDetailState({
    this.status = AsrsInventoryDetailStatus.initial,
    this.task,
    this.details = const [],
    this.trayItems = const [],
    this.keyword = '',
    this.errorMessage,
  });

  final AsrsInventoryDetailStatus status;
  final AsrsInventoryTask? task;
  final List<AsrsInventoryTaskDetail> details;
  final List<AsrsInventoryTrayItem> trayItems;
  final String keyword;
  final String? errorMessage;

  AsrsInventoryDetailState copyWith({
    AsrsInventoryDetailStatus? status,
    AsrsInventoryTask? task,
    List<AsrsInventoryTaskDetail>? details,
    List<AsrsInventoryTrayItem>? trayItems,
    String? keyword,
    String? errorMessage,
  }) {
    return AsrsInventoryDetailState(
      status: status ?? this.status,
      task: task ?? this.task,
      details: details ?? this.details,
      trayItems: trayItems ?? this.trayItems,
      keyword: keyword ?? this.keyword,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, task, details, trayItems, keyword, errorMessage];
}
