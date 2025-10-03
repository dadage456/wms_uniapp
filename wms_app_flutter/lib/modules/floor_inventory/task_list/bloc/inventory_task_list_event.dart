import 'package:equatable/equatable.dart';
import 'package:wms_app/modules/floor_inventory/task_list/models/inventory_task.dart';

abstract class InventoryTaskListEvent extends Equatable {
  const InventoryTaskListEvent();

  @override
  List<Object?> get props => [];
}

class InventoryTaskListSearchSubmitted extends InventoryTaskListEvent {
  const InventoryTaskListSearchSubmitted(this.keyword);

  final String keyword;

  @override
  List<Object?> get props => [keyword];
}

class InventoryTaskListRefreshRequested extends InventoryTaskListEvent {
  const InventoryTaskListRefreshRequested();
}

class InventoryTaskCancelRequested extends InventoryTaskListEvent {
  const InventoryTaskCancelRequested(this.task);

  final InventoryTask task;

  @override
  List<Object?> get props => [task];
}

class InventoryTaskNavigateToDetail extends InventoryTaskListEvent {
  const InventoryTaskNavigateToDetail(this.task);

  final InventoryTask task;

  @override
  List<Object?> get props => [task];
}

class InventoryTaskMessageCleared extends InventoryTaskListEvent {
  const InventoryTaskMessageCleared();
}
