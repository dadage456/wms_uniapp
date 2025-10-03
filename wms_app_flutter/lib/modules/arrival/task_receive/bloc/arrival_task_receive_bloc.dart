import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/common_widgets/common_grid/grid_bloc.dart';
import 'package:wms_app/common_widgets/common_grid/grid_event.dart';
import 'package:wms_app/modules/arrival/services/arrival_service.dart';
import 'package:wms_app/modules/arrival/task_list/models/arrival_task.dart';

import 'arrival_task_receive_event.dart';
import 'arrival_task_receive_state.dart';

class ArrivalTaskReceiveBloc
    extends Bloc<ArrivalTaskReceiveEvent, ArrivalTaskReceiveState> {
  ArrivalTaskReceiveBloc({required ArrivalService service})
      : _service = service,
        super(const ArrivalTaskReceiveState()) {
    _currentQuery = const ArrivalTaskQuery();
    gridBloc = CommonDataGridBloc<ArrivalTask>(
      dataLoader: _createDataLoader(),
    );

    on<ArrivalTaskReceiveSearchSubmitted>(_onSearchSubmitted);
    on<ArrivalTaskReceiveRefreshRequested>(_onRefreshRequested);
    on<ArrivalTaskReceiveConfirmed>(_onReceiveConfirmed);
    on<ArrivalTaskReceiveMessageCleared>(_onMessageCleared);
  }

  final ArrivalService _service;
  late ArrivalTaskQuery _currentQuery;
  late final CommonDataGridBloc<ArrivalTask> gridBloc;

  DataGridLoader<ArrivalTask> _createDataLoader() {
    return (pageIndex) async {
      final requestPage = pageIndex <= 0 ? 1 : pageIndex;
      _currentQuery = _currentQuery.copyWith(pageIndex: requestPage);
      final result = await _service.getPendingReceiveTasks(_currentQuery);
      final totalPages = (result.total / _currentQuery.pageSize).ceil();
      return DataGridResponseData<ArrivalTask>(
        totalPages: totalPages <= 0 ? 1 : totalPages,
        data: result.rows,
      );
    };
  }

  Future<void> _onSearchSubmitted(
    ArrivalTaskReceiveSearchSubmitted event,
    Emitter<ArrivalTaskReceiveState> emit,
  ) async {
    _currentQuery = _currentQuery.copyWith(searchKey: event.searchKey, pageIndex: 1);
    gridBloc.add(LoadDataEvent<ArrivalTask>(_currentQuery.pageIndex));
  }

  Future<void> _onRefreshRequested(
    ArrivalTaskReceiveRefreshRequested event,
    Emitter<ArrivalTaskReceiveState> emit,
  ) async {
    final targetPage = gridBloc.state.currentPage;
    gridBloc.add(LoadDataEvent<ArrivalTask>(targetPage));
  }

  Future<void> _onReceiveConfirmed(
    ArrivalTaskReceiveConfirmed event,
    Emitter<ArrivalTaskReceiveState> emit,
  ) async {
    emit(state.copyWith(isProcessing: true, successMessage: null, errorMessage: null));
    try {
      await _service.receiveArrivalTask(event.arrivalsBillId);
      emit(state.copyWith(
        isProcessing: false,
        successMessage: '接收成功',
        errorMessage: null,
      ));
      final targetPage = gridBloc.state.currentPage;
      gridBloc.add(LoadDataEvent<ArrivalTask>(targetPage));
    } catch (e) {
      emit(state.copyWith(
        isProcessing: false,
        successMessage: null,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onMessageCleared(
    ArrivalTaskReceiveMessageCleared event,
    Emitter<ArrivalTaskReceiveState> emit,
  ) async {
    emit(state.clearMessages());
  }

  @override
  Future<void> close() {
    gridBloc.close();
    return super.close();
  }
}
