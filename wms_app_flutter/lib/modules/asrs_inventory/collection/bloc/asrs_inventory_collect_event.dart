import 'package:equatable/equatable.dart';
import 'package:wms_app/modules/asrs_inventory/models/asrs_inventory_models.dart';

abstract class AsrsInventoryCollectEvent extends Equatable {
  const AsrsInventoryCollectEvent();

  @override
  List<Object?> get props => [];
}

class AsrsInventoryCollectInitialized extends AsrsInventoryCollectEvent {
  const AsrsInventoryCollectInitialized({required this.task});

  final AsrsInventoryTask task;

  @override
  List<Object?> get props => [task];
}

class AsrsInventoryCollectDetailSelected extends AsrsInventoryCollectEvent {
  const AsrsInventoryCollectDetailSelected(this.detail);

  final AsrsInventoryTaskDetail detail;

  @override
  List<Object?> get props => [detail];
}

class AsrsInventoryCollectSearchChanged extends AsrsInventoryCollectEvent {
  const AsrsInventoryCollectSearchChanged(this.keyword);

  final String keyword;

  @override
  List<Object?> get props => [keyword];
}

class AsrsInventoryCollectQuantityChanged extends AsrsInventoryCollectEvent {
  const AsrsInventoryCollectQuantityChanged(this.quantity);

  final double quantity;

  @override
  List<Object?> get props => [quantity];
}

class AsrsInventoryCollectRecordAdded extends AsrsInventoryCollectEvent {
  const AsrsInventoryCollectRecordAdded();
}

class AsrsInventoryCollectRecordRemoved extends AsrsInventoryCollectEvent {
  const AsrsInventoryCollectRecordRemoved(this.recordId);

  final String recordId;

  @override
  List<Object?> get props => [recordId];
}

class AsrsInventoryCollectSubmitted extends AsrsInventoryCollectEvent {
  const AsrsInventoryCollectSubmitted();
}

class AsrsInventoryCollectScanReceived extends AsrsInventoryCollectEvent {
  const AsrsInventoryCollectScanReceived(this.code);

  final String code;

  @override
  List<Object?> get props => [code];
}

class AsrsInventoryCollectMessagesCleared extends AsrsInventoryCollectEvent {
  const AsrsInventoryCollectMessagesCleared();
}
