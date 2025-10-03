import 'package:equatable/equatable.dart';
import 'package:wms_app/modules/floor_inventory/task_collect/models/inventory_collect_models.dart';
import 'package:wms_app/modules/floor_inventory/task_list/models/inventory_task.dart';

abstract class InventoryCollectEvent extends Equatable {
  const InventoryCollectEvent();

  @override
  List<Object?> get props => [];
}

class InventoryCollectStarted extends InventoryCollectEvent {
  const InventoryCollectStarted(this.task);

  final InventoryTask task;

  @override
  List<Object?> get props => [task];
}

class InventoryCollectRefreshRequested extends InventoryCollectEvent {
  const InventoryCollectRefreshRequested();
}

class InventoryCollectTabChanged extends InventoryCollectEvent {
  const InventoryCollectTabChanged(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}

class InventoryCollectScanReceived extends InventoryCollectEvent {
  const InventoryCollectScanReceived(this.code);

  final String code;

  @override
  List<Object?> get props => [code];
}

class InventoryCollectManualQuantityChanged extends InventoryCollectEvent {
  const InventoryCollectManualQuantityChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class InventoryCollectQuantitySubmitted extends InventoryCollectEvent {
  const InventoryCollectQuantitySubmitted(this.quantity);

  final double quantity;

  @override
  List<Object?> get props => [quantity];
}

class InventoryCollectRecordRemoved extends InventoryCollectEvent {
  const InventoryCollectRecordRemoved(this.record);

  final InventoryCollectionRecord record;

  @override
  List<Object?> get props => [record];
}

class InventoryCollectSubmitRequested extends InventoryCollectEvent {
  const InventoryCollectSubmitRequested();
}

class InventoryCollectResetRequested extends InventoryCollectEvent {
  const InventoryCollectResetRequested();
}

class InventoryCollectMessageCleared extends InventoryCollectEvent {
  const InventoryCollectMessageCleared();
}
