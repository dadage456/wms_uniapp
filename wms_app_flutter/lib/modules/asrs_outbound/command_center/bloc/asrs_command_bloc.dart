import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/modules/asrs_outbound/command_center/bloc/asrs_command_event.dart';
import 'package:wms_app/modules/asrs_outbound/command_center/bloc/asrs_command_state.dart';
import 'package:wms_app/modules/asrs_outbound/models/asrs_outbound_models.dart';
import 'package:wms_app/modules/asrs_outbound/services/asrs_outbound_service.dart';

class AsrsCommandBloc extends Bloc<AsrsCommandEvent, AsrsCommandState> {
  AsrsCommandBloc({required AsrsOutboundService service})
      : _service = service,
        super(const AsrsCommandState()) {
    on<AsrsCommandInitialized>(_onInitialized);
    on<AsrsCommandTypeChanged>(_onTypeChanged);
    on<AsrsCommandTrayChanged>(_onTrayChanged);
    on<AsrsCommandStartChanged>(_onStartChanged);
    on<AsrsCommandEndChanged>(_onEndChanged);
    on<AsrsCommandSingleFlagChanged>(_onSingleFlagChanged);
    on<AsrsCommandApplyLocation>(_onApplyLocation);
    on<AsrsCommandSubmitRequested>(_onSubmitRequested);
    on<AsrsCommandMessageCleared>(_onMessageCleared);
  }

  final AsrsOutboundService _service;

  Future<void> _onInitialized(
    AsrsCommandInitialized event,
    Emitter<AsrsCommandState> emit,
  ) async {
    emit(state.copyWith(status: AsrsCommandStatus.loading, task: event.task));
    try {
      final outLocations = await _service.fetchInOutLocations('OUT');
      final inLocations = await _service.fetchInOutLocations('IN');
      final palletSites = await _service.fetchPalletSites(event.task.taskNo);
      emit(
        state.copyWith(
          status: AsrsCommandStatus.ready,
          outLocations: outLocations,
          inLocations: inLocations,
          palletSites: palletSites,
          startAddress: outLocations.isNotEmpty ? outLocations.first.address : '',
          endAddress: inLocations.isNotEmpty ? inLocations.first.address : '',
          trayNo: event.task.projectNum.isNotEmpty
              ? event.task.projectNum
              : '',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AsrsCommandStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  FutureOr<void> _onTypeChanged(
    AsrsCommandTypeChanged event,
    Emitter<AsrsCommandState> emit,
  ) {
    emit(state.copyWith(type: event.type));
  }

  FutureOr<void> _onTrayChanged(
    AsrsCommandTrayChanged event,
    Emitter<AsrsCommandState> emit,
  ) {
    emit(state.copyWith(trayNo: event.trayNo));
  }

  FutureOr<void> _onStartChanged(
    AsrsCommandStartChanged event,
    Emitter<AsrsCommandState> emit,
  ) {
    emit(state.copyWith(startAddress: event.address));
  }

  FutureOr<void> _onEndChanged(
    AsrsCommandEndChanged event,
    Emitter<AsrsCommandState> emit,
  ) {
    emit(state.copyWith(endAddress: event.address));
  }

  FutureOr<void> _onSingleFlagChanged(
    AsrsCommandSingleFlagChanged event,
    Emitter<AsrsCommandState> emit,
  ) {
    emit(state.copyWith(singleFlag: event.flag));
  }

  FutureOr<void> _onApplyLocation(
    AsrsCommandApplyLocation event,
    Emitter<AsrsCommandState> emit,
  ) {
    emit(
      event.isStart
          ? state.copyWith(startAddress: event.address)
          : state.copyWith(endAddress: event.address),
    );
  }

  Future<void> _onSubmitRequested(
    AsrsCommandSubmitRequested event,
    Emitter<AsrsCommandState> emit,
  ) async {
    if (state.task == null) return;
    if (state.trayNo.trim().isEmpty) {
      emit(state.copyWith(errorMessage: '托盘号不能为空'));
      return;
    }
    if (state.startAddress.trim().isEmpty || state.endAddress.trim().isEmpty) {
      emit(state.copyWith(errorMessage: '请填写完整的起始和目标地址'));
      return;
    }

    emit(
      state.copyWith(
        status: AsrsCommandStatus.submitting,
        errorMessage: null,
        successMessage: null,
      ),
    );

    try {
      await _service.commitWcsCommand(
        AsrsWcsCommandPayload(
          taskId: state.task!.taskId,
          taskNo: state.task!.taskNo,
          trayNo: state.trayNo,
          startAddress: state.startAddress,
          endAddress: state.endAddress,
          singleFlag: state.singleFlag,
          type: state.type,
        ),
      );
      emit(
        state.copyWith(
          status: AsrsCommandStatus.success,
          successMessage: '指令已下发',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AsrsCommandStatus.ready,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  FutureOr<void> _onMessageCleared(
    AsrsCommandMessageCleared event,
    Emitter<AsrsCommandState> emit,
  ) {
    emit(state.clearMessages());
  }
}
