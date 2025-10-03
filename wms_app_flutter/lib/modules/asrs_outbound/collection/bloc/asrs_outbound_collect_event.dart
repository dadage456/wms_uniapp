import 'package:equatable/equatable.dart';
import 'package:wms_app/modules/asrs_outbound/models/asrs_outbound_models.dart';

abstract class AsrsOutboundCollectEvent extends Equatable {
  const AsrsOutboundCollectEvent();

  @override
  List<Object?> get props => [];
}

class AsrsOutboundCollectStarted extends AsrsOutboundCollectEvent {
  const AsrsOutboundCollectStarted(this.task);

  final AsrsOutboundTask task;

  @override
  List<Object?> get props => [task];
}

class AsrsOutboundCollectDetailSelected extends AsrsOutboundCollectEvent {
  const AsrsOutboundCollectDetailSelected(this.detail);

  final AsrsOutboundTaskDetail detail;

  @override
  List<Object?> get props => [detail];
}

class AsrsOutboundCollectScanReceived extends AsrsOutboundCollectEvent {
  const AsrsOutboundCollectScanReceived(this.code);

  final String code;

  @override
  List<Object?> get props => [code];
}

class AsrsOutboundCollectQuantitySubmitted extends AsrsOutboundCollectEvent {
  const AsrsOutboundCollectQuantitySubmitted(this.quantity);

  final double quantity;

  @override
  List<Object?> get props => [quantity];
}

class AsrsOutboundCollectRecordRemoved extends AsrsOutboundCollectEvent {
  const AsrsOutboundCollectRecordRemoved(this.recordId);

  final String recordId;

  @override
  List<Object?> get props => [recordId];
}

class AsrsOutboundCollectSubmitRequested extends AsrsOutboundCollectEvent {
  const AsrsOutboundCollectSubmitRequested();
}

class AsrsOutboundCollectResetRequested extends AsrsOutboundCollectEvent {
  const AsrsOutboundCollectResetRequested();
}

class AsrsOutboundCollectMessageCleared extends AsrsOutboundCollectEvent {
  const AsrsOutboundCollectMessageCleared();
}
