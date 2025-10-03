import 'package:equatable/equatable.dart';
import 'package:wms_app/modules/asrs_inventory/models/asrs_inventory_models.dart';

abstract class AsrsInventoryCommandEvent extends Equatable {
  const AsrsInventoryCommandEvent();

  @override
  List<Object?> get props => [];
}

class AsrsInventoryCommandStarted extends AsrsInventoryCommandEvent {
  const AsrsInventoryCommandStarted({required this.task});

  final AsrsInventoryTask task;

  @override
  List<Object?> get props => [task];
}

class AsrsInventoryCommandTrayChanged extends AsrsInventoryCommandEvent {
  const AsrsInventoryCommandTrayChanged(this.trayNo);

  final String trayNo;

  @override
  List<Object?> get props => [trayNo];
}

class AsrsInventoryCommandStartChanged extends AsrsInventoryCommandEvent {
  const AsrsInventoryCommandStartChanged(this.address);

  final String address;

  @override
  List<Object?> get props => [address];
}

class AsrsInventoryCommandEndChanged extends AsrsInventoryCommandEvent {
  const AsrsInventoryCommandEndChanged(this.address);

  final String address;

  @override
  List<Object?> get props => [address];
}

class AsrsInventoryCommandTypeChanged extends AsrsInventoryCommandEvent {
  const AsrsInventoryCommandTypeChanged(this.type);

  final AsrsInventoryCommandType type;

  @override
  List<Object?> get props => [type];
}

class AsrsInventoryCommandSingleFlagChanged extends AsrsInventoryCommandEvent {
  const AsrsInventoryCommandSingleFlagChanged(this.singleFlag);

  final bool singleFlag;

  @override
  List<Object?> get props => [singleFlag];
}

class AsrsInventoryCommandSubmitted extends AsrsInventoryCommandEvent {
  const AsrsInventoryCommandSubmitted();
}

class AsrsInventoryCommandRefreshed extends AsrsInventoryCommandEvent {
  const AsrsInventoryCommandRefreshed();
}

class AsrsInventoryCommandMessagesCleared extends AsrsInventoryCommandEvent {
  const AsrsInventoryCommandMessagesCleared();
}
