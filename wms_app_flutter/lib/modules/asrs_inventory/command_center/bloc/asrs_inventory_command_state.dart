import 'package:equatable/equatable.dart';
import 'package:wms_app/modules/asrs_inventory/models/asrs_inventory_models.dart';

enum AsrsInventoryCommandStatus { initial, loading, ready, submitting, failure }

class AsrsInventoryCommandState extends Equatable {
  const AsrsInventoryCommandState({
    this.status = AsrsInventoryCommandStatus.initial,
    this.task,
    this.trayNo = '',
    this.startAddress = '',
    this.endAddress = '',
    this.history = const [],
    this.commandType = AsrsInventoryCommandType.down,
    this.singleFlag = false,
    this.errorMessage,
    this.successMessage,
  });

  final AsrsInventoryCommandStatus status;
  final AsrsInventoryTask? task;
  final String trayNo;
  final String startAddress;
  final String endAddress;
  final List<AsrsInventoryWcsCommand> history;
  final AsrsInventoryCommandType commandType;
  final bool singleFlag;
  final String? errorMessage;
  final String? successMessage;

  AsrsInventoryCommandState copyWith({
    AsrsInventoryCommandStatus? status,
    AsrsInventoryTask? task,
    String? trayNo,
    String? startAddress,
    String? endAddress,
    List<AsrsInventoryWcsCommand>? history,
    AsrsInventoryCommandType? commandType,
    bool? singleFlag,
    String? errorMessage,
    String? successMessage,
  }) {
    return AsrsInventoryCommandState(
      status: status ?? this.status,
      task: task ?? this.task,
      trayNo: trayNo ?? this.trayNo,
      startAddress: startAddress ?? this.startAddress,
      endAddress: endAddress ?? this.endAddress,
      history: history ?? this.history,
      commandType: commandType ?? this.commandType,
      singleFlag: singleFlag ?? this.singleFlag,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  AsrsInventoryCommandState clearMessages() =>
      copyWith(errorMessage: null, successMessage: null);

  @override
  List<Object?> get props => [
        status,
        task,
        trayNo,
        startAddress,
        endAddress,
        history,
        commandType,
        singleFlag,
        errorMessage,
        successMessage,
      ];
}
