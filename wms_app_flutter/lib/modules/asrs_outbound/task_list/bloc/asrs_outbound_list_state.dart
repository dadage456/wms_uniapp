import 'package:equatable/equatable.dart';
import 'package:wms_app/modules/asrs_outbound/models/asrs_outbound_models.dart';

enum AsrsOutboundListStatus { initial, loading, success, failure }

class AsrsOutboundListState extends Equatable {
  const AsrsOutboundListState({
    this.status = AsrsOutboundListStatus.initial,
    this.tasks = const [],
    this.keyword = '',
    this.isActionInProgress = false,
    this.errorMessage,
    this.successMessage,
  });

  final AsrsOutboundListStatus status;
  final List<AsrsOutboundTask> tasks;
  final String keyword;
  final bool isActionInProgress;
  final String? errorMessage;
  final String? successMessage;

  AsrsOutboundListState copyWith({
    AsrsOutboundListStatus? status,
    List<AsrsOutboundTask>? tasks,
    String? keyword,
    bool? isActionInProgress,
    String? errorMessage,
    String? successMessage,
  }) {
    return AsrsOutboundListState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      keyword: keyword ?? this.keyword,
      isActionInProgress: isActionInProgress ?? this.isActionInProgress,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  AsrsOutboundListState clearMessages() {
    return copyWith(errorMessage: null, successMessage: null);
  }

  @override
  List<Object?> get props => [
        status,
        tasks,
        keyword,
        isActionInProgress,
        errorMessage,
        successMessage,
      ];
}
