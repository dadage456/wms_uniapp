import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/common_widgets/common_grid/grid_bloc.dart';
import 'package:wms_app/common_widgets/common_grid/grid_event.dart';
import 'package:wms_app/modules/floor_inventory/services/floor_inventory_service.dart';
import 'package:wms_app/modules/floor_inventory/task_list/models/inventory_task.dart';
import 'package:wms_app/services/user_manager.dart';

import 'inventory_task_receive_event.dart';
import 'inventory_task_receive_state.dart';

class InventoryTaskReceiveBloc
    extends Bloc<InventoryTaskReceiveEvent, InventoryTaskReceiveState> {
  InventoryTaskReceiveBloc({
    required FloorInventoryService service,
    required UserManager userManager,
  })  : _service = service,
        _userManager = userManager,
        super(const InventoryTaskReceiveState()) {
    final userId = _userManager.userInfo?.userId.toString() ?? '';
    _currentQuery = InventoryTaskQuery(
      userId: 'ALL',
      roleOrUserId: userId,
    );

    gridBloc = CommonDataGridBloc<InventoryTask>(
      dataLoader: _createLoader(),
    );

    on<InventoryTaskReceiveSearchSubmitted>(_onSearchSubmitted);
    on<InventoryTaskReceiveRefreshRequested>(_onRefreshRequested);
    on<InventoryTaskReceiveConfirmed>(_onConfirmed);
    on<InventoryTaskReceiveMessageCleared>(_onMessageCleared);
  }

  final FloorInventoryService _service;
  final UserManager _userManager;
  late InventoryTaskQuery _currentQuery;
  late final CommonDataGridBloc<InventoryTask> gridBloc;

  DataGridLoader<InventoryTask> _createLoader() {
    return (pageIndex) async {
      final requestPage = pageIndex <= 0 ? 1 : pageIndex;
      _currentQuery = _currentQuery.copyWith(pageIndex: requestPage);
      final result = await _service.getInventoryTasks(_currentQuery);
      final totalPages = (result.total / _currentQuery.pageSize).ceil();
      return DataGridResponseData(
        totalPages: totalPages <= 0 ? 1 : totalPages,
        data: result.rows,
      );
    };
  }

  Future<void> _onSearchSubmitted(
    InventoryTaskReceiveSearchSubmitted event,
    Emitter<InventoryTaskReceiveState> emit,
  ) async {
    _currentQuery = _currentQuery.copyWith(
      searchKey: event.keyword,
      pageIndex: 1,
    );
    gridBloc.add(LoadDataEvent<InventoryTask>(_currentQuery.pageIndex));
  }

  Future<void> _onRefreshRequested(
    InventoryTaskReceiveRefreshRequested event,
    Emitter<InventoryTaskReceiveState> emit,
  ) async {
    gridBloc.add(LoadDataEvent<InventoryTask>(gridBloc.state.currentPage));
  }

  Future<void> _onConfirmed(
    InventoryTaskReceiveConfirmed event,
    Emitter<InventoryTaskReceiveState> emit,
  ) async {
    emit(state.copyWith(isActionInProgress: true, successMessage: null, errorMessage: null));
    try {
      await _service.commitInventoryTask(
        taskComment: event.task.taskNo.isNotEmpty ? event.task.taskNo : event.task.taskComment,
        userId: _userManager.userInfo?.userId.toString() ?? '',
        isCancel: false,
      );
      emit(state.copyWith(successMessage: '接收成功', isActionInProgress: false));
      gridBloc.add(LoadDataEvent<InventoryTask>(gridBloc.state.currentPage));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString(), isActionInProgress: false));
    }
  }

  Future<void> _onMessageCleared(
    InventoryTaskReceiveMessageCleared event,
    Emitter<InventoryTaskReceiveState> emit,
  ) async {
    emit(state.clearMessages());
  }

  @override
  Future<void> close() {
    gridBloc.close();
    return super.close();
  }
}
