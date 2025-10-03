import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/common_widgets/common_grid/grid_bloc.dart';
import 'package:wms_app/common_widgets/common_grid/grid_event.dart';
import 'package:wms_app/modules/floor_exception/exception_task_list/models/exception_task.dart';
import 'package:wms_app/modules/floor_exception/services/floor_exception_service.dart';
import 'package:wms_app/services/user_manager.dart';

import 'exception_task_list_event.dart';
import 'exception_task_list_state.dart';

class ExceptionTaskListBloc
    extends Bloc<ExceptionTaskListEvent, ExceptionTaskListState> {
  ExceptionTaskListBloc({
    required FloorExceptionService service,
    required UserManager userManager,
  })  : _service = service,
        _userManager = userManager,
        super(const ExceptionTaskListState()) {
    final userId = _userManager.userInfo?.userId.toString() ?? '';
    _currentQuery = ExceptionTaskQuery(userId: userId, roleOrUserId: userId);

    gridBloc = CommonDataGridBloc<ExceptionTaskRecord>(
      dataLoader: _createLoader(),
    );

    on<ExceptionTaskListSearchSubmitted>(_onSearchSubmitted);
    on<ExceptionTaskListRefreshRequested>(_onRefreshRequested);
    on<ExceptionTaskListReprocessRequested>(_onReprocessRequested);
    on<ExceptionTaskListMessageCleared>(_onMessageCleared);
  }

  final FloorExceptionService _service;
  final UserManager _userManager;
  late ExceptionTaskQuery _currentQuery;
  late final CommonDataGridBloc<ExceptionTaskRecord> gridBloc;

  DataGridLoader<ExceptionTaskRecord> _createLoader() {
    return (pageIndex) async {
      final requestPage = pageIndex <= 0 ? 1 : pageIndex;
      _currentQuery = _currentQuery.copyWith(pageIndex: requestPage);
      final result = await _service.getExceptionTasks(_currentQuery);
      final totalPages = (result.total / _currentQuery.pageSize).ceil();
      return DataGridResponseData(
        totalPages: totalPages <= 0 ? 1 : totalPages,
        data: result.rows,
      );
    };
  }

  Future<void> _onSearchSubmitted(
    ExceptionTaskListSearchSubmitted event,
    Emitter<ExceptionTaskListState> emit,
  ) async {
    _currentQuery = _currentQuery.copyWith(
      searchKey: event.keyword,
      pageIndex: 1,
    );
    gridBloc.add(LoadDataEvent<ExceptionTaskRecord>(_currentQuery.pageIndex));
  }

  Future<void> _onRefreshRequested(
    ExceptionTaskListRefreshRequested event,
    Emitter<ExceptionTaskListState> emit,
  ) async {
    gridBloc.add(LoadDataEvent<ExceptionTaskRecord>(gridBloc.state.currentPage));
  }

  Future<void> _onReprocessRequested(
    ExceptionTaskListReprocessRequested event,
    Emitter<ExceptionTaskListState> emit,
  ) async {
    emit(
      state.copyWith(
        isActionInProgress: true,
        successMessage: null,
        errorMessage: null,
      ),
    );

    try {
      await _service.reprocessException(event.record.dcConnectId);
      emit(
        state.copyWith(
          isActionInProgress: false,
          successMessage: '重新处理成功',
        ),
      );
      gridBloc.add(LoadDataEvent<ExceptionTaskRecord>(gridBloc.state.currentPage));
    } catch (e) {
      emit(
        state.copyWith(
          isActionInProgress: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onMessageCleared(
    ExceptionTaskListMessageCleared event,
    Emitter<ExceptionTaskListState> emit,
  ) async {
    emit(state.clearMessages());
  }

  @override
  Future<void> close() {
    gridBloc.close();
    return super.close();
  }
}
