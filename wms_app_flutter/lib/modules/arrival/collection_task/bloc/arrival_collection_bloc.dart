import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:wms_app/modules/arrival/collection_task/bloc/arrival_collection_event.dart';
import 'package:wms_app/modules/arrival/collection_task/bloc/arrival_collection_state.dart';
import 'package:wms_app/modules/arrival/collection_task/models/arrival_collection_models.dart';
import 'package:wms_app/modules/arrival/services/arrival_service.dart';
import 'package:wms_app/modules/arrival/task_details/models/arrival_task_detail.dart';
import 'package:wms_app/modules/arrival/task_list/models/arrival_task.dart';
import 'package:wms_app/modules/floor_inbound/collection_task/models/inbound_collection_models.dart';

class ArrivalCollectionBloc
    extends Bloc<ArrivalCollectionEvent, ArrivalCollectionState> {
  ArrivalCollectionBloc({required ArrivalService service})
    : _service = service,
      super(const ArrivalCollectionState()) {
    on<InitializeArrivalCollection>(_onInitialize);
    on<ArrivalCollectionScanReceived>(_onScanReceived);
    on<ArrivalCollectionDetailSelected>(_onDetailSelected);
    on<ArrivalCollectionQuantitySubmitted>(_onQuantitySubmitted);
    on<ArrivalCollectionPromptDismissed>(_onPromptDismissed);
    on<ArrivalCollectionRecordRemoved>(_onRecordRemoved);
    on<ArrivalCollectionSubmitRequested>(_onSubmitRequested);
    on<ArrivalCollectionMessagesCleared>(_onMessagesCleared);
    on<ArrivalCollectionTabChanged>(_onTabChanged);
  }

  final ArrivalService _service;
  final Uuid _uuid = const Uuid();
  ArrivalTaskDetailQuery? _currentQuery;

  Future<void> _onInitialize(
    InitializeArrivalCollection event,
    Emitter<ArrivalCollectionState> emit,
  ) async {
    emit(
      state.copyWith(
        task: event.task,
        isLoading: true,
        records: const [],
        errorMessage: null,
        successMessage: null,
        clearError: true,
        clearSuccess: true,
      ),
    );

    try {
      _currentQuery = ArrivalTaskDetailQuery(
        arrivalsBillId: event.task.arrivalsBillId,
      );
      final result = await _service.getArrivalDetails(_currentQuery!);
      final initialCollected = <String, double>{
        for (final item in result.rows) item.detailId: item.collectedQty,
      };
      emit(
        state.copyWith(
          isLoading: false,
          details: result.rows,
          initialCollected: initialCollected,
          currentTab: 0,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
          clearSuccess: true,
        ),
      );
    }
  }

  Future<void> _onScanReceived(
    ArrivalCollectionScanReceived event,
    Emitter<ArrivalCollectionState> emit,
  ) async {
    final task = state.task;
    if (task == null) {
      return;
    }
    final code = event.code.trim();
    if (code.isEmpty) {
      return;
    }

    emit(state.copyWith(clearError: true, clearSuccess: true));

    try {
      final material = await _service.getMaterialInfo(code);
      final detail = _findDetailForMaterial(material, state.details);
      if (detail == null) {
        emit(
          state.copyWith(errorMessage: '物料【${material.matCode}】不在当前任务中或已采集完成'),
        );
        return;
      }

      final remaining = _remainingQty(detail);
      if (remaining <= 0) {
        emit(state.copyWith(errorMessage: '物料【${detail.materialCode}】已完成采集'));
        return;
      }

      double? suggested;
      if (material.qty != null && material.qty! > 0) {
        suggested = material.qty! <= remaining ? material.qty! : remaining;
      } else if ((material.sn ?? '').isNotEmpty) {
        suggested = 1;
      }

      emit(
        state.copyWith(
          prompt: ArrivalCollectionPrompt(
            detail: detail,
            material: material,
            remainingQty: remaining,
            suggestedQty: suggested,
          ),
        ),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  void _onDetailSelected(
    ArrivalCollectionDetailSelected event,
    Emitter<ArrivalCollectionState> emit,
  ) {
    final remaining = _remainingQty(event.detail);
    if (remaining <= 0) {
      emit(
        state.copyWith(errorMessage: '物料【${event.detail.materialCode}】已完成采集'),
      );
      return;
    }

    emit(
      state.copyWith(
        prompt: ArrivalCollectionPrompt(
          detail: event.detail,
          material: null,
          remainingQty: remaining,
          suggestedQty: remaining,
        ),
        clearError: true,
        clearSuccess: true,
      ),
    );
  }

  void _onPromptDismissed(
    ArrivalCollectionPromptDismissed event,
    Emitter<ArrivalCollectionState> emit,
  ) {
    emit(state.copyWith(clearPrompt: true));
  }

  void _onMessagesCleared(
    ArrivalCollectionMessagesCleared event,
    Emitter<ArrivalCollectionState> emit,
  ) {
    emit(state.copyWith(clearError: true, clearSuccess: true));
  }

  void _onTabChanged(
    ArrivalCollectionTabChanged event,
    Emitter<ArrivalCollectionState> emit,
  ) {
    emit(state.copyWith(currentTab: event.index));
  }

  Future<void> _onQuantitySubmitted(
    ArrivalCollectionQuantitySubmitted event,
    Emitter<ArrivalCollectionState> emit,
  ) async {
    final prompt = state.prompt;
    final task = state.task;
    if (prompt == null || task == null) {
      return;
    }

    final quantity = event.quantity;
    if (quantity <= 0) {
      emit(state.copyWith(errorMessage: '采集数量必须大于0', clearSuccess: true));
      return;
    }

    if (quantity > prompt.remainingQty + 1e-6) {
      emit(
        state.copyWith(
          errorMessage:
              '采集数量不能超过剩余任务数量${prompt.remainingQty.toStringAsFixed(2)}',
          clearSuccess: true,
        ),
      );
      return;
    }

    final material = prompt.material;
    final detail = prompt.detail;
    final batch = (material?.batchNo?.isNotEmpty ?? false)
        ? material!.batchNo
        : (detail.batchNo.isNotEmpty ? detail.batchNo : null);
    final serial = (material?.sn?.isNotEmpty ?? false) ? material!.sn : null;

    final matchesBatch =
        detail.batchNo.isEmpty || batch == null || detail.batchNo == batch;
    final matchesSerial =
        detail.serialNo.isEmpty || serial == null || detail.serialNo == serial;
    final collectFlag = (matchesBatch && matchesSerial) ? '0' : '1';

    final record = ArrivalCollectionRecord(
      id: _uuid.v4(),
      detailId: detail.detailId,
      arrivalsBillId: task.arrivalsBillId,
      materialCode: detail.materialCode,
      materialName: detail.materialName,
      batchNo: batch,
      serialNo: serial,
      quantity: quantity,
      taskQty: detail.planQty,
      storeRoom: detail.storeRoom,
      subInventory: detail.subInventory,
      supplierName: detail.supplierName.isNotEmpty
          ? detail.supplierName
          : material?.supplierName,
      collectFlag: collectFlag,
      productionDate: material?.productionDate,
      validDays: material?.validDays,
    );

    final updatedRecords = List<ArrivalCollectionRecord>.from(state.records);
    final index = updatedRecords.indexWhere(
      (element) => element.isSameTarget(record),
    );
    if (index >= 0) {
      final existing = updatedRecords[index];
      updatedRecords[index] = existing.copyWith(
        quantity: existing.quantity + record.quantity,
      );
    } else {
      updatedRecords.add(record);
    }

    final updatedDetails = state.details.map((item) {
      if (item.detailId == detail.detailId) {
        final newQty = item.collectedQty + quantity;
        return item.copyWith(collectedQty: newQty);
      }
      return item;
    }).toList();

    emit(
      state.copyWith(
        records: updatedRecords,
        details: updatedDetails,
        successMessage: '采集成功',
        currentTab: 1,
        clearError: true,
        clearPrompt: true,
      ),
    );
  }

  void _onRecordRemoved(
    ArrivalCollectionRecordRemoved event,
    Emitter<ArrivalCollectionState> emit,
  ) {
    final targetIndex = state.records.indexWhere(
      (element) => element.id == event.recordId,
    );
    if (targetIndex < 0) {
      return;
    }

    final target = state.records[targetIndex];
    final updatedRecords = List<ArrivalCollectionRecord>.from(state.records)
      ..removeAt(targetIndex);

    final updatedDetails = state.details.map((item) {
      if (item.detailId == target.detailId) {
        final double newQty = (item.collectedQty - target.quantity).clamp(
          0,
          item.planQty,
        );
        return item.copyWith(collectedQty: newQty);
      }
      return item;
    }).toList();

    emit(
      state.copyWith(
        records: updatedRecords,
        details: updatedDetails,
        successMessage: '已移除采集记录',
        clearError: true,
      ),
    );
  }

  Future<void> _onSubmitRequested(
    ArrivalCollectionSubmitRequested event,
    Emitter<ArrivalCollectionState> emit,
  ) async {
    final task = state.task;
    if (task == null) {
      return;
    }
    if (state.records.isEmpty) {
      emit(
        state.copyWith(errorMessage: '本次无采集记录，请先采集后再提交', clearSuccess: true),
      );
      return;
    }

    emit(
      state.copyWith(isSubmitting: true, clearError: true, clearSuccess: true),
    );

    try {
      await _service.submitArrivalCollection(
        task: task,
        records: state.records,
        details: state.details,
        initialCollected: state.initialCollected,
      );

      if (_currentQuery != null) {
        final refreshed = await _service.getArrivalDetails(_currentQuery!);
        final initialCollected = <String, double>{
          for (final item in refreshed.rows) item.detailId: item.collectedQty,
        };
        emit(
          state.copyWith(
            details: refreshed.rows,
            records: const [],
            initialCollected: initialCollected,
            successMessage: '提交成功',
            isSubmitting: false,
            currentTab: 0,
            clearPrompt: true,
          ),
        );
      } else {
        emit(
          state.copyWith(
            records: const [],
            successMessage: '提交成功',
            isSubmitting: false,
            currentTab: 0,
            clearPrompt: true,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: e.toString(),
          clearPrompt: true,
        ),
      );
    }
  }

  ArrivalTaskDetail? _findDetailForMaterial(
    InboundBarcodeContent material,
    List<ArrivalTaskDetail> details,
  ) {
    final candidates = details.where((item) {
      if (item.materialCode != material.matCode) {
        return false;
      }
      final remaining = _remainingQty(item);
      if (remaining <= 0) {
        return false;
      }
      if ((material.batchNo?.isNotEmpty ?? false) && item.batchNo.isNotEmpty) {
        if (item.batchNo != material.batchNo) {
          return false;
        }
      }
      if ((material.sn?.isNotEmpty ?? false) && item.serialNo.isNotEmpty) {
        if (item.serialNo != material.sn) {
          return false;
        }
      }
      return true;
    }).toList();

    if (candidates.isEmpty) {
      final fallback = details
          .where(
            (item) =>
                item.materialCode == material.matCode &&
                _remainingQty(item) > 0,
          )
          .toList();
      if (fallback.isEmpty) {
        return null;
      }
      fallback.sort((a, b) => _remainingQty(b).compareTo(_remainingQty(a)));
      return fallback.first;
    }

    candidates.sort((a, b) => _remainingQty(b).compareTo(_remainingQty(a)));
    return candidates.first;
  }

  double _remainingQty(ArrivalTaskDetail detail) {
    final remaining = detail.planQty - detail.collectedQty;
    return remaining < 0 ? 0 : remaining;
  }
}
