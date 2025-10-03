import 'package:equatable/equatable.dart';
import 'package:wms_app/modules/floor_exception/exception_task_list/models/exception_task.dart';

abstract class FloorExceptionCollectEvent extends Equatable {
  const FloorExceptionCollectEvent();

  @override
  List<Object?> get props => [];
}

class FloorExceptionInitializeEvent extends FloorExceptionCollectEvent {
  const FloorExceptionInitializeEvent({
    this.taskSummary,
    this.trayNo = '',
    this.initialStoreSite = '',
  });

  final FloorExceptionTaskSummary? taskSummary;
  final String trayNo;
  final String initialStoreSite;

  @override
  List<Object?> get props => [taskSummary, trayNo, initialStoreSite];
}

class FloorExceptionTypeChangedEvent extends FloorExceptionCollectEvent {
  const FloorExceptionTypeChangedEvent({required this.type, required this.name});

  final String type;
  final String name;

  @override
  List<Object?> get props => [type, name];
}

class FloorExceptionPerformScanEvent extends FloorExceptionCollectEvent {
  const FloorExceptionPerformScanEvent(this.barcode);

  final String barcode;

  @override
  List<Object?> get props => [barcode];
}

class FloorExceptionSelectionChangedEvent extends FloorExceptionCollectEvent {
  const FloorExceptionSelectionChangedEvent(this.selectedIds);

  final List<String> selectedIds;

  @override
  List<Object?> get props => [selectedIds];
}

class FloorExceptionDeleteSelectedEvent extends FloorExceptionCollectEvent {
  const FloorExceptionDeleteSelectedEvent();
}

class FloorExceptionCommitRequestedEvent extends FloorExceptionCollectEvent {
  const FloorExceptionCommitRequestedEvent();
}

class FloorExceptionClearErrorEvent extends FloorExceptionCollectEvent {
  const FloorExceptionClearErrorEvent();
}

class FloorExceptionClearMessageEvent extends FloorExceptionCollectEvent {
  const FloorExceptionClearMessageEvent();
}
