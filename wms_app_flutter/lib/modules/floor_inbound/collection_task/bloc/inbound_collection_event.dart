import 'package:equatable/equatable.dart';
import 'package:wms_app/modules/floor_inbound/task_list/models/inbound_task.dart';

abstract class InboundCollectionEvent extends Equatable {
  const InboundCollectionEvent();

  @override
  List<Object?> get props => [];
}

class InitializeInboundCollection extends InboundCollectionEvent {
  const InitializeInboundCollection({required this.task, required this.userId});

  final InboundTask task;
  final int userId;

  @override
  List<Object?> get props => [task, userId];
}

class InboundScanPerformed extends InboundCollectionEvent {
  const InboundScanPerformed(this.content);

  final String content;

  @override
  List<Object?> get props => [content];
}

class InboundManualQuantityConfirmed extends InboundCollectionEvent {
  const InboundManualQuantityConfirmed(this.quantity);

  final double quantity;

  @override
  List<Object?> get props => [quantity];
}

class InboundRemoveRecord extends InboundCollectionEvent {
  const InboundRemoveRecord(this.recordIndex);

  final int recordIndex;

  @override
  List<Object?> get props => [recordIndex];
}

class SubmitInboundCollection extends InboundCollectionEvent {
  const SubmitInboundCollection();
}
