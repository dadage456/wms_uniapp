import 'package:equatable/equatable.dart';
import 'package:wms_app/modules/asrs_outbound/models/asrs_outbound_models.dart';

enum AsrsOutboundDetailStatus { initial, loading, success, failure }

class AsrsOutboundDetailState extends Equatable {
  const AsrsOutboundDetailState({
    this.status = AsrsOutboundDetailStatus.initial,
    this.task,
    this.details = const [],
    this.selectedIds = const {},
    this.keyword = '',
    this.isActionInProgress = false,
    this.errorMessage,
    this.successMessage,
  });

  final AsrsOutboundDetailStatus status;
  final AsrsOutboundTask? task;
  final List<AsrsOutboundTaskDetail> details;
  final Set<String> selectedIds;
  final String keyword;
  final bool isActionInProgress;
  final String? errorMessage;
  final String? successMessage;

  AsrsOutboundDetailState copyWith({
    AsrsOutboundDetailStatus? status,
    AsrsOutboundTask? task,
    List<AsrsOutboundTaskDetail>? details,
    Set<String>? selectedIds,
    String? keyword,
    bool? isActionInProgress,
    String? errorMessage,
    String? successMessage,
  }) {
    return AsrsOutboundDetailState(
      status: status ?? this.status,
      task: task ?? this.task,
      details: details ?? this.details,
      selectedIds: selectedIds ?? this.selectedIds,
      keyword: keyword ?? this.keyword,
      isActionInProgress: isActionInProgress ?? this.isActionInProgress,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  AsrsOutboundDetailState clearMessages() {
    return copyWith(errorMessage: null, successMessage: null);
  }

  @override
  List<Object?> get props => [
        status,
        task,
        details,
        selectedIds,
        keyword,
        isActionInProgress,
        errorMessage,
        successMessage,
      ];
}
