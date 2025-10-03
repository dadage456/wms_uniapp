import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/modules/asrs_inbound/collection/bloc/asrs_inbound_collect_event.dart';
import 'package:wms_app/modules/asrs_inbound/collection/bloc/asrs_inbound_collect_state.dart';
import 'package:wms_app/modules/asrs_inbound/models/asrs_inbound_models.dart';
import 'package:wms_app/modules/asrs_inbound/services/asrs_inbound_service.dart';

class AsrsInboundCollectBloc
    extends Bloc<AsrsInboundCollectEvent, AsrsInboundCollectState> {
  AsrsInboundCollectBloc({required AsrsInboundService service})
      : _service = service,
        super(const AsrsInboundCollectState()) {
    on<AsrsInboundCollectInitialized>(_onInitialized);
    on<AsrsInboundCollectTrayChanged>(_onTrayChanged);
    on<AsrsInboundCollectBarcodeScanned>(_onBarcodeScanned);
    on<AsrsInboundCollectQuantityChanged>(_onQuantityChanged);
    on<AsrsInboundCollectRecordAdded>(_onRecordAdded);
    on<AsrsInboundCollectRecordRemoved>(_onRecordRemoved);
    on<AsrsInboundCollectSubmitted>(_onSubmitted);
  }

  final AsrsInboundService _service;

  Future<void> _onInitialized(
    AsrsInboundCollectInitialized event,
    Emitter<AsrsInboundCollectState> emit,
  ) async {
    emit(
      state.copyWith(
        status: AsrsInboundCollectStatus.loading,
        task: event.task,
        trayNo: '',
        records: const [],
      ),
    );

    try {
      final details = await _service.fetchTaskDetails(taskId: event.task.taskId);
      emit(
        state.copyWith(
          status: AsrsInboundCollectStatus.ready,
          details: details,
          step: AsrsInboundCollectStep.tray,
          errorMessage: null,
          successMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AsrsInboundCollectStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onTrayChanged(
    AsrsInboundCollectTrayChanged event,
    Emitter<AsrsInboundCollectState> emit,
  ) async {
    if (state.task == null) return;
    final trayNo = event.trayNo.trim();
    if (trayNo.isEmpty) {
      emit(state.copyWith(errorMessage: '托盘号不能为空'));
      return;
    }

    emit(state.copyWith(status: AsrsInboundCollectStatus.loading));
    try {
      await _service.checkTray(trayNo);
      await _service.checkTrayBinding(taskId: state.task!.taskId, trayNo: trayNo);
      emit(
        state.copyWith(
          status: AsrsInboundCollectStatus.ready,
          trayNo: trayNo,
          step: AsrsInboundCollectStep.barcode,
          errorMessage: null,
          successMessage: '托盘校验成功',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AsrsInboundCollectStatus.ready,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onBarcodeScanned(
    AsrsInboundCollectBarcodeScanned event,
    Emitter<AsrsInboundCollectState> emit,
  ) async {
    if (state.task == null) return;
    final barcode = event.barcode.trim();
    if (barcode.isEmpty) {
      emit(state.copyWith(errorMessage: '条码不能为空'));
      return;
    }

    emit(state.copyWith(status: AsrsInboundCollectStatus.loading));
    try {
      final detail = await _service.getMaterialInfoByBarcode(
        barcode: barcode,
        taskId: state.task!.taskId,
      );
      emit(
        state.copyWith(
          status: AsrsInboundCollectStatus.ready,
          currentDetail: detail,
          step: AsrsInboundCollectStep.quantity,
          quantity: detail.taskQty > 0
              ? (detail.taskQty - detail.collectedQty)
                  .clamp(0, detail.taskQty)
                  .toDouble()
              : 0.0,
          errorMessage: null,
          successMessage: '物料识别成功',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AsrsInboundCollectStatus.ready,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  FutureOr<void> _onQuantityChanged(
    AsrsInboundCollectQuantityChanged event,
    Emitter<AsrsInboundCollectState> emit,
  ) {
    emit(state.copyWith(quantity: event.quantity));
  }

  Future<void> _onRecordAdded(
    AsrsInboundCollectRecordAdded event,
    Emitter<AsrsInboundCollectState> emit,
  ) async {
    if (state.task == null) return;
    if (state.trayNo.isEmpty) {
      emit(state.copyWith(errorMessage: '请先校验托盘'));
      return;
    }
    final detail = state.currentDetail;
    if (detail == null) {
      emit(state.copyWith(errorMessage: '请先扫码物料'));
      return;
    }
    if (state.quantity <= 0) {
      emit(state.copyWith(errorMessage: '请输入大于0的数量'));
      return;
    }

    final record = AsrsInboundCollectionRecord(
      materialCode: detail.materialCode,
      materialName: detail.materialName,
      batchNo: detail.batchNo,
      serialNo: detail.serialNo,
      quantity: state.quantity,
      unit: detail.unit,
      storeSiteNo: detail.storeSiteNo,
      taskItemId: detail.taskItemId,
    );

    emit(
      state.copyWith(
        records: [...state.records, record],
        currentDetail: null,
        quantity: 0,
        step: AsrsInboundCollectStep.barcode,
        successMessage: '已添加到待提交列表',
      ),
    );
  }

  FutureOr<void> _onRecordRemoved(
    AsrsInboundCollectRecordRemoved event,
    Emitter<AsrsInboundCollectState> emit,
  ) {
    emit(
      state.copyWith(
        records: state.records
            .where((element) => element.id != event.recordId)
            .toList(),
      ),
    );
  }

  Future<void> _onSubmitted(
    AsrsInboundCollectSubmitted event,
    Emitter<AsrsInboundCollectState> emit,
  ) async {
    final task = state.task;
    if (task == null || state.records.isEmpty) {
      emit(state.copyWith(errorMessage: '请先添加待提交的记录'));
      return;
    }

    emit(state.copyWith(status: AsrsInboundCollectStatus.submitting));

    try {
      final upShelvesInfos = state.records
          .map(
            (record) => {
              'intaskid': task.taskId,
              'palletno': state.trayNo,
              'storesiteno': record.storeSiteNo,
              'quantity': record.quantity,
              'unit': record.unit,
            },
          )
          .toList();

      final itemListInfos = state.records
          .map(
            (record) => {
              'intaskitemid': record.taskItemId,
              'quantity': record.quantity,
            },
          )
          .toList();

      await _service.commitUpShelves(
        taskNo: task.taskNo,
        trayNo: state.trayNo,
        upShelvesInfos: upShelvesInfos,
        itemListInfos: itemListInfos,
        filter: '',
      );

      final refreshedDetails = await _service.fetchTaskDetails(taskId: task.taskId);

      emit(
        state.copyWith(
          status: AsrsInboundCollectStatus.success,
          details: refreshedDetails,
          records: const [],
          currentDetail: null,
          quantity: 0,
          step: AsrsInboundCollectStep.barcode,
          successMessage: '提交成功',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AsrsInboundCollectStatus.ready,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
