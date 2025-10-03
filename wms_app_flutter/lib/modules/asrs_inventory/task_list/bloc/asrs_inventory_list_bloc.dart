import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/modules/asrs_inventory/services/asrs_inventory_service.dart';
import 'package:wms_app/modules/asrs_inventory/task_list/bloc/asrs_inventory_list_event.dart';
import 'package:wms_app/modules/asrs_inventory/task_list/bloc/asrs_inventory_list_state.dart';

class AsrsInventoryListBloc
    extends Bloc<AsrsInventoryListEvent, AsrsInventoryListState> {
  AsrsInventoryListBloc({required AsrsInventoryService service})
      : _service = service,
        super(const AsrsInventoryListState()) {
    on<AsrsInventoryListInitialized>(_onInitialized);
    on<AsrsInventoryListKeywordChanged>(
      _onKeywordChanged,
      transformer: (events, mapper) => events
          .distinct((previous, next) => previous.keyword == next.keyword)
          .asyncExpand(mapper),
    );
    on<AsrsInventoryListToggleProcessing>(_onToggleProcessing);
    on<AsrsInventoryListRefreshed>(_onRefreshed);
  }

  final AsrsInventoryService _service;

  Future<void> _onInitialized(
    AsrsInventoryListInitialized event,
    Emitter<AsrsInventoryListState> emit,
  ) async {
    emit(state.copyWith(keyword: event.keyword ?? state.keyword));
    await _loadTasks(emit, keyword: event.keyword ?? state.keyword);
  }

  Future<void> _onKeywordChanged(
    AsrsInventoryListKeywordChanged event,
    Emitter<AsrsInventoryListState> emit,
  ) async {
    emit(state.copyWith(keyword: event.keyword));
    await _loadTasks(emit, keyword: event.keyword);
  }

  Future<void> _onToggleProcessing(
    AsrsInventoryListToggleProcessing event,
    Emitter<AsrsInventoryListState> emit,
  ) async {
    emit(state.copyWith(onlyProcessing: event.onlyProcessing));
    await _loadTasks(
      emit,
      keyword: state.keyword,
      onlyProcessing: event.onlyProcessing,
    );
  }

  Future<void> _onRefreshed(
    AsrsInventoryListRefreshed event,
    Emitter<AsrsInventoryListState> emit,
  ) async {
    await _loadTasks(
      emit,
      keyword: state.keyword,
      onlyProcessing: state.onlyProcessing,
    );
  }

  Future<void> _loadTasks(
    Emitter<AsrsInventoryListState> emit, {
    String? keyword,
    bool? onlyProcessing,
    String? successMessage,
  }) async {
    emit(
      state.copyWith(
        status: AsrsInventoryListStatus.loading,
        errorMessage: null,
        successMessage: null,
      ),
    );

    try {
      final tasks = await _service.fetchTaskList(
        keyword: keyword,
        onlyProcessing: onlyProcessing ?? state.onlyProcessing,
      );
      emit(
        state.copyWith(
          status: AsrsInventoryListStatus.success,
          tasks: tasks,
          successMessage: successMessage,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AsrsInventoryListStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
