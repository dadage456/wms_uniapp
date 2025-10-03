import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/modules/asrs_outbound/models/asrs_outbound_models.dart';
import 'package:wms_app/modules/asrs_outbound/services/asrs_outbound_service.dart';
import 'package:wms_app/modules/asrs_outbound/task_list/bloc/asrs_outbound_list_event.dart';
import 'package:wms_app/modules/asrs_outbound/task_list/bloc/asrs_outbound_list_state.dart';

class AsrsOutboundListBloc
    extends Bloc<AsrsOutboundListEvent, AsrsOutboundListState> {
  AsrsOutboundListBloc({required AsrsOutboundService service})
      : _service = service,
        super(const AsrsOutboundListState()) {
    on<AsrsOutboundListInitialized>(_onInitialized);
    on<AsrsOutboundListKeywordChanged>(_onKeywordChanged,
        transformer: (events, mapper) => events
            .distinct((previous, next) => previous.keyword == next.keyword)
            .asyncExpand(mapper));
    on<AsrsOutboundListRefreshed>(_onRefreshed);
    on<AsrsOutboundListReceiveRequested>(_onReceiveRequested);
  }

  final AsrsOutboundService _service;

  Future<void> _onInitialized(
    AsrsOutboundListInitialized event,
    Emitter<AsrsOutboundListState> emit,
  ) async {
    emit(state.copyWith(keyword: event.keyword ?? state.keyword));
    await _loadTasks(emit, keyword: event.keyword ?? state.keyword);
  }

  Future<void> _onKeywordChanged(
    AsrsOutboundListKeywordChanged event,
    Emitter<AsrsOutboundListState> emit,
  ) async {
    emit(state.copyWith(keyword: event.keyword));
    await _loadTasks(emit, keyword: event.keyword);
  }

  Future<void> _onRefreshed(
    AsrsOutboundListRefreshed event,
    Emitter<AsrsOutboundListState> emit,
  ) async {
    await _loadTasks(emit, keyword: state.keyword);
  }

  Future<void> _onReceiveRequested(
    AsrsOutboundListReceiveRequested event,
    Emitter<AsrsOutboundListState> emit,
  ) async {
    if (event.taskItemIds.isEmpty) {
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
        taskItemIds: event.taskItemIds,
        roomTag: '0',
        cancel: event.cancel,
      );
      await _loadTasks(
        emit,
        keyword: state.keyword,
        successMessage: event.cancel ? '撤销成功' : '接收成功',
      );
    } catch (e) {
      emit(
        state.copyWith(
          isActionInProgress: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _loadTasks(
    Emitter<AsrsOutboundListState> emit, {
    String? keyword,
    String? successMessage,
  }) async {
    emit(
      state.copyWith(
        status: AsrsOutboundListStatus.loading,
        errorMessage: null,
        successMessage: null,
      ),
    );

    try {
      final tasks = await _service.fetchTaskList(keyword: keyword);
      emit(
        state.copyWith(
          status: AsrsOutboundListStatus.success,
          tasks: tasks,
          successMessage: successMessage,
          isActionInProgress: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AsrsOutboundListStatus.failure,
          errorMessage: e.toString(),
          isActionInProgress: false,
        ),
      );
    }
  }
}
