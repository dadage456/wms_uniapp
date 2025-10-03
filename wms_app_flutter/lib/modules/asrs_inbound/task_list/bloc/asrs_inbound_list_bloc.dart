import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/modules/asrs_inbound/services/asrs_inbound_service.dart';
import 'package:wms_app/modules/asrs_inbound/task_list/bloc/asrs_inbound_list_event.dart';
import 'package:wms_app/modules/asrs_inbound/task_list/bloc/asrs_inbound_list_state.dart';

class AsrsInboundListBloc
    extends Bloc<AsrsInboundListEvent, AsrsInboundListState> {
  AsrsInboundListBloc({required AsrsInboundService service})
      : _service = service,
        super(const AsrsInboundListState()) {
    on<AsrsInboundListInitialized>(_onInitialized);
    on<AsrsInboundListKeywordChanged>(
      _onKeywordChanged,
      transformer: (events, mapper) => events
          .distinct((previous, next) => previous.keyword == next.keyword)
          .asyncExpand(mapper),
    );
    on<AsrsInboundListRefreshed>(_onRefreshed);
  }

  final AsrsInboundService _service;

  Future<void> _onInitialized(
    AsrsInboundListInitialized event,
    Emitter<AsrsInboundListState> emit,
  ) async {
    emit(state.copyWith(keyword: event.keyword ?? state.keyword));
    await _loadTasks(emit, keyword: event.keyword ?? state.keyword);
  }

  Future<void> _onKeywordChanged(
    AsrsInboundListKeywordChanged event,
    Emitter<AsrsInboundListState> emit,
  ) async {
    emit(state.copyWith(keyword: event.keyword));
    await _loadTasks(emit, keyword: event.keyword);
  }

  Future<void> _onRefreshed(
    AsrsInboundListRefreshed event,
    Emitter<AsrsInboundListState> emit,
  ) async {
    await _loadTasks(emit, keyword: state.keyword);
  }

  Future<void> _loadTasks(
    Emitter<AsrsInboundListState> emit, {
    String? keyword,
    String? successMessage,
  }) async {
    emit(
      state.copyWith(
        status: AsrsInboundListStatus.loading,
        errorMessage: null,
        successMessage: null,
      ),
    );

    try {
      final tasks = await _service.fetchTaskList(keyword: keyword);
      emit(
        state.copyWith(
          status: AsrsInboundListStatus.success,
          tasks: tasks,
          successMessage: successMessage,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AsrsInboundListStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
