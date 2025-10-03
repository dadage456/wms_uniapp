import 'package:equatable/equatable.dart';
import 'package:wms_app/modules/asrs_inbound/models/asrs_inbound_models.dart';

enum AsrsInboundListStatus { initial, loading, success, failure }

class AsrsInboundListState extends Equatable {
  const AsrsInboundListState({
    this.status = AsrsInboundListStatus.initial,
    this.tasks = const [],
    this.keyword = '',
    this.errorMessage,
    this.successMessage,
  });

  final AsrsInboundListStatus status;
  final List<AsrsInboundTask> tasks;
  final String keyword;
  final String? errorMessage;
  final String? successMessage;

  AsrsInboundListState copyWith({
    AsrsInboundListStatus? status,
    List<AsrsInboundTask>? tasks,
    String? keyword,
    String? errorMessage,
    String? successMessage,
  }) {
    return AsrsInboundListState(
      status: status ?? this.status,
      tasks: tasks ?? this.tasks,
      keyword: keyword ?? this.keyword,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  AsrsInboundListState clearMessage() {
    return copyWith(errorMessage: null, successMessage: null);
  }

  @override
  List<Object?> get props => [status, tasks, keyword, errorMessage, successMessage];
}
