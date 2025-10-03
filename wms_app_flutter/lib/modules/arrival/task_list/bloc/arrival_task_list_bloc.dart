import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/common_widgets/common_grid/grid_bloc.dart';
import 'package:wms_app/common_widgets/common_grid/grid_event.dart';
import 'package:wms_app/common_widgets/common_grid/grid_state.dart';
import 'package:wms_app/modules/arrival/services/arrival_service.dart';
import 'package:wms_app/modules/arrival/task_list/models/arrival_task.dart';

import 'arrival_task_list_event.dart';
import 'arrival_task_list_state.dart';

class ArrivalTaskListBloc extends Bloc<ArrivalTaskListEvent, ArrivalTaskListState> {
  ArrivalTaskListBloc({required ArrivalService service})
      : _service = service,
        super(const ArrivalTaskListState()) {
    _currentQuery = const ArrivalTaskQuery();
    gridBloc = CommonDataGridBloc<ArrivalTask>(
      dataLoader: _createDataLoader(),
    );

    on<ArrivalTaskListSearchSubmitted>(_onSearchSubmitted);
    on<ArrivalTaskListRefreshRequested>(_onRefreshRequested);
    on<ArrivalTaskCancelRequested>(_onCancelRequested);
    on<ArrivalTaskActionMessageCleared>(_onMessageCleared);
  }

  final ArrivalService _service;
  late ArrivalTaskQuery _currentQuery;
  late final CommonDataGridBloc<ArrivalTask> gridBloc;

  DataGridLoader<ArrivalTask> _createDataLoader() {
    return (pageIndex) async {
      final requestPage = pageIndex <= 0 ? 1 : pageIndex;
      _currentQuery = _currentQuery.copyWith(pageIndex: requestPage);
      final result = await _service.getReceivedTasks(_currentQuery);
      final totalPages = (result.total / _currentQuery.pageSize).ceil();
      return DataGridResponseData<ArrivalTask>(
        totalPages: totalPages <= 0 ? 1 : totalPages,
        data: result.rows,
      );
    };
  }

  Future<void> _onSearchSubmitted(
    ArrivalTaskListSearchSubmitted event,
    Emitter<ArrivalTaskListState> emit,
  ) async {
    _currentQuery = _currentQuery.copyWith(searchKey: event.searchKey, pageIndex: 1);
    gridBloc.add(LoadDataEvent<ArrivalTask>(_currentQuery.pageIndex));
  }

  Future<void> _onRefreshRequested(
    ArrivalTaskListRefreshRequested event,
    Emitter<ArrivalTaskListState> emit,
  ) async {
    final targetPage = gridBloc.state.currentPage;
    gridBloc.add(LoadDataEvent<ArrivalTask>(targetPage));
  }

  Future<void> _onCancelRequested(
    ArrivalTaskCancelRequested event,
    Emitter<ArrivalTaskListState> emit,
  ) async {
    emit(state.copyWith(isActionInProgress: true, successMessage: null, errorMessage: null));
    try {
      await _service.cancelArrivalTask(event.arrivalsBillId);
      emit(state.copyWith(
        isActionInProgress: false,
        successMessage: '撤销成功',
        errorMessage: null,
      ));
      final targetPage = gridBloc.state.currentPage;
      gridBloc.add(LoadDataEvent<ArrivalTask>(targetPage));
    } catch (e) {
      emit(state.copyWith(
        isActionInProgress: false,
        successMessage: null,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onMessageCleared(
    ArrivalTaskActionMessageCleared event,
    Emitter<ArrivalTaskListState> emit,
  ) async {
    emit(state.clearMessages());
  }

  @override
  Future<void> close() {
    gridBloc.close();
    return super.close();
  }
}
