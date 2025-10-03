import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/modules/floor_inventory/services/floor_inventory_service.dart';
import 'package:wms_app/modules/floor_inventory/task_collect/bloc/inventory_collect_event.dart';
import 'package:wms_app/modules/floor_inventory/task_collect/bloc/inventory_collect_state.dart';
import 'package:wms_app/modules/floor_inventory/task_collect/models/inventory_collect_models.dart';
import 'package:wms_app/modules/floor_inventory/task_details/models/inventory_task_detail.dart';

class InventoryCollectBloc
    extends Bloc<InventoryCollectEvent, InventoryCollectState> {
  InventoryCollectBloc({required FloorInventoryService service})
    : _service = service,
      super(const InventoryCollectState()) {
    on<InventoryCollectStarted>(_onStarted);
    on<InventoryCollectRefreshRequested>(_onRefreshRequested);
    on<InventoryCollectTabChanged>(_onTabChanged);
    on<InventoryCollectScanReceived>(_onScanReceived);
    on<InventoryCollectManualQuantityChanged>(_onQuantityChanged);
    on<InventoryCollectQuantitySubmitted>(_onQuantitySubmitted);
    on<InventoryCollectRecordRemoved>(_onRecordRemoved);
    on<InventoryCollectSubmitRequested>(_onSubmitRequested);
    on<InventoryCollectResetRequested>(_onResetRequested);
    on<InventoryCollectMessageCleared>(_onMessageCleared);
  }

  final FloorInventoryService _service;
  InventoryTaskDetailQuery? _query;

  Future<void> _onStarted(
    InventoryCollectStarted event,
    Emitter<InventoryCollectState> emit,
  ) async {
    _query = InventoryTaskDetailQuery(
      taskComment: event.task.taskComment,
      taskNo: event.task.taskNo,
    );
    emit(
      state.copyWith(
        status: InventoryCollectStatus.loading,
        task: event.task,
        step: InventoryCollectStep.site,
        placeholder: _placeholderForStep(InventoryCollectStep.site),
        currentStoreSite: '',
        collectQty: 0,
        currentTab: 0,
        clearMaterial: true,
        errorMessage: null,
        successMessage: null,
      ),
    );
    await _loadData(emit);
  }

  Future<void> _onRefreshRequested(
    InventoryCollectRefreshRequested event,
    Emitter<InventoryCollectState> emit,
  ) async {
    emit(
      state.copyWith(
        status: InventoryCollectStatus.loading,
        errorMessage: null,
        successMessage: null,
      ),
    );
    await _loadData(emit);
  }

  Future<void> _onTabChanged(
    InventoryCollectTabChanged event,
    Emitter<InventoryCollectState> emit,
  ) async {
    emit(state.copyWith(currentTab: event.index));
  }

  Future<void> _onScanReceived(
    InventoryCollectScanReceived event,
    Emitter<InventoryCollectState> emit,
  ) async {
    final code = event.code.trim();
    if (code.isEmpty) {
      return;
    }

    switch (state.step) {
      case InventoryCollectStep.site:
        await _handleSiteScan(code, emit);
        break;
      case InventoryCollectStep.material:
        await _handleMaterialScan(code, emit);
        break;
      case InventoryCollectStep.quantity:
        final quantity = double.tryParse(code);
        if (quantity == null) {
          emit(state.copyWith(errorMessage: '请输入正确的数量'));
          return;
        }
        await _finalizeCollection(quantity, emit);
        break;
    }
  }

  void _onQuantityChanged(
    InventoryCollectManualQuantityChanged event,
    Emitter<InventoryCollectState> emit,
  ) {
    final value = double.tryParse(event.value);
    emit(state.copyWith(collectQty: value ?? 0));
  }

  Future<void> _onQuantitySubmitted(
    InventoryCollectQuantitySubmitted event,
    Emitter<InventoryCollectState> emit,
  ) async {
    await _finalizeCollection(event.quantity, emit);
  }

  Future<void> _onRecordRemoved(
    InventoryCollectRecordRemoved event,
    Emitter<InventoryCollectState> emit,
  ) async {
    final updatedRecords = List<InventoryCollectionRecord>.from(
      state.collectRecords,
    );
    final index = updatedRecords.indexWhere(
      (record) => record.isSameTarget(event.record),
    );
    if (index < 0) {
      return;
    }

    final removed = updatedRecords.removeAt(index);
    final updatedDetails = state.taskItems.map((detail) {
      if (detail.detailId == removed.invTaskItemId) {
        final newQty = detail.collectedQty - removed.collectQty;
        final double adjusted = newQty < 0 ? 0 : newQty;
        return detail.copyWith(collectedQty: adjusted);
      }
      return detail;
    }).toList();

    emit(
      state.copyWith(
        collectRecords: updatedRecords,
        taskItems: updatedDetails,
        successMessage: null,
        errorMessage: null,
        currentTab: updatedRecords.isEmpty ? 0 : state.currentTab,
      ),
    );
  }

  Future<void> _onSubmitRequested(
    InventoryCollectSubmitRequested event,
    Emitter<InventoryCollectState> emit,
  ) async {
    if (state.collectRecords.isEmpty) {
      emit(state.copyWith(errorMessage: '本次无采集明细，请确认！'));
      return;
    }

    final taskComment = state.task?.taskComment ?? '';
    emit(
      state.copyWith(
        status: InventoryCollectStatus.submitting,
        errorMessage: null,
        successMessage: null,
      ),
    );

    try {
      await _service.submitInventoryInfos(
        inventoryInfos: state.collectRecords,
        taskComment: taskComment,
      );
      emit(
        state.copyWith(
          status: InventoryCollectStatus.submitSuccess,
          collectRecords: const [],
          currentTab: 0,
          step: InventoryCollectStep.site,
          placeholder: _placeholderForStep(InventoryCollectStep.site),
          currentStoreSite: '',
          collectQty: 0,
          clearMaterial: true,
          successMessage: '提交成功',
        ),
      );
      await _loadData(emit);
    } catch (e) {
      emit(
        state.copyWith(
          status: InventoryCollectStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onResetRequested(
    InventoryCollectResetRequested event,
    Emitter<InventoryCollectState> emit,
  ) {
    emit(
      state.copyWith(
        step: InventoryCollectStep.site,
        currentStoreSite: '',
        collectQty: 0,
        placeholder: _placeholderForStep(InventoryCollectStep.site),
        clearMaterial: true,
        errorMessage: null,
        successMessage: null,
      ),
    );
  }

  void _onMessageCleared(
    InventoryCollectMessageCleared event,
    Emitter<InventoryCollectState> emit,
  ) {
    emit(state.clearMessages());
  }

  Future<void> _loadData(Emitter<InventoryCollectState> emit) async {
    final query = _query;
    if (query == null) {
      return;
    }
    try {
      final detailResult = await _service.getInventoryTaskItems(query);
      final collectResult = await _service.getInventoryCollectingItems(query);
      emit(
        state.copyWith(
          status: InventoryCollectStatus.success,
          taskItems: detailResult.rows,
          collectRecords: collectResult.rows,
          errorMessage: null,
          placeholder: _placeholderForStep(state.step),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: InventoryCollectStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _handleSiteScan(
    String code,
    Emitter<InventoryCollectState> emit,
  ) async {
    final siteCode = _extractSiteCode(code);
    if (siteCode.isEmpty) {
      emit(state.copyWith(errorMessage: '库位条码识别失败'));
      return;
    }

    final storeRoom = state.task?.storeRoomNo ?? '';
    if (storeRoom.isNotEmpty) {
      try {
        final info = await _service.getStoreSiteByRoom(
          storeRoomNo: storeRoom,
          storeSiteNo: siteCode,
        );
        if (info == null) {
          emit(state.copyWith(errorMessage: '库房【$storeRoom】下无库位号【$siteCode】'));
          return;
        }
        if (!info.isAvailable) {
          emit(state.copyWith(errorMessage: '库位【$siteCode】被锁定或冻结'));
          return;
        }
      } catch (e) {
        emit(state.copyWith(errorMessage: e.toString()));
        return;
      }
    }

    emit(
      state.copyWith(
        currentStoreSite: siteCode,
        step: InventoryCollectStep.material,
        placeholder: _placeholderForStep(InventoryCollectStep.material),
        clearMaterial: true,
        collectQty: 0,
        errorMessage: null,
        successMessage: null,
      ),
    );
  }

  Future<void> _handleMaterialScan(
    String code,
    Emitter<InventoryCollectState> emit,
  ) async {
    if (state.currentStoreSite.isEmpty) {
      emit(state.copyWith(errorMessage: '请先扫描库位'));
      return;
    }

    try {
      final material = await _service.getMaterialInfoByQr(code);
      final detail = _findDetail(
        material,
        state.currentStoreSite,
        state.taskItems,
      );
      if (detail == null) {
        emit(state.copyWith(errorMessage: '物料【${material.matCode}】不在盘点任务清单'));
        return;
      }

      if (material.isSerialControl) {
        await _finalizeCollection(1, emit, material: material, detail: detail);
      } else {
        emit(
          state.copyWith(
            currentMaterial: material,
            step: InventoryCollectStep.quantity,
            placeholder: _placeholderForStep(InventoryCollectStep.quantity),
            collectQty: 0,
            errorMessage: null,
            successMessage: null,
          ),
        );
      }
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> _finalizeCollection(
    double quantity,
    Emitter<InventoryCollectState> emit, {
    InventoryMaterialInfo? material,
    InventoryTaskDetail? detail,
  }) async {
    final currentMaterial = material ?? state.currentMaterial;
    final storeSite = state.currentStoreSite;
    final task = state.task;
    if (currentMaterial == null || storeSite.isEmpty || task == null) {
      emit(state.copyWith(errorMessage: '采集信息不完整，请重新扫描'));
      return;
    }

    if (quantity <= 0) {
      emit(state.copyWith(errorMessage: '采集数量必须大于0'));
      return;
    }

    final matchedDetail =
        detail ?? _findDetail(currentMaterial, storeSite, state.taskItems);
    if (matchedDetail == null) {
      emit(
        state.copyWith(errorMessage: '物料【${currentMaterial.matCode}】不在盘点任务清单'),
      );
      return;
    }

    final batch = currentMaterial.batchNo.isNotEmpty
        ? currentMaterial.batchNo
        : (matchedDetail.batchNo.isNotEmpty ? matchedDetail.batchNo : null);
    final record = InventoryCollectionRecord(
      taskComment: task.taskComment,
      taskNo: task.taskNo,
      invTaskItemId: matchedDetail.detailId,
      storeRoomNo: matchedDetail.storeRoomNo.isNotEmpty
          ? matchedDetail.storeRoomNo
          : task.storeRoomNo,
      storeSiteNo: storeSite,
      matCode: currentMaterial.matCode,
      matName: currentMaterial.matName,
      collectQty: quantity,
      batchNo: batch,
      sn: currentMaterial.isSerialControl ? currentMaterial.sn : null,
      materialId: currentMaterial.materialId,
    );

    final updatedRecords = List<InventoryCollectionRecord>.from(
      state.collectRecords,
    );
    final index = updatedRecords.indexWhere(
      (element) => element.isSameTarget(record),
    );
    if (index >= 0) {
      final existing = updatedRecords[index];
      updatedRecords[index] = existing.copyWith(
        collectQty: existing.collectQty + quantity,
      );
    } else {
      updatedRecords.add(record);
    }

    final updatedDetails = state.taskItems
        .map(
          (item) => item.detailId == matchedDetail.detailId
              ? item.copyWith(collectedQty: item.collectedQty + quantity)
              : item,
        )
        .toList();

    emit(
      state.copyWith(
        taskItems: updatedDetails,
        collectRecords: updatedRecords,
        step: InventoryCollectStep.site,
        currentStoreSite: '',
        collectQty: 0,
        currentTab: updatedRecords.isEmpty ? state.currentTab : 1,
        placeholder: _placeholderForStep(InventoryCollectStep.site),
        successMessage: '采集成功',
        errorMessage: null,
        clearMaterial: true,
      ),
    );
  }

  InventoryTaskDetail? _findDetail(
    InventoryMaterialInfo material,
    String storeSite,
    List<InventoryTaskDetail> details,
  ) {
    InventoryTaskDetail? match;

    if (material.isSerialControl && material.sn.isNotEmpty) {
      match = _firstWhere(
        details,
        (item) =>
            item.storeSite == storeSite &&
            item.materialCode == material.matCode &&
            item.serialNo == material.sn,
      );
      if (match != null) {
        return match;
      }
    }

    if (material.batchNo.isNotEmpty) {
      match = _firstWhere(
        details,
        (item) =>
            item.storeSite == storeSite &&
            item.materialCode == material.matCode &&
            item.batchNo == material.batchNo,
      );
      if (match != null) {
        return match;
      }
    }

    match = _firstWhere(
      details,
      (item) =>
          item.storeSite == storeSite && item.materialCode == material.matCode,
    );
    if (match != null) {
      return match;
    }

    return _firstWhere(
      details,
      (item) => item.materialCode == material.matCode,
    );
  }

  InventoryTaskDetail? _firstWhere(
    List<InventoryTaskDetail> list,
    bool Function(InventoryTaskDetail item) test,
  ) {
    for (final item in list) {
      if (test(item)) {
        return item;
      }
    }
    return null;
  }

  String _placeholderForStep(InventoryCollectStep step) {
    switch (step) {
      case InventoryCollectStep.site:
        return '请扫描库位';
      case InventoryCollectStep.material:
        return '请扫描二维码';
      case InventoryCollectStep.quantity:
        return '请输入数量';
    }
  }

  String _extractSiteCode(String code) {
    final parts = code.split(r'$');
    if (parts.length >= 3) {
      return parts[2].trim();
    }
    return code.trim();
  }
}
