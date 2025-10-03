import 'package:equatable/equatable.dart';
import 'package:wms_app/modules/arrival/task_details/models/arrival_task_detail.dart';
import 'package:wms_app/modules/arrival/task_list/models/arrival_task.dart';

abstract class ArrivalCollectionEvent extends Equatable {
  const ArrivalCollectionEvent();

  @override
  List<Object?> get props => [];
}

class InitializeArrivalCollection extends ArrivalCollectionEvent {
  const InitializeArrivalCollection({required this.task});

  final ArrivalTask task;

  @override
  List<Object?> get props => [task];
}

class ArrivalCollectionScanReceived extends ArrivalCollectionEvent {
  const ArrivalCollectionScanReceived(this.code);

  final String code;

  @override
  List<Object?> get props => [code];
}

class ArrivalCollectionDetailSelected extends ArrivalCollectionEvent {
  const ArrivalCollectionDetailSelected(this.detail);

  final ArrivalTaskDetail detail;

  @override
  List<Object?> get props => [detail];
}

class ArrivalCollectionQuantitySubmitted extends ArrivalCollectionEvent {
  const ArrivalCollectionQuantitySubmitted(this.quantity);

  final double quantity;

  @override
  List<Object?> get props => [quantity];
}

class ArrivalCollectionPromptDismissed extends ArrivalCollectionEvent {
  const ArrivalCollectionPromptDismissed();
}

class ArrivalCollectionRecordRemoved extends ArrivalCollectionEvent {
  const ArrivalCollectionRecordRemoved(this.recordId);

  final String recordId;

  @override
  List<Object?> get props => [recordId];
}

class ArrivalCollectionSubmitRequested extends ArrivalCollectionEvent {
  const ArrivalCollectionSubmitRequested();
}

class ArrivalCollectionMessagesCleared extends ArrivalCollectionEvent {
  const ArrivalCollectionMessagesCleared();
}

class ArrivalCollectionTabChanged extends ArrivalCollectionEvent {
  const ArrivalCollectionTabChanged(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}
