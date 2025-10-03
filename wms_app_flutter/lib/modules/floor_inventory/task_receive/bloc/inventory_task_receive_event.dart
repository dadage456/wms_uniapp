import 'package:equatable/equatable.dart';
import 'package:wms_app/modules/floor_inventory/task_list/models/inventory_task.dart';

abstract class InventoryTaskReceiveEvent extends Equatable {
  const InventoryTaskReceiveEvent();

  @override
  List<Object?> get props => [];
}

class InventoryTaskReceiveSearchSubmitted extends InventoryTaskReceiveEvent {
  const InventoryTaskReceiveSearchSubmitted(this.keyword);

  final String keyword;

  @override
  List<Object?> get props => [keyword];
}

class InventoryTaskReceiveRefreshRequested extends InventoryTaskReceiveEvent {
  const InventoryTaskReceiveRefreshRequested();
}

class InventoryTaskReceiveConfirmed extends InventoryTaskReceiveEvent {
  const InventoryTaskReceiveConfirmed(this.task);

  final InventoryTask task;

  @override
  List<Object?> get props => [task];
}

class InventoryTaskReceiveMessageCleared extends InventoryTaskReceiveEvent {
  const InventoryTaskReceiveMessageCleared();
}
