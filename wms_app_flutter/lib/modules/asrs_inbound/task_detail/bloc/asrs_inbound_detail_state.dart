import 'package:equatable/equatable.dart';
import 'package:wms_app/modules/asrs_inbound/models/asrs_inbound_models.dart';

enum AsrsInboundDetailStatus { initial, loading, success, failure }

class AsrsInboundDetailState extends Equatable {
  const AsrsInboundDetailState({
    this.status = AsrsInboundDetailStatus.initial,
    this.task,
    this.details = const [],
    this.trayInfos = const [],
    this.keyword = '',
    this.errorMessage,
  });

  final AsrsInboundDetailStatus status;
  final AsrsInboundTask? task;
  final List<AsrsInboundTaskDetail> details;
  final List<AsrsInboundTrayInfo> trayInfos;
  final String keyword;
  final String? errorMessage;

  AsrsInboundDetailState copyWith({
    AsrsInboundDetailStatus? status,
    AsrsInboundTask? task,
    List<AsrsInboundTaskDetail>? details,
    List<AsrsInboundTrayInfo>? trayInfos,
    String? keyword,
    String? errorMessage,
  }) {
    return AsrsInboundDetailState(
      status: status ?? this.status,
      task: task ?? this.task,
      details: details ?? this.details,
      trayInfos: trayInfos ?? this.trayInfos,
      keyword: keyword ?? this.keyword,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        task,
        details,
        trayInfos,
        keyword,
        errorMessage,
      ];
}
