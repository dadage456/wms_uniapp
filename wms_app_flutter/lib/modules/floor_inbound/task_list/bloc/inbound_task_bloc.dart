import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/common_widgets/common_grid/grid_bloc.dart';
import 'package:wms_app/common_widgets/common_grid/grid_event.dart';
import 'package:wms_app/modules/floor_inbound/task_list/models/inbound_task.dart';
import 'package:wms_app/modules/floor_inbound/task_list/bloc/inbound_task_event.dart';
import 'package:wms_app/modules/floor_inbound/task_list/bloc/inbound_task_state.dart';
import 'package:wms_app/modules/floor_inbound/services/floor_inbound_service.dart';
import 'package:wms_app/services/user_manager.dart';

class InboundTaskBloc extends Bloc<InboundTaskEvent, InboundTaskState> {
  InboundTaskBloc({required FloorInboundService service, required UserManager userManager})
      : _service = service,
        _userManager = userManager,
        super(const InboundTaskState()) {
    currentQuery = _defaultQuery();
    gridBloc = CommonDataGridBloc(dataLoader: _createDataLoader());

    on<SearchInboundTasksEvent>(_onSearch);
    on<FilterInboundTasksEvent>(_onFilter);
    on<RefreshInboundTasksEvent>(_onRefresh);
    on<SetInboundTaskUserScopeEvent>(_onSetUserScope);
  }

  final FloorInboundService _service;
  final UserManager _userManager;
  late final CommonDataGridBloc<InboundTask> gridBloc;
  late InboundTaskQuery currentQuery;

  InboundTaskQuery _defaultQuery() {
    final user = _userManager.userInfo;
    final userId = user?.userId.toString() ?? '';
    return InboundTaskQuery(userId: userId, roleOrUserId: userId);
  }

  DataGridLoader<InboundTask> _createDataLoader() {
    return (pageIndex) async {
      final query = currentQuery.copyWith(pageIndex: pageIndex);
      final response = await _service.getTaskList(query);
      final totalPages = (response.total / query.pageSize).ceil();
      return DataGridResponseData(
        totalPages: totalPages <= 0 ? 1 : totalPages,
        data: response.rows,
      );
    };
  }

  Future<void> _onSearch(
    SearchInboundTasksEvent event,
    Emitter<InboundTaskState> emit,
  ) async {
    currentQuery = currentQuery.copyWith(searchKey: event.searchKey, pageIndex: 0);
    gridBloc.add(LoadDataEvent(0));
  }

  Future<void> _onFilter(
    FilterInboundTasksEvent event,
    Emitter<InboundTaskState> emit,
  ) async {
    emit(state.copyWith(finishFlag: event.finishFlag));
    currentQuery = currentQuery.copyWith(finishFlag: event.finishFlag, pageIndex: 0);
    final completer = Completer<DataGridResponseData<InboundTask>>();
    gridBloc.add(LoadDataEvent(0, completer: completer));
    await completer.future;
  }

  Future<void> _onRefresh(
    RefreshInboundTasksEvent event,
    Emitter<InboundTaskState> emit,
  ) async {
    gridBloc.add(LoadDataEvent(0));
  }

  Future<void> _onSetUserScope(
    SetInboundTaskUserScopeEvent event,
    Emitter<InboundTaskState> emit,
  ) async {
    currentQuery = currentQuery.copyWith(
      userId: event.userId,
      roleOrUserId: event.roleOrUserId,
      pageIndex: 0,
    );
  }
}
