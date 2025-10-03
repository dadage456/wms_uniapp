import 'package:equatable/equatable.dart';
import 'package:wms_app/modules/asrs_inbound/models/asrs_inbound_models.dart';

abstract class AsrsInboundCommandEvent extends Equatable {
  const AsrsInboundCommandEvent();

  @override
  List<Object?> get props => [];
}

class AsrsInboundCommandStarted extends AsrsInboundCommandEvent {
  const AsrsInboundCommandStarted({required this.task});

  final AsrsInboundTask task;

  @override
  List<Object?> get props => [task];
}

class AsrsInboundCommandTrayChanged extends AsrsInboundCommandEvent {
  const AsrsInboundCommandTrayChanged(this.trayNo);

  final String trayNo;

  @override
  List<Object?> get props => [trayNo];
}

class AsrsInboundCommandStartChanged extends AsrsInboundCommandEvent {
  const AsrsInboundCommandStartChanged(this.address);

  final String address;

  @override
  List<Object?> get props => [address];
}

class AsrsInboundCommandEndChanged extends AsrsInboundCommandEvent {
  const AsrsInboundCommandEndChanged(this.address);

  final String address;

  @override
  List<Object?> get props => [address];
}

class AsrsInboundCommandSubmitted extends AsrsInboundCommandEvent {
  const AsrsInboundCommandSubmitted();
}

class AsrsInboundCommandRefreshed extends AsrsInboundCommandEvent {
  const AsrsInboundCommandRefreshed();
}
