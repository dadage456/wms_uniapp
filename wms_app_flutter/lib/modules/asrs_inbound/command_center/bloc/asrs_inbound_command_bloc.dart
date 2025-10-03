import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/modules/asrs_inbound/command_center/bloc/asrs_inbound_command_event.dart';
import 'package:wms_app/modules/asrs_inbound/command_center/bloc/asrs_inbound_command_state.dart';
import 'package:wms_app/modules/asrs_inbound/services/asrs_inbound_service.dart';

class AsrsInboundCommandBloc
    extends Bloc<AsrsInboundCommandEvent, AsrsInboundCommandState> {
  AsrsInboundCommandBloc({required AsrsInboundService service})
      : _service = service,
        super(const AsrsInboundCommandState()) {
    on<AsrsInboundCommandStarted>(_onStarted);
    on<AsrsInboundCommandTrayChanged>(_onTrayChanged);
    on<AsrsInboundCommandStartChanged>(_onStartChanged);
    on<AsrsInboundCommandEndChanged>(_onEndChanged);
    on<AsrsInboundCommandSubmitted>(_onSubmitted);
    on<AsrsInboundCommandRefreshed>(_onRefreshed);
  }

  final AsrsInboundService _service;

  Future<void> _onStarted(
    AsrsInboundCommandStarted event,
    Emitter<AsrsInboundCommandState> emit,
  ) async {
    emit(state.copyWith(status: AsrsInboundCommandStatus.loading, task: event.task));
    await _loadHistory(emit, task: event.task);
  }

  Future<void> _onTrayChanged(
    AsrsInboundCommandTrayChanged event,
    Emitter<AsrsInboundCommandState> emit,
  ) async {
    emit(state.copyWith(trayNo: event.trayNo));
  }

  Future<void> _onStartChanged(
    AsrsInboundCommandStartChanged event,
    Emitter<AsrsInboundCommandState> emit,
  ) async {
    emit(state.copyWith(startAddress: event.address));
  }

  Future<void> _onEndChanged(
    AsrsInboundCommandEndChanged event,
    Emitter<AsrsInboundCommandState> emit,
  ) async {
    emit(state.copyWith(endAddress: event.address));
  }

  Future<void> _onSubmitted(
    AsrsInboundCommandSubmitted event,
    Emitter<AsrsInboundCommandState> emit,
  ) async {
    final task = state.task;
    if (task == null) return;
    if (state.trayNo.isEmpty) {
      emit(state.copyWith(errorMessage: '请先填写托盘号'));
      return;
    }
    if (state.startAddress.isEmpty || state.endAddress.isEmpty) {
      emit(state.copyWith(errorMessage: '请完善起始和目标地址'));
      return;
    }

    emit(state.copyWith(status: AsrsInboundCommandStatus.submitting));

    try {
      await _service.submitWcsCommand(
        taskId: task.taskId,
        taskNo: task.taskNo,
        trayNo: state.trayNo,
        startAddress: state.startAddress,
        endAddress: state.endAddress,
      );
      await _loadHistory(emit, task: task, successMessage: '指令下发成功');
    } catch (e) {
      emit(
        state.copyWith(
          status: AsrsInboundCommandStatus.ready,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onRefreshed(
    AsrsInboundCommandRefreshed event,
    Emitter<AsrsInboundCommandState> emit,
  ) async {
    if (state.task == null) return;
    await _loadHistory(emit, task: state.task!);
  }

  Future<void> _loadHistory(
    Emitter<AsrsInboundCommandState> emit, {
    required AsrsInboundTask task,
    String? successMessage,
  }) async {
    emit(
      state.copyWith(
        status: AsrsInboundCommandStatus.loading,
        successMessage: null,
        errorMessage: null,
      ),
    );

    try {
      final history = await _service.fetchCommandHistory(
        taskId: task.taskId,
        taskComment: task.taskComment,
      );
      emit(
        state.copyWith(
          status: AsrsInboundCommandStatus.ready,
          task: task,
          history: history,
          successMessage: successMessage,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AsrsInboundCommandStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
