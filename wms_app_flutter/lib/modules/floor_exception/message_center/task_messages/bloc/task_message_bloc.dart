import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/common_widgets/common_grid/grid_bloc.dart';
import 'package:wms_app/common_widgets/common_grid/grid_event.dart';
import 'package:wms_app/modules/floor_exception/message_center/task_messages/bloc/task_message_event.dart';
import 'package:wms_app/modules/floor_exception/message_center/task_messages/bloc/task_message_state.dart';
import 'package:wms_app/modules/floor_exception/message_center/task_messages/models/exception_task_message.dart';
import 'package:wms_app/modules/floor_exception/services/floor_exception_service.dart';
import 'package:wms_app/services/user_manager.dart';

class TaskMessageBloc extends Bloc<TaskMessageEvent, TaskMessageState> {
  TaskMessageBloc({
    required FloorExceptionService service,
    required UserManager userManager,
  })  : _service = service,
        _userManager = userManager,
        super(const TaskMessageState()) {
    final userId = _userManager.userInfo?.userId.toString() ?? '';
    _currentQuery = ExceptionTaskMessageQuery(
      userId: userId,
      roleOrUserId: userId,
    );

    gridBloc = CommonDataGridBloc<ExceptionTaskMessage>(
      dataLoader: _createLoader(),
    );

    on<TaskMessageSearchSubmitted>(_onSearchSubmitted);
    on<TaskMessageRefreshRequested>(_onRefreshRequested);
    on<TaskMessageConfirmRequested>(_onConfirmRequested);
    on<TaskMessageClearFeedback>(_onClearFeedback);
  }

  final FloorExceptionService _service;
  final UserManager _userManager;
  late ExceptionTaskMessageQuery _currentQuery;
  late final CommonDataGridBloc<ExceptionTaskMessage> gridBloc;

  DataGridLoader<ExceptionTaskMessage> _createLoader() {
    return (pageIndex) async {
      final requestPage = pageIndex <= 0 ? 1 : pageIndex;
      _currentQuery = _currentQuery.copyWith(pageIndex: requestPage);
      final result = await _service.getTaskMessages(_currentQuery);
      final totalPages = (result.total / _currentQuery.pageSize).ceil();
      return DataGridResponseData(
        totalPages: totalPages <= 0 ? 1 : totalPages,
        data: result.rows,
      );
    };
  }

  Future<void> _onSearchSubmitted(
    TaskMessageSearchSubmitted event,
    Emitter<TaskMessageState> emit,
  ) async {
    _currentQuery = _currentQuery.copyWith(
      searchKey: event.keyword,
      pageIndex: 1,
    );
    gridBloc.add(LoadDataEvent<ExceptionTaskMessage>(_currentQuery.pageIndex));
  }

  Future<void> _onRefreshRequested(
    TaskMessageRefreshRequested event,
    Emitter<TaskMessageState> emit,
  ) async {
    gridBloc.add(LoadDataEvent<ExceptionTaskMessage>(gridBloc.state.currentPage));
  }

  Future<void> _onConfirmRequested(
    TaskMessageConfirmRequested event,
    Emitter<TaskMessageState> emit,
  ) async {
    emit(state.copyWith(isProcessing: true, successMessage: null, errorMessage: null));
    try {
      await _service.confirmTaskMessage(event.message.messageId);
      emit(state.copyWith(isProcessing: false, successMessage: '消息确认成功'));
      gridBloc.add(LoadDataEvent<ExceptionTaskMessage>(gridBloc.state.currentPage));
    } catch (e) {
      emit(state.copyWith(isProcessing: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onClearFeedback(
    TaskMessageClearFeedback event,
    Emitter<TaskMessageState> emit,
  ) async {
    emit(state.clearMessages());
  }

  @override
  Future<void> close() {
    gridBloc.close();
    return super.close();
  }
}
