import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/modules/asrs_inbound/services/asrs_inbound_service.dart';
import 'package:wms_app/modules/asrs_inbound/task_detail/bloc/asrs_inbound_detail_event.dart';
import 'package:wms_app/modules/asrs_inbound/task_detail/bloc/asrs_inbound_detail_state.dart';

class AsrsInboundDetailBloc
    extends Bloc<AsrsInboundDetailEvent, AsrsInboundDetailState> {
  AsrsInboundDetailBloc({required AsrsInboundService service})
      : _service = service,
        super(const AsrsInboundDetailState()) {
    on<AsrsInboundDetailLoaded>(_onLoaded);
    on<AsrsInboundDetailSearchChanged>(
      _onSearchChanged,
      transformer: (events, mapper) => events
          .distinct((previous, next) => previous.keyword == next.keyword)
          .asyncExpand(mapper),
    );
    on<AsrsInboundDetailRefreshed>(_onRefreshed);
  }

  final AsrsInboundService _service;

  Future<void> _onLoaded(
    AsrsInboundDetailLoaded event,
    Emitter<AsrsInboundDetailState> emit,
  ) async {
    emit(state.copyWith(status: AsrsInboundDetailStatus.loading, task: event.task));
    await _fetchDetail(emit, keyword: state.keyword, task: event.task);
  }

  Future<void> _onSearchChanged(
    AsrsInboundDetailSearchChanged event,
    Emitter<AsrsInboundDetailState> emit,
  ) async {
    if (state.task == null) return;
    emit(state.copyWith(keyword: event.keyword));
    await _fetchDetail(emit, keyword: event.keyword, task: state.task);
  }

  Future<void> _onRefreshed(
    AsrsInboundDetailRefreshed event,
    Emitter<AsrsInboundDetailState> emit,
  ) async {
    if (state.task == null) return;
    await _fetchDetail(emit, keyword: state.keyword, task: state.task);
  }

  Future<void> _fetchDetail(
    Emitter<AsrsInboundDetailState> emit, {
    required String? keyword,
    required AsrsInboundTask? task,
  }) async {
    if (task == null) return;

    emit(
      state.copyWith(
        status: AsrsInboundDetailStatus.loading,
        errorMessage: null,
      ),
    );

    try {
      final details = await _service.fetchTaskDetails(
        taskId: task.taskId,
        keyword: keyword,
      );
      final trayInfos = await _service.fetchTrayInfos(task.taskId);
      emit(
        state.copyWith(
          status: AsrsInboundDetailStatus.success,
          task: task,
          details: details,
          trayInfos: trayInfos,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AsrsInboundDetailStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
