import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/common_widgets/common_grid/grid_bloc.dart';
import 'package:wms_app/common_widgets/common_grid/grid_event.dart';
import 'package:wms_app/modules/floor_inventory/services/floor_inventory_service.dart';
import 'package:wms_app/modules/floor_inventory/task_list/models/inventory_task.dart';
import 'package:wms_app/services/user_manager.dart';

import 'inventory_task_list_event.dart';
import 'inventory_task_list_state.dart';

class InventoryTaskListBloc extends Bloc<InventoryTaskListEvent, InventoryTaskListState> {
  InventoryTaskListBloc({
    required FloorInventoryService service,
    required UserManager userManager,
  })  : _service = service,
        _userManager = userManager,
        super(const InventoryTaskListState()) {
    final userId = _userManager.userInfo?.userId.toString() ?? '';
    _currentQuery = InventoryTaskQuery(
      userId: userId,
      roleOrUserId: userId,
    );

    gridBloc = CommonDataGridBloc<InventoryTask>(
      dataLoader: _createLoader(),
    );

    on<InventoryTaskListSearchSubmitted>(_onSearchSubmitted);
    on<InventoryTaskListRefreshRequested>(_onRefreshRequested);
    on<InventoryTaskCancelRequested>(_onCancelRequested);
    on<InventoryTaskMessageCleared>(_onMessageCleared);
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
    InventoryTaskListSearchSubmitted event,
    Emitter<InventoryTaskListState> emit,
  ) async {
    _currentQuery = _currentQuery.copyWith(
      searchKey: event.keyword,
      pageIndex: 1,
    );
    gridBloc.add(LoadDataEvent<InventoryTask>(_currentQuery.pageIndex));
  }

  Future<void> _onRefreshRequested(
    InventoryTaskListRefreshRequested event,
    Emitter<InventoryTaskListState> emit,
  ) async {
    gridBloc.add(LoadDataEvent<InventoryTask>(gridBloc.state.currentPage));
  }

  Future<void> _onCancelRequested(
    InventoryTaskCancelRequested event,
    Emitter<InventoryTaskListState> emit,
  ) async {
    emit(state.copyWith(isActionInProgress: true, successMessage: null, errorMessage: null));
    try {
      await _service.commitInventoryTask(
        taskComment: event.task.taskNo.isNotEmpty ? event.task.taskNo : event.task.taskComment,
        userId: _userManager.userInfo?.userId.toString() ?? '',
        isCancel: true,
      );
      emit(state.copyWith(successMessage: '撤销成功', isActionInProgress: false));
      gridBloc.add(LoadDataEvent<InventoryTask>(gridBloc.state.currentPage));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString(), isActionInProgress: false));
    }
  }

  Future<void> _onMessageCleared(
    InventoryTaskMessageCleared event,
    Emitter<InventoryTaskListState> emit,
  ) async {
    emit(state.clearMessages());
  }

  @override
  Future<void> close() {
    gridBloc.close();
    return super.close();
  }
}
