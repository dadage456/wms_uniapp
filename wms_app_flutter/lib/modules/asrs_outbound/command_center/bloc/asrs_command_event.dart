import 'package:equatable/equatable.dart';
import 'package:wms_app/modules/asrs_outbound/models/asrs_outbound_models.dart';

abstract class AsrsCommandEvent extends Equatable {
  const AsrsCommandEvent();

  @override
  List<Object?> get props => [];
}

class AsrsCommandInitialized extends AsrsCommandEvent {
  const AsrsCommandInitialized(this.task);

  final AsrsOutboundTask task;

  @override
  List<Object?> get props => [task];
}

class AsrsCommandTypeChanged extends AsrsCommandEvent {
  const AsrsCommandTypeChanged(this.type);

  final AsrsCommandType type;

  @override
  List<Object?> get props => [type];
}

class AsrsCommandTrayChanged extends AsrsCommandEvent {
  const AsrsCommandTrayChanged(this.trayNo);

  final String trayNo;

  @override
  List<Object?> get props => [trayNo];
}

class AsrsCommandStartChanged extends AsrsCommandEvent {
  const AsrsCommandStartChanged(this.address);

  final String address;

  @override
  List<Object?> get props => [address];
}

class AsrsCommandEndChanged extends AsrsCommandEvent {
  const AsrsCommandEndChanged(this.address);

  final String address;

  @override
  List<Object?> get props => [address];
}

class AsrsCommandSingleFlagChanged extends AsrsCommandEvent {
  const AsrsCommandSingleFlagChanged(this.flag);

  final String flag;

  @override
  List<Object?> get props => [flag];
}

class AsrsCommandApplyLocation extends AsrsCommandEvent {
  const AsrsCommandApplyLocation(this.address, {required this.isStart});

  final String address;
  final bool isStart;

  @override
  List<Object?> get props => [address, isStart];
}

class AsrsCommandSubmitRequested extends AsrsCommandEvent {
  const AsrsCommandSubmitRequested();
}

class AsrsCommandMessageCleared extends AsrsCommandEvent {
  const AsrsCommandMessageCleared();
}
