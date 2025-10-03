import 'package:equatable/equatable.dart';
import 'package:wms_app/modules/asrs_outbound/models/asrs_outbound_models.dart';

enum AsrsCommandStatus { initial, loading, ready, submitting, success, failure }

class AsrsCommandState extends Equatable {
  const AsrsCommandState({
    this.status = AsrsCommandStatus.initial,
    this.task,
    this.type = AsrsCommandType.normal,
    this.trayNo = '',
    this.startAddress = '',
    this.endAddress = '',
    this.singleFlag = '0',
    this.outLocations = const [],
    this.inLocations = const [],
    this.palletSites = const [],
    this.errorMessage,
    this.successMessage,
  });

  final AsrsCommandStatus status;
  final AsrsOutboundTask? task;
  final AsrsCommandType type;
  final String trayNo;
  final String startAddress;
  final String endAddress;
  final String singleFlag;
  final List<AsrsLocation> outLocations;
  final List<AsrsLocation> inLocations;
  final List<AsrsLocation> palletSites;
  final String? errorMessage;
  final String? successMessage;

  AsrsCommandState copyWith({
    AsrsCommandStatus? status,
    AsrsOutboundTask? task,
    AsrsCommandType? type,
    String? trayNo,
    String? startAddress,
    String? endAddress,
    String? singleFlag,
    List<AsrsLocation>? outLocations,
    List<AsrsLocation>? inLocations,
    List<AsrsLocation>? palletSites,
    String? errorMessage,
    String? successMessage,
  }) {
    return AsrsCommandState(
      status: status ?? this.status,
      task: task ?? this.task,
      type: type ?? this.type,
      trayNo: trayNo ?? this.trayNo,
      startAddress: startAddress ?? this.startAddress,
      endAddress: endAddress ?? this.endAddress,
      singleFlag: singleFlag ?? this.singleFlag,
      outLocations: outLocations ?? this.outLocations,
      inLocations: inLocations ?? this.inLocations,
      palletSites: palletSites ?? this.palletSites,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  AsrsCommandState clearMessages() {
    return copyWith(errorMessage: null, successMessage: null);
  }

  @override
  List<Object?> get props => [
        status,
        task,
        type,
        trayNo,
        startAddress,
        endAddress,
        singleFlag,
        outLocations,
        inLocations,
        palletSites,
        errorMessage,
        successMessage,
      ];
}
