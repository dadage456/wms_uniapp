import 'package:equatable/equatable.dart';
import 'package:wms_app/modules/floor_inbound/collection_task/models/inbound_collection_models.dart';
import 'package:wms_app/modules/floor_inbound/task_list/models/inbound_task.dart';

class InboundCollectionState extends Equatable {
  const InboundCollectionState({
    this.task,
    this.context,
    this.isLoading = false,
    this.errorMessage,
    this.infoMessage,
  });

  final InboundTask? task;
  final InboundCollectionContext? context;
  final bool isLoading;
  final String? errorMessage;
  final String? infoMessage;

  InboundCollectionState copyWith({
    InboundTask? task,
    InboundCollectionContext? context,
    bool? isLoading,
    String? errorMessage,
    String? infoMessage,
  }) {
    return InboundCollectionState(
      task: task ?? this.task,
      context: context ?? this.context,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      infoMessage: infoMessage,
    );
  }

  @override
  List<Object?> get props => [task, context, isLoading, errorMessage, infoMessage];
}
