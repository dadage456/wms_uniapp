import 'package:equatable/equatable.dart';
import 'package:wms_app/modules/asrs_inbound/models/asrs_inbound_models.dart';

abstract class AsrsInboundCollectEvent extends Equatable {
  const AsrsInboundCollectEvent();

  @override
  List<Object?> get props => [];
}

class AsrsInboundCollectInitialized extends AsrsInboundCollectEvent {
  const AsrsInboundCollectInitialized({required this.task});

  final AsrsInboundTask task;

  @override
  List<Object?> get props => [task];
}

class AsrsInboundCollectTrayChanged extends AsrsInboundCollectEvent {
  const AsrsInboundCollectTrayChanged(this.trayNo);

  final String trayNo;

  @override
  List<Object?> get props => [trayNo];
}

class AsrsInboundCollectBarcodeScanned extends AsrsInboundCollectEvent {
  const AsrsInboundCollectBarcodeScanned(this.barcode);

  final String barcode;

  @override
  List<Object?> get props => [barcode];
}

class AsrsInboundCollectQuantityChanged extends AsrsInboundCollectEvent {
  const AsrsInboundCollectQuantityChanged(this.quantity);

  final double quantity;

  @override
  List<Object?> get props => [quantity];
}

class AsrsInboundCollectRecordAdded extends AsrsInboundCollectEvent {
  const AsrsInboundCollectRecordAdded();
}

class AsrsInboundCollectRecordRemoved extends AsrsInboundCollectEvent {
  const AsrsInboundCollectRecordRemoved(this.recordId);

  final String recordId;

  @override
  List<Object?> get props => [recordId];
}

class AsrsInboundCollectSubmitted extends AsrsInboundCollectEvent {
  const AsrsInboundCollectSubmitted();
}
