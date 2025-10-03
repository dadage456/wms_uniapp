import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/modules/floor_inventory/services/floor_inventory_service.dart';
import 'package:wms_app/modules/floor_inventory/task_details/models/inventory_task_detail.dart';

import 'inventory_task_detail_event.dart';
import 'inventory_task_detail_state.dart';

class InventoryTaskDetailBloc
    extends Bloc<InventoryTaskDetailEvent, InventoryTaskDetailState> {
  InventoryTaskDetailBloc({required FloorInventoryService service})
      : _service = service,
        super(const InventoryTaskDetailState()) {
    on<InventoryTaskDetailLoaded>(_onLoaded);
    on<InventoryTaskDetailRefreshed>(_onRefreshed);
  }

  final FloorInventoryService _service;
  InventoryTaskDetailQuery? _query;

  Future<void> _onLoaded(
    InventoryTaskDetailLoaded event,
    Emitter<InventoryTaskDetailState> emit,
  ) async {
    _query = InventoryTaskDetailQuery(
      taskComment: event.taskComment,
      taskNo: event.taskNo,
    );
    await _loadDetails(emit);
  }

  Future<void> _onRefreshed(
    InventoryTaskDetailRefreshed event,
    Emitter<InventoryTaskDetailState> emit,
  ) async {
    await _loadDetails(emit);
  }

  Future<void> _loadDetails(Emitter<InventoryTaskDetailState> emit) async {
    final query = _query;
    if (query == null) {
      return;
    }
    emit(state.copyWith(status: InventoryTaskDetailStatus.loading));
    try {
      final result = await _service.getInventoryTaskItems(query);
      emit(
        state.copyWith(
          status: InventoryTaskDetailStatus.success,
          details: result.rows,
          errorMessage: null,
          taskComment: query.taskComment,
          taskNo: query.taskNo,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: InventoryTaskDetailStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
