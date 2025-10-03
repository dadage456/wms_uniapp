import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/modules/asrs_outbound/collection/bloc/asrs_outbound_collect_event.dart';
import 'package:wms_app/modules/asrs_outbound/collection/bloc/asrs_outbound_collect_state.dart';
import 'package:wms_app/modules/asrs_outbound/models/asrs_outbound_models.dart';
import 'package:wms_app/modules/asrs_outbound/services/asrs_outbound_service.dart';

class AsrsOutboundCollectBloc
    extends Bloc<AsrsOutboundCollectEvent, AsrsOutboundCollectState> {
  AsrsOutboundCollectBloc({required AsrsOutboundService service})
    : _service = service,
      super(const AsrsOutboundCollectState()) {
    on<AsrsOutboundCollectStarted>(_onStarted);
    on<AsrsOutboundCollectDetailSelected>(_onDetailSelected);
    on<AsrsOutboundCollectScanReceived>(_onScanReceived);
    on<AsrsOutboundCollectQuantitySubmitted>(_onQuantitySubmitted);
    on<AsrsOutboundCollectRecordRemoved>(_onRecordRemoved);
    on<AsrsOutboundCollectSubmitRequested>(_onSubmitRequested);
    on<AsrsOutboundCollectResetRequested>(_onResetRequested);
    on<AsrsOutboundCollectMessageCleared>(_onMessageCleared);
  }

  final AsrsOutboundService _service;

  Future<void> _onStarted(
    AsrsOutboundCollectStarted event,
    Emitter<AsrsOutboundCollectState> emit,
  ) async {
    emit(
      const AsrsOutboundCollectState(status: AsrsOutboundCollectStatus.loading),
    );
    try {
      final details = await _service.fetchTaskDetails(
        taskId: event.task.taskId,
      );
      emit(
        state.copyWith(
          status: AsrsOutboundCollectStatus.ready,
          task: event.task,
          details: details,
          step: AsrsCollectStep.scanSite,
          storeSite: '',
          trayNo: '',
          inventoryQty: 0,
          inputQuantity: 0,
          records: const [],
          removeMaterialInfo: true,
          removeSelectedDetail: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AsrsOutboundCollectStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onDetailSelected(
    AsrsOutboundCollectDetailSelected event,
    Emitter<AsrsOutboundCollectState> emit,
  ) {
    emit(
      state.copyWith(
        selectedDetail: event.detail,
        step: state.step == AsrsCollectStep.scanSite
            ? AsrsCollectStep.scanSite
            : state.step,
        errorMessage: null,
        successMessage: null,
      ),
    );
  }

  Future<void> _onScanReceived(
    AsrsOutboundCollectScanReceived event,
    Emitter<AsrsOutboundCollectState> emit,
  ) async {
    final code = event.code.trim();
    if (code.isEmpty) {
      emit(state.copyWith(errorMessage: '采集内容为空,请重新扫描'));
      return;
    }

    final numeric = double.tryParse(code);
    if (numeric != null && state.step == AsrsCollectStep.inputQuantity) {
      add(AsrsOutboundCollectQuantitySubmitted(numeric));
      return;
    }

    try {
      if (code.contains(r'$KW$')) {
        final site = _parseStoreSite(code);
        if (site.isEmpty) {
          throw Exception('库位条码不合法');
        }
        emit(
          state.clearMessages().copyWith(
            storeSite: site,
            step: AsrsCollectStep.scanTray,
            clearScanField: true,
            focusQuantity: false,
          ),
        );
        return;
      }

      if (_looksLikeTray(code)) {
        if (state.storeSite.isEmpty) {
          throw Exception('请先扫描库位');
        }
        emit(
          state.clearMessages().copyWith(
            trayNo: code,
            step: AsrsCollectStep.scanMaterial,
            clearScanField: true,
            focusQuantity: false,
          ),
        );
        return;
      }

      if (code.contains('MC')) {
        if (state.storeSite.isEmpty) {
          throw Exception('请先扫描库位');
        }
        emit(
          state.copyWith(
            isLoadingMaterial: true,
            errorMessage: null,
            successMessage: null,
          ),
        );
        final material = await _service.getMaterialInfo(code);
        final inventoryList = await _service.getInventoryByStoreSite(
          storeSiteNo: state.storeSite,
          materialCode: material.materialCode,
          batchNo: material.batchNo.isEmpty ? null : material.batchNo,
          serialNo: material.serialNo.isEmpty ? null : material.serialNo,
          storeRoomNo: material.erpStoreRoom.isEmpty
              ? null
              : material.erpStoreRoom,
        );
        final double inventory = inventoryList.isNotEmpty
            ? inventoryList.first.availableQty
            : 0;
        final matchedDetail = _matchDetail(material) ?? state.selectedDetail;
        emit(
          state.copyWith(
            isLoadingMaterial: false,
            materialInfo: material,
            inventoryQty: inventory,
            step: AsrsCollectStep.inputQuantity,
            focusQuantity: true,
            clearScanField: true,
            selectedDetail: matchedDetail,
          ),
        );
        return;
      }

      throw Exception('未识别的采集内容');
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: e.toString(),
          focusQuantity: false,
          clearScanField: true,
        ),
      );
    }
  }

  void _onQuantitySubmitted(
    AsrsOutboundCollectQuantitySubmitted event,
    Emitter<AsrsOutboundCollectState> emit,
  ) {
    if (event.quantity <= 0) {
      emit(state.copyWith(errorMessage: '采集数量必须大于0'));
      return;
    }
    if (state.storeSite.isEmpty || state.trayNo.isEmpty) {
      emit(state.copyWith(errorMessage: '请先扫描库位与托盘'));
      return;
    }
    if (state.materialInfo == null) {
      emit(state.copyWith(errorMessage: '请先扫描物料条码'));
      return;
    }
    if (state.selectedDetail == null) {
      emit(state.copyWith(errorMessage: '请选择任务明细'));
      return;
    }

    final record = AsrsOutboundCollectRecord(
      taskItemId: state.selectedDetail!.taskItemId,
      taskNo: state.selectedDetail!.taskNo,
      taskId: state.selectedDetail!.taskId,
      storeSite: state.storeSite,
      trayNo: state.trayNo,
      materialCode: state.materialInfo!.materialCode,
      materialName: state.materialInfo!.materialName,
      batchNo: state.materialInfo!.batchNo,
      serialNo: state.materialInfo!.serialNo,
      quantity: event.quantity,
      erpStoreRoom: state.materialInfo!.erpStoreRoom,
      erpOwnerCode: state.materialInfo!.erpOwnerCode,
      projectNum: state.materialInfo!.projectNum,
    );

    emit(
      state.copyWith(
        records: [...state.records, record],
        inventoryQty: state.inventoryQty - event.quantity,
        inputQuantity: 0,
        removeMaterialInfo: true,
        focusQuantity: false,
        clearScanField: true,
        step: AsrsCollectStep.scanTray,
        successMessage: '已采集 ${state.materialInfo!.materialCode}',
      ),
    );
  }

  void _onRecordRemoved(
    AsrsOutboundCollectRecordRemoved event,
    Emitter<AsrsOutboundCollectState> emit,
  ) {
    emit(
      state.copyWith(
        records: state.records.where((r) => r.id != event.recordId).toList(),
        successMessage: '已删除采集记录',
      ),
    );
  }

  Future<void> _onSubmitRequested(
    AsrsOutboundCollectSubmitRequested event,
    Emitter<AsrsOutboundCollectState> emit,
  ) async {
    if (state.records.isEmpty) {
      emit(state.copyWith(errorMessage: '暂无采集数据，请先采集'));
      return;
    }
    if (state.task == null) {
      return;
    }

    emit(
      state.copyWith(
        status: AsrsOutboundCollectStatus.submitting,
        errorMessage: null,
        successMessage: null,
      ),
    );

    try {
      final downShelves = state.records
          .map((e) => e.toDownShelvesJson())
          .toList();
      final itemInfos = state.records.map((record) {
        AsrsOutboundTaskDetail? detail;
        try {
          detail = state.details.firstWhere(
            (d) => d.taskItemId == record.taskItemId,
          );
        } catch (_) {
          detail =
              state.selectedDetail ??
              (state.details.isNotEmpty ? state.details.first : null);
        }
        if (detail == null) {
          return {
            'outtaskitemid': record.taskItemId,
            'taskId': record.taskId,
            'taskNo': record.taskNo,
          };
        }
        return detail.toReceivePayload();
      }).toList();
      await _service.commitDownShelves(
        downShelvesInfos: downShelves,
        itemListInfos: itemInfos,
      );
      final refreshed = await _service.fetchTaskDetails(
        taskId: state.task!.taskId,
      );
      emit(
        state.copyWith(
          status: AsrsOutboundCollectStatus.success,
          details: refreshed,
          records: const [],
          storeSite: '',
          trayNo: '',
          inventoryQty: 0,
          removeMaterialInfo: true,
          removeSelectedDetail: true,
          step: AsrsCollectStep.scanSite,
          successMessage: '采集提交成功',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AsrsOutboundCollectStatus.ready,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onResetRequested(
    AsrsOutboundCollectResetRequested event,
    Emitter<AsrsOutboundCollectState> emit,
  ) {
    emit(
      state.copyWith(
        storeSite: '',
        trayNo: '',
        removeMaterialInfo: true,
        inputQuantity: 0,
        inventoryQty: 0,
        step: AsrsCollectStep.scanSite,
        errorMessage: null,
        successMessage: '已重置采集流程',
      ),
    );
  }

  void _onMessageCleared(
    AsrsOutboundCollectMessageCleared event,
    Emitter<AsrsOutboundCollectState> emit,
  ) {
    emit(state.clearMessages().copyWith(clearScanField: false));
  }

  String _parseStoreSite(String code) {
    final parts = code.split(r'$');
    if (parts.length >= 3) {
      return parts[2];
    }
    return '';
  }

  bool _looksLikeTray(String code) {
    final upper = code.toUpperCase();
    return upper.startsWith('TP') ||
        upper.startsWith('TR') ||
        upper.contains('TRAY');
  }

  AsrsOutboundTaskDetail? _matchDetail(AsrsMaterialInfo material) {
    try {
      return state.details.firstWhere(
        (detail) =>
            detail.materialCode == material.materialCode &&
            (state.storeSite.isEmpty || detail.storeSiteNo == state.storeSite),
      );
    } catch (_) {
      return null;
    }
  }
}
