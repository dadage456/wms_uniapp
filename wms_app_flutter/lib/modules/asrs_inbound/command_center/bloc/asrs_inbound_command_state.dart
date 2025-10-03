import 'package:equatable/equatable.dart';
import 'package:wms_app/modules/asrs_inbound/models/asrs_inbound_models.dart';

enum AsrsInboundCommandStatus { initial, loading, ready, submitting, failure }

class AsrsInboundCommandState extends Equatable {
  const AsrsInboundCommandState({
    this.status = AsrsInboundCommandStatus.initial,
    this.task,
    this.trayNo = '',
    this.startAddress = '',
    this.endAddress = '',
    this.history = const [],
    this.errorMessage,
    this.successMessage,
  });

  final AsrsInboundCommandStatus status;
  final AsrsInboundTask? task;
  final String trayNo;
  final String startAddress;
  final String endAddress;
  final List<AsrsInboundWcsCommand> history;
  final String? errorMessage;
  final String? successMessage;

  AsrsInboundCommandState copyWith({
    AsrsInboundCommandStatus? status,
    AsrsInboundTask? task,
    String? trayNo,
    String? startAddress,
    String? endAddress,
    List<AsrsInboundWcsCommand>? history,
    String? errorMessage,
    String? successMessage,
  }) {
    return AsrsInboundCommandState(
      status: status ?? this.status,
      task: task ?? this.task,
      trayNo: trayNo ?? this.trayNo,
      startAddress: startAddress ?? this.startAddress,
      endAddress: endAddress ?? this.endAddress,
      history: history ?? this.history,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        task,
        trayNo,
        startAddress,
        endAddress,
        history,
        errorMessage,
        successMessage,
      ];
}
