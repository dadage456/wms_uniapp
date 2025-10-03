import 'package:equatable/equatable.dart';
import 'package:wms_app/modules/asrs_inbound/models/asrs_inbound_models.dart';

enum AsrsInboundCollectStatus { initial, loading, ready, failure, submitting, success }

enum AsrsInboundCollectStep { tray, barcode, quantity }

class AsrsInboundCollectState extends Equatable {
  const AsrsInboundCollectState({
    this.status = AsrsInboundCollectStatus.initial,
    this.task,
    this.step = AsrsInboundCollectStep.tray,
    this.trayNo = '',
    this.currentDetail,
    this.quantity = 0,
    this.details = const [],
    this.records = const [],
    this.errorMessage,
    this.successMessage,
  });

  final AsrsInboundCollectStatus status;
  final AsrsInboundTask? task;
  final AsrsInboundCollectStep step;
  final String trayNo;
  final AsrsInboundTaskDetail? currentDetail;
  final double quantity;
  final List<AsrsInboundTaskDetail> details;
  final List<AsrsInboundCollectionRecord> records;
  final String? errorMessage;
  final String? successMessage;

  bool get canSubmit => records.isNotEmpty && status != AsrsInboundCollectStatus.submitting;

  AsrsInboundCollectState copyWith({
    AsrsInboundCollectStatus? status,
    AsrsInboundTask? task,
    AsrsInboundCollectStep? step,
    String? trayNo,
    AsrsInboundTaskDetail? currentDetail,
    double? quantity,
    List<AsrsInboundTaskDetail>? details,
    List<AsrsInboundCollectionRecord>? records,
    String? errorMessage,
    String? successMessage,
  }) {
    return AsrsInboundCollectState(
      status: status ?? this.status,
      task: task ?? this.task,
      step: step ?? this.step,
      trayNo: trayNo ?? this.trayNo,
      currentDetail: currentDetail ?? this.currentDetail,
      quantity: quantity ?? this.quantity,
      details: details ?? this.details,
      records: records ?? this.records,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        task,
        step,
        trayNo,
        currentDetail,
        quantity,
        details,
        records,
        errorMessage,
        successMessage,
      ];
}
