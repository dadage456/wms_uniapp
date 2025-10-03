import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:wms_app/modules/asrs_inventory/collection/bloc/asrs_inventory_collect_event.dart';
import 'package:wms_app/modules/asrs_inventory/collection/bloc/asrs_inventory_collect_state.dart';
import 'package:wms_app/modules/asrs_inventory/models/asrs_inventory_models.dart';
import 'package:wms_app/modules/asrs_inventory/services/asrs_inventory_service.dart';

class AsrsInventoryCollectBloc
    extends Bloc<AsrsInventoryCollectEvent, AsrsInventoryCollectState> {
  AsrsInventoryCollectBloc({required AsrsInventoryService service})
      : _service = service,
        super(const AsrsInventoryCollectState()) {
    on<AsrsInventoryCollectInitialized>(_onInitialized);
    on<AsrsInventoryCollectSearchChanged>(
      _onSearchChanged,
      transformer: (events, mapper) => events
          .debounceTime(const Duration(milliseconds: 200))
          .asyncExpand(mapper),
    );
    on<AsrsInventoryCollectScanReceived>(_onScanReceived);
    on<AsrsInventoryCollectDetailSelected>(_onDetailSelected);
    on<AsrsInventoryCollectQuantityChanged>(_onQuantityChanged);
    on<AsrsInventoryCollectRecordAdded>(_onRecordAdded);
    on<AsrsInventoryCollectRecordRemoved>(_onRecordRemoved);
    on<AsrsInventoryCollectSubmitted>(_onSubmitted);
    on<AsrsInventoryCollectMessagesCleared>(_onMessagesCleared);
  }

  final AsrsInventoryService _service;

  Future<void> _onInitialized(
    AsrsInventoryCollectInitialized event,
    Emitter<AsrsInventoryCollectState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AsrsInventoryCollectStatus.loading,
        task: event.task,
        records: const [],
        keyword: '',
        quantity: 0,
        selectedDetail: null,
        successMessage: null,
        errorMessage: null,
      ),
    );

    try {
      final details = await _service.fetchTaskDetails(
        taskComment: event.task.taskComment,
        taskNo: event.task.taskNo,
        roomTag: '1',
      );
      emit(
        state.copyWith(
          status: AsrsInventoryCollectStatus.ready,
          details: details,
          filteredDetails: details,
          step: AsrsInventoryCollectStep.search,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AsrsInventoryCollectStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  FutureOr<void> _onSearchChanged(
    AsrsInventoryCollectSearchChanged event,
    Emitter<AsrsInventoryCollectState> emit,
  ) {
    final keyword = event.keyword.trim();
    if (state.details.isEmpty) return;

    final filtered = state.details.where((detail) {
      if (keyword.isEmpty) return true;
      final lc = keyword.toLowerCase();
      return detail.materialCode.toLowerCase().contains(lc) ||
          detail.materialName.toLowerCase().contains(lc) ||
          detail.trayNo.toLowerCase().contains(lc) ||
          detail.storeSiteNo.toLowerCase().contains(lc) ||
          (detail.batchNo ?? '').toLowerCase().contains(lc);
    }).toList();

    final hasSingle = filtered.length == 1;
    emit(
      state.copyWith(
        keyword: keyword,
        filteredDetails: filtered,
        step: hasSingle
            ? AsrsInventoryCollectStep.quantity
            : AsrsInventoryCollectStep.search,
        selectedDetail: hasSingle ? filtered.first : state.selectedDetail,
        quantity: hasSingle ? filtered.first.remainingQty : state.quantity,
        errorMessage: null,
        successMessage: null,
      ),
    );
  }

  FutureOr<void> _onScanReceived(
    AsrsInventoryCollectScanReceived event,
    Emitter<AsrsInventoryCollectState> emit,
  ) {
    final code = event.code.trim();
    if (code.isEmpty || state.details.isEmpty) {
      emit(state.copyWith(errorMessage: '扫码内容为空'));
      return;
    }

    final match = state.details.firstWhere(
      (detail) =>
          detail.materialCode == code ||
          detail.trayNo == code ||
          detail.storeSiteNo == code,
      orElse: () => state.details.firstWhere(
        (detail) => detail.materialCode.contains(code),
        orElse: () => state.details.first,
      ),
    );

    emit(
      state.copyWith(
        selectedDetail: match,
        quantity: match.remainingQty,
        step: AsrsInventoryCollectStep.quantity,
        keyword: code,
        successMessage: '已定位到物料 ${match.materialCode}',
        errorMessage: null,
      ),
    );
  }

  FutureOr<void> _onDetailSelected(
    AsrsInventoryCollectDetailSelected event,
    Emitter<AsrsInventoryCollectState> emit,
  ) {
    emit(
      state.copyWith(
        selectedDetail: event.detail,
        step: AsrsInventoryCollectStep.quantity,
        quantity: event.detail.remainingQty,
        successMessage: null,
        errorMessage: null,
      ),
    );
  }

  FutureOr<void> _onQuantityChanged(
    AsrsInventoryCollectQuantityChanged event,
    Emitter<AsrsInventoryCollectState> emit,
  ) {
    emit(state.copyWith(quantity: event.quantity));
  }

  Future<void> _onRecordAdded(
    AsrsInventoryCollectRecordAdded event,
    Emitter<AsrsInventoryCollectState> emit,
  ) async {
    final detail = state.selectedDetail;
    if (detail == null) {
      emit(state.copyWith(errorMessage: '请先选择一条任务明细'));
      return;
    }
    if (state.quantity <= 0) {
      emit(state.copyWith(errorMessage: '采集数量需大于0'));
      return;
    }

    final record = AsrsInventoryCollectionRecord(
      taskItemId: detail.taskItemId,
      storeSiteNo: detail.storeSiteNo,
      materialCode: detail.materialCode,
      materialName: detail.materialName,
      quantity: state.quantity,
      unit: detail.unit,
      batchNo: detail.batchNo,
      serialNo: detail.serialNo,
    );

    emit(
      state.copyWith(
        records: [...state.records, record],
        successMessage: '已添加采集记录',
        errorMessage: null,
        selectedDetail: null,
        quantity: 0,
        step: AsrsInventoryCollectStep.review,
      ),
    );
  }

  FutureOr<void> _onRecordRemoved(
    AsrsInventoryCollectRecordRemoved event,
    Emitter<AsrsInventoryCollectState> emit,
  ) {
    emit(
      state.copyWith(
        records: state.records
            .where((record) => record.id != event.recordId)
            .toList(),
      ),
    );
  }

  Future<void> _onSubmitted(
    AsrsInventoryCollectSubmitted event,
    Emitter<AsrsInventoryCollectState> emit,
  ) async {
    final task = state.task;
    if (task == null) {
      emit(state.copyWith(errorMessage: '任务信息缺失'));
      return;
    }
    if (state.records.isEmpty) {
      emit(state.copyWith(errorMessage: '请先添加采集记录'));
      return;
    }

    emit(state.copyWith(status: AsrsInventoryCollectStatus.submitting));
    try {
      await _service.submitCollection(
        taskComment: task.taskComment,
        records: state.records,
      );
      final refreshedDetails = await _service.fetchTaskDetails(
        taskComment: task.taskComment,
        taskNo: task.taskNo,
        roomTag: '1',
      );
      emit(
        state.copyWith(
          status: AsrsInventoryCollectStatus.ready,
          details: refreshedDetails,
          filteredDetails: refreshedDetails,
          records: const [],
          selectedDetail: null,
          quantity: 0,
          step: AsrsInventoryCollectStep.search,
          successMessage: '提交成功',
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AsrsInventoryCollectStatus.ready,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  FutureOr<void> _onMessagesCleared(
    AsrsInventoryCollectMessagesCleared event,
    Emitter<AsrsInventoryCollectState> emit,
  ) {
    emit(state.clearMessages());
  }
}
