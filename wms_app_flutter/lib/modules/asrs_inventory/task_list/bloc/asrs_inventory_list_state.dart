import 'package:equatable/equatable.dart';
import 'package:wms_app/modules/asrs_inventory/models/asrs_inventory_models.dart';

enum AsrsInventoryListStatus { initial, loading, success, failure }

class AsrsInventoryListState extends Equatable {
  const AsrsInventoryListState({
    this.status = AsrsInventoryListStatus.initial,
    this.tasks = const [],
    this.keyword = '',
    this.onlyProcessing = true,
    this.errorMessage,
    this.successMessage,
  });

  final AsrsInventoryListStatus status;
  final List<AsrsInventoryTask> tasks;
  final String keyword;
  final bool onlyProcessing;
  final String? errorMessage;
  final String? successMessage;

  AsrsInventoryListState copyWith({
    AsrsInventoryListStatus? status,
    List<AsrsInventoryTask>? tasks,
    String? keyword,
    bool? onlyProcessing,
    String? errorMessage,
    String? successMessage,
  }) {
    return AsrsInventoryListState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      keyword: keyword ?? this.keyword,
      onlyProcessing: onlyProcessing ?? this.onlyProcessing,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  AsrsInventoryListState clearMessages() {
    return copyWith(errorMessage: null, successMessage: null);
  }

  @override
  List<Object?> get props =>
      [status, tasks, keyword, onlyProcessing, errorMessage, successMessage];
}
