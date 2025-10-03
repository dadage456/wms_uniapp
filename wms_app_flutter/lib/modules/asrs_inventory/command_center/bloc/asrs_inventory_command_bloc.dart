import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/modules/asrs_inventory/command_center/bloc/asrs_inventory_command_event.dart';
import 'package:wms_app/modules/asrs_inventory/command_center/bloc/asrs_inventory_command_state.dart';
import 'package:wms_app/modules/asrs_inventory/models/asrs_inventory_models.dart';
import 'package:wms_app/modules/asrs_inventory/services/asrs_inventory_service.dart';

class AsrsInventoryCommandBloc
    extends Bloc<AsrsInventoryCommandEvent, AsrsInventoryCommandState> {
  AsrsInventoryCommandBloc({required AsrsInventoryService service})
    : _service = service,
      super(const AsrsInventoryCommandState()) {
    on<AsrsInventoryCommandStarted>(_onStarted);
    on<AsrsInventoryCommandTrayChanged>(_onTrayChanged);
    on<AsrsInventoryCommandStartChanged>(_onStartChanged);
    on<AsrsInventoryCommandEndChanged>(_onEndChanged);
    on<AsrsInventoryCommandTypeChanged>(_onTypeChanged);
    on<AsrsInventoryCommandSingleFlagChanged>(_onSingleFlagChanged);
    on<AsrsInventoryCommandSubmitted>(_onSubmitted);
    on<AsrsInventoryCommandRefreshed>(_onRefreshed);
    on<AsrsInventoryCommandMessagesCleared>(_onMessagesCleared);
  }

  final AsrsInventoryService _service;

  Future<void> _onStarted(
    AsrsInventoryCommandStarted event,
    Emitter<AsrsInventoryCommandState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AsrsInventoryCommandStatus.loading,
        task: event.task,
        trayNo: '',
        startAddress: '',
        endAddress: '',
        history: const [],
        errorMessage: null,
        successMessage: null,
      ),
    );
    await _loadHistory(emit, task: event.task);
  }

  void _onTrayChanged(
    AsrsInventoryCommandTrayChanged event,
    Emitter<AsrsInventoryCommandState> emit,
  ) {
    emit(state.copyWith(trayNo: event.trayNo));
  }

  void _onStartChanged(
    AsrsInventoryCommandStartChanged event,
    Emitter<AsrsInventoryCommandState> emit,
  ) {
    emit(state.copyWith(startAddress: event.address));
  }

  void _onEndChanged(
    AsrsInventoryCommandEndChanged event,
    Emitter<AsrsInventoryCommandState> emit,
  ) {
    emit(state.copyWith(endAddress: event.address));
  }

  void _onTypeChanged(
    AsrsInventoryCommandTypeChanged event,
    Emitter<AsrsInventoryCommandState> emit,
  ) {
    emit(state.copyWith(commandType: event.type));
  }

  void _onSingleFlagChanged(
    AsrsInventoryCommandSingleFlagChanged event,
    Emitter<AsrsInventoryCommandState> emit,
  ) {
    emit(state.copyWith(singleFlag: event.singleFlag));
  }

  Future<void> _onSubmitted(
    AsrsInventoryCommandSubmitted event,
    Emitter<AsrsInventoryCommandState> emit,
  ) async {
    final task = state.task;
    if (task == null) {
      emit(state.copyWith(errorMessage: '任务信息缺失'));
      return;
    }
    if (state.trayNo.isEmpty) {
      emit(state.copyWith(errorMessage: '请先输入托盘号'));
      return;
    }
    if (state.startAddress.isEmpty || state.endAddress.isEmpty) {
      emit(state.copyWith(errorMessage: '请完善起始与目标地址'));
      return;
    }

    emit(state.copyWith(status: AsrsInventoryCommandStatus.submitting));
    try {
      if (state.commandType == AsrsInventoryCommandType.down) {
        await _service.submitDownCommand(
          taskId: task.taskId,
          taskNo: task.taskNo,
          trayNo: state.trayNo,
          startAddress: state.startAddress,
          endAddress: state.endAddress,
          singleFlag: state.singleFlag,
        );
      } else {
        await _service.submitResetCommand(
          taskId: task.taskId,
          taskNo: task.taskNo,
          trayNo: state.trayNo,
          startAddress: state.startAddress,
          endAddress: state.endAddress,
        );
      }
      await _loadHistory(emit, task: task, successMessage: '指令下发成功');
    } catch (e) {
      emit(
        state.copyWith(
          status: AsrsInventoryCommandStatus.ready,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onRefreshed(
    AsrsInventoryCommandRefreshed event,
    Emitter<AsrsInventoryCommandState> emit,
  ) async {
    final task = state.task;
    if (task == null) return;
    await _loadHistory(emit, task: task);
  }

  void _onMessagesCleared(
    AsrsInventoryCommandMessagesCleared event,
    Emitter<AsrsInventoryCommandState> emit,
  ) {
    emit(state.clearMessages());
  }

  Future<void> _loadHistory(
    Emitter<AsrsInventoryCommandState> emit, {
    required AsrsInventoryTask task,
    String? successMessage,
  }) async {
    emit(
      state.copyWith(
        status: AsrsInventoryCommandStatus.loading,
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
          status: AsrsInventoryCommandStatus.ready,
          history: history,
          successMessage: successMessage,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AsrsInventoryCommandStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
