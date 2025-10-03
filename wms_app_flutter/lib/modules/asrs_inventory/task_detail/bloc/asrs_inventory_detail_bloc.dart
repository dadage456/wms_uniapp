import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:wms_app/modules/asrs_inventory/models/asrs_inventory_models.dart';
import 'package:wms_app/modules/asrs_inventory/services/asrs_inventory_service.dart';
import 'package:wms_app/modules/asrs_inventory/task_detail/bloc/asrs_inventory_detail_event.dart';
import 'package:wms_app/modules/asrs_inventory/task_detail/bloc/asrs_inventory_detail_state.dart';

class AsrsInventoryDetailBloc
    extends Bloc<AsrsInventoryDetailEvent, AsrsInventoryDetailState> {
  AsrsInventoryDetailBloc({required AsrsInventoryService service})
      : _service = service,
        super(const AsrsInventoryDetailState()) {
    on<AsrsInventoryDetailLoaded>(_onLoaded);
    on<AsrsInventoryDetailSearchChanged>(
      _onSearchChanged,
      transformer: (events, mapper) => events
          .debounceTime(const Duration(milliseconds: 300))
          .asyncExpand(mapper),
    );
    on<AsrsInventoryDetailRefreshed>(_onRefreshed);
  }

  final AsrsInventoryService _service;

  Future<void> _onLoaded(
    AsrsInventoryDetailLoaded event,
    Emitter<AsrsInventoryDetailState> emit,
  ) async {
    emit(state.copyWith(task: event.task));
    await _loadDetails(emit, task: event.task);
  }

  Future<void> _onSearchChanged(
    AsrsInventoryDetailSearchChanged event,
    Emitter<AsrsInventoryDetailState> emit,
  ) async {
    if (state.task == null) return;
    emit(state.copyWith(keyword: event.keyword));
    await _loadDetails(
      emit,
      task: state.task!,
      keyword: event.keyword,
    );
  }

  Future<void> _onRefreshed(
    AsrsInventoryDetailRefreshed event,
    Emitter<AsrsInventoryDetailState> emit,
  ) async {
    if (state.task == null) return;
    await _loadDetails(
      emit,
      task: state.task!,
      keyword: state.keyword,
    );
  }

  Future<void> _loadDetails(
    Emitter<AsrsInventoryDetailState> emit, {
    required AsrsInventoryTask task,
    String? keyword,
  }) async {
    emit(
      state.copyWith(
        status: AsrsInventoryDetailStatus.loading,
        errorMessage: null,
      ),
    );

    try {
      final details = await _service.fetchTaskDetails(
        taskComment: task.taskComment,
        taskNo: task.taskNo,
        roomTag: '1',
        keyword: keyword,
      );
      final trayItems = await _service.fetchTrayItems(taskId: task.taskId);
      emit(
        state.copyWith(
          status: AsrsInventoryDetailStatus.success,
          details: details,
          trayItems: trayItems,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AsrsInventoryDetailStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
