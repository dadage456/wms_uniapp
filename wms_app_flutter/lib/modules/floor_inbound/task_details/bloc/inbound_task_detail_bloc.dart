import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/modules/floor_inbound/services/floor_inbound_service.dart';
import 'package:wms_app/modules/outbound/task_details/models/commit_task_item_result.dart';

import '../models/inbound_task_item.dart';
import 'inbound_task_detail_event.dart';
import 'inbound_task_detail_state.dart';

class InboundTaskDetailBloc extends Bloc<InboundTaskDetailEvent, InboundTaskDetailState> {
  InboundTaskDetailBloc(this._service) : super(const InboundTaskDetailState()) {
    on<InitializeInboundTaskDetail>(_onInitialize);
    on<SearchInboundTaskItems>(_onSearch);
    on<ToggleInboundTaskItemSelection>(_onToggleSelection);
    on<SelectAllInboundTaskItems>(_onSelectAll);
    on<CommitInboundTaskItems>(_onCommit);
    on<RefreshInboundTaskItems>(_onRefresh);
  }

  final FloorInboundService _service;

  Future<void> _onInitialize(
    InitializeInboundTaskDetail event,
    Emitter<InboundTaskDetailState> emit,
  ) async {
    final query = InboundTaskItemQuery(
      inTaskId: event.inTaskId,
      workStation: event.workStation,
    );
    emit(state.copyWith(query: query, selectedIds: {}));
    await _load(query, emit);
  }

  Future<void> _onSearch(
    SearchInboundTaskItems event,
    Emitter<InboundTaskDetailState> emit,
  ) async {
    final currentQuery = state.query;
    if (currentQuery == null) return;
    try {
      final keyword = event.decode
          ? await _resolveSearchKeyword(event.keyword)
          : event.keyword.trim();
      final query = currentQuery.copyWith(searchKey: keyword, pageIndex: 0);
      emit(state.copyWith(query: query, errorMessage: null));
      await _load(query, emit);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _onRefresh(
    RefreshInboundTaskItems event,
    Emitter<InboundTaskDetailState> emit,
  ) async {
    final query = state.query;
    if (query == null) return;
    await _load(query, emit);
  }

  Future<void> _load(
    InboundTaskItemQuery query,
    Emitter<InboundTaskDetailState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      final response = await _service.getTaskItems(query);
      emit(
        state.copyWith(
          isLoading: false,
          items: response.rows,
          selectedIds: state.selectedIds.intersection(response.rows.map((e) => e.itemId).toSet()),
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _onToggleSelection(
    ToggleInboundTaskItemSelection event,
    Emitter<InboundTaskDetailState> emit,
  ) async {
    final newSet = Set<String>.from(state.selectedIds);
    if (newSet.contains(event.itemId)) {
      newSet.remove(event.itemId);
    } else {
      newSet.add(event.itemId);
    }
    emit(state.copyWith(selectedIds: newSet));
  }

  Future<void> _onSelectAll(
    SelectAllInboundTaskItems event,
    Emitter<InboundTaskDetailState> emit,
  ) async {
    if (event.checked) {
      emit(state.copyWith(selectedIds: state.items.map((e) => e.itemId).toSet()));
    } else {
      emit(state.copyWith(selectedIds: {}));
    }
  }

  Future<void> _onCommit(
    CommitInboundTaskItems event,
    Emitter<InboundTaskDetailState> emit,
  ) async {
    if (state.selectedIds.isEmpty) {
      return;
    }
    emit(state.copyWith(isLoading: true));
    try {
      final CommitTaskItemResult result = await _service.commitTaskItems(
        taskItemIds: state.selectedIds.toList(),
        isCancel: event.cancel,
      );
      emit(state.copyWith(isLoading: false));
      if (result.success) {
        final query = state.query;
        if (query != null) {
          await _load(query, emit);
        }
      } else {
        emit(state.copyWith(errorMessage: '操作失败:${result.action}'));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<String> _resolveSearchKeyword(String raw) async {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    if (trimmed.contains(r'$KW$')) {
      final parts = trimmed.split(r'$');
      if (parts.length > 2 && parts[2].isNotEmpty) {
        return parts[2];
      }
      throw Exception('库位条码解析失败');
    }
    if (trimmed.toUpperCase().contains('MC')) {
      final info = await _service.getMaterialInfo(trimmed);
      final matCode = info.matCode.trim();
      if (matCode.isEmpty) {
        throw Exception('物料二维码无法识别');
      }
      return matCode;
    }
    return trimmed;
  }
}
