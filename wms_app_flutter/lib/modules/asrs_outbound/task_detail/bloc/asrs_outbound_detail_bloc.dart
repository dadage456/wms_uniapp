import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/modules/asrs_outbound/models/asrs_outbound_models.dart';
import 'package:wms_app/modules/asrs_outbound/services/asrs_outbound_service.dart';
import 'package:wms_app/modules/asrs_outbound/task_detail/bloc/asrs_outbound_detail_event.dart';
import 'package:wms_app/modules/asrs_outbound/task_detail/bloc/asrs_outbound_detail_state.dart';

class AsrsOutboundDetailBloc
    extends Bloc<AsrsOutboundDetailEvent, AsrsOutboundDetailState> {
  AsrsOutboundDetailBloc({required AsrsOutboundService service})
    : _service = service,
      super(const AsrsOutboundDetailState()) {
    on<AsrsOutboundDetailStarted>(_onStarted);
    on<AsrsOutboundDetailSearchChanged>(_onSearchChanged);
    on<AsrsOutboundDetailSelectionToggled>(_onSelectionToggled);
    on<AsrsOutboundDetailToggleAll>(_onToggleAll);
    on<AsrsOutboundDetailReceiveRequested>(_onReceiveRequested);
  }

  final AsrsOutboundService _service;

  Future<void> _onStarted(
    AsrsOutboundDetailStarted event,
    Emitter<AsrsOutboundDetailState> emit,
  ) async {
    emit(state.copyWith(task: event.task, keyword: event.keyword ?? ''));
    await _loadDetails(emit, task: event.task, keyword: event.keyword);
  }

  Future<void> _onSearchChanged(
    AsrsOutboundDetailSearchChanged event,
    Emitter<AsrsOutboundDetailState> emit,
  ) async {
    if (state.task == null) return;
    emit(state.copyWith(keyword: event.keyword));
    await _loadDetails(emit, task: state.task!, keyword: event.keyword);
  }

  void _onSelectionToggled(
    AsrsOutboundDetailSelectionToggled event,
    Emitter<AsrsOutboundDetailState> emit,
  ) {
    final updated = Set<String>.from(state.selectedIds);
    if (event.selected) {
      updated.add(event.taskItemId);
    } else {
      updated.remove(event.taskItemId);
    }
    emit(state.copyWith(selectedIds: updated));
  }

  void _onToggleAll(
    AsrsOutboundDetailToggleAll event,
    Emitter<AsrsOutboundDetailState> emit,
  ) {
    if (event.selectAll) {
      emit(
        state.copyWith(
          selectedIds: state.details.map((e) => e.taskItemId).toSet(),
        ),
      );
    } else {
      emit(state.copyWith(selectedIds: {}));
    }
  }

  Future<void> _onReceiveRequested(
    AsrsOutboundDetailReceiveRequested event,
    Emitter<AsrsOutboundDetailState> emit,
  ) async {
    if (state.task == null) return;
    if (state.selectedIds.isEmpty) {
      emit(state.copyWith(errorMessage: '请先选择需要操作的任务明细'));
      return;
    }

    emit(
      state.copyWith(
        isActionInProgress: true,
        errorMessage: null,
        successMessage: null,
      ),
    );

    try {
      await _service.commitReceive(
        taskItemIds: state.selectedIds.toList(),
        roomTag: '0',
        cancel: event.cancel,
      );
      await _loadDetails(
        emit,
        task: state.task!,
        keyword: state.keyword,
        successMessage: event.cancel ? '撤销成功' : '任务接收成功',
      );
    } catch (e) {
      emit(
        state.copyWith(isActionInProgress: false, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _loadDetails(
    Emitter<AsrsOutboundDetailState> emit, {
    required AsrsOutboundTask task,
    String? keyword,
    String? successMessage,
  }) async {
    emit(
      state.copyWith(
        status: AsrsOutboundDetailStatus.loading,
        errorMessage: null,
        successMessage: null,
      ),
    );

    try {
      final details = await _service.fetchTaskDetails(
        taskId: task.taskId,
        searchKey: keyword,
      );
      emit(
        state.copyWith(
          status: AsrsOutboundDetailStatus.success,
          details: details,
          selectedIds: state.selectedIds.intersection(
            details.map((e) => e.taskItemId).toSet(),
          ),
          isActionInProgress: false,
          successMessage: successMessage,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AsrsOutboundDetailStatus.failure,
          errorMessage: e.toString(),
          isActionInProgress: false,
        ),
      );
    }
  }
}
