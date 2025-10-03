import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:wms_app/modules/floor_exception/exception_collection/bloc/floor_exception_collect_event.dart';
import 'package:wms_app/modules/floor_exception/exception_collection/bloc/floor_exception_collect_state.dart';
import 'package:wms_app/modules/floor_exception/exception_collection/models/floor_exception_collect_models.dart';
import 'package:wms_app/modules/floor_exception/exception_task_list/models/exception_task.dart';
import 'package:wms_app/modules/floor_exception/services/floor_exception_service.dart';
import 'package:wms_app/modules/outbound/collection_task/models/collection_models.dart';

class FloorExceptionCollectBloc
    extends Bloc<FloorExceptionCollectEvent, FloorExceptionCollectState> {
  FloorExceptionCollectBloc({required FloorExceptionService service})
    : _service = service,
      super(const FloorExceptionCollectState()) {
    on<FloorExceptionInitializeEvent>(_onInitialize);
    on<FloorExceptionTypeChangedEvent>(_onTypeChanged);
    on<FloorExceptionPerformScanEvent>(_onPerformScan);
    on<FloorExceptionSelectionChangedEvent>(_onSelectionChanged);
    on<FloorExceptionDeleteSelectedEvent>(_onDeleteSelected);
    on<FloorExceptionCommitRequestedEvent>(_onCommitRequested);
    on<FloorExceptionClearErrorEvent>(_onClearError);
    on<FloorExceptionClearMessageEvent>(_onClearMessage);
  }

  final FloorExceptionService _service;
  FloorExceptionTaskSummary _summary = const FloorExceptionTaskSummary();

  void _onInitialize(
    FloorExceptionInitializeEvent event,
    Emitter<FloorExceptionCollectState> emit,
  ) {
    _summary = event.taskSummary ?? const FloorExceptionTaskSummary();
    final tray = event.trayNo.isNotEmpty
        ? event.trayNo
        : (_summary.trayNo.isNotEmpty ? _summary.trayNo : '');
    var nextState = state.copyWith(
      trayNo: tray,
      storeSite: event.initialStoreSite,
      barcodeContent: BarcodeContent.fromJson({}),
      collectQty: 0,
      matCode: '',
      batchNo: '',
      sn: '',
      matControlFlag: '',
    );
    nextState = _applyPlaceholder(nextState);
    emit(nextState);
  }

  void _onTypeChanged(
    FloorExceptionTypeChangedEvent event,
    Emitter<FloorExceptionCollectState> emit,
  ) {
    emit(state.copyWith(exceptionType: event.type, exceptionName: event.name));
  }

  Future<void> _onPerformScan(
    FloorExceptionPerformScanEvent event,
    Emitter<FloorExceptionCollectState> emit,
  ) async {
    final barcode = event.barcode.trim();

    if (state.exceptionType.isEmpty) {
      emit(state.copyWith(error: '请指定异常类型!'));
      return;
    }

    if (barcode.isEmpty) {
      emit(state.copyWith(error: '采集内容为空,请重新采集!'));
      return;
    }

    try {
      var workingState = state.copyWith(error: null);

      if (barcode.contains('MC')) {
        emit(workingState.copyWith(isLoading: true));
        final barcodeContent = await _service.getMaterialInfoByQR(barcode);
        workingState = _handleQRCode(
          workingState.copyWith(isLoading: false),
          barcodeContent,
        );
      } else if (barcode.contains(r'$KW$')) {
        workingState = _handleSite(workingState, barcode);
      } else if (barcode.contains(r'$TP$')) {
        emit(workingState.copyWith(isLoading: true));
        workingState = await _handleTray(
          workingState.copyWith(isLoading: false),
          barcode,
        );
      } else if (_isNumeric(barcode)) {
        workingState = _handleQuantity(workingState, barcode);
      } else {
        throw Exception('采集内容不合法!');
      }

      workingState = _applyPlaceholder(workingState);
      if (workingState.placeholder.isEmpty) {
        workingState = _finalizeCollection(workingState);
      }

      emit(workingState);
    } catch (e) {
      var resetState = state.copyWith(
        isLoading: false,
        error: _formatError(e),
        barcodeContent: BarcodeContent.fromJson({}),
        collectQty: 0,
        matCode: '',
        batchNo: '',
        sn: '',
        matControlFlag: '',
      );
      resetState = _applyPlaceholder(resetState);
      emit(resetState);
    }
  }

  FloorExceptionCollectState _handleQRCode(
    FloorExceptionCollectState current,
    BarcodeContent barcodeContent,
  ) {
    final matControl = barcodeContent.seqctrl?.toString() ?? '';
    final newMartTask = barcodeContent.id_old?.toString() ?? '';

    String newBatchNo = current.batchNo;
    String newSn = current.sn;
    double newCollectQty = current.collectQty;

    if (matControl == '0') {
      final snValue = barcodeContent.sn?.trim() ?? '';
      if (snValue.isEmpty) {
        throw Exception('物料【${barcodeContent.matcode ?? ''}】的序列号为空，不允许采集，请确认');
      }
      newSn = snValue;
      newBatchNo = newMartTask == '1' ? (barcodeContent.batchno ?? '') : '';
      newCollectQty = 1;
    } else if (matControl == '1' || matControl == '2') {
      final batchValue = newMartTask == '1'
          ? (barcodeContent.batchno ?? '')
          : (barcodeContent.sn ?? '');
      if (batchValue.isEmpty) {
        throw Exception('物料【${barcodeContent.matcode ?? ''}】批次号不能为空');
      }
      newBatchNo = batchValue;
      newSn = newMartTask == '1' ? (barcodeContent.sn ?? '') : '';
      newCollectQty = 0;
    } else {
      throw Exception('物料${barcodeContent.matcode ?? ''}编码控制维护值维护不合法');
    }

    return current.copyWith(
      barcodeContent: barcodeContent,
      matCode: barcodeContent.matcode ?? '',
      matControlFlag: matControl,
      batchNo: newBatchNo,
      sn: newSn,
      collectQty: newCollectQty,
    );
  }

  FloorExceptionCollectState _handleSite(
    FloorExceptionCollectState current,
    String barcode,
  ) {
    final parts = barcode.split(r'$');
    if (parts.length < 3 || parts[2].isEmpty) {
      throw Exception('库位编码不合法');
    }
    return current.copyWith(storeSite: parts[2]);
  }

  Future<FloorExceptionCollectState> _handleTray(
    FloorExceptionCollectState current,
    String barcode,
  ) async {
    final parts = barcode.split(r'$');
    if (parts.length < 3 || parts[2].isEmpty) {
      throw Exception('托盘号不能为空!');
    }
    final trayNo = parts[2];
    final storeSite = await _service.getPalletStoreSite(trayNo);
    if (storeSite == null || storeSite.isEmpty) {
      throw Exception('托盘未绑定库位');
    }
    return current.copyWith(trayNo: trayNo, storeSite: storeSite);
  }

  FloorExceptionCollectState _handleQuantity(
    FloorExceptionCollectState current,
    String barcode,
  ) {
    if (current.matCode.isEmpty) {
      throw Exception('请先扫描二维码');
    }
    if (current.matControlFlag == '0') {
      throw Exception('已采集序列号无需采集数量，请扫描二维码');
    }
    final qty = double.tryParse(barcode);
    if (qty == null || qty <= 0) {
      throw Exception('采集数量必须大于0');
    }
    return current.copyWith(collectQty: qty);
  }

  FloorExceptionCollectState _finalizeCollection(
    FloorExceptionCollectState current,
  ) {
    if (current.matCode.isEmpty) {
      throw Exception('请先扫描二维码');
    }
    if (current.collectQty <= 0) {
      throw Exception('采集数量必须大于0');
    }

    final id = const Uuid().v4();
    final item = FloorExceptionCollectionItem(
      id: id,
      matCode: current.matCode,
      storeSite: current.storeSite,
      exceptionName: current.exceptionName,
      qty: current.collectQty,
      batchNo: current.batchNo,
      sn: current.sn,
      storeRoom: _summary.storeRoom,
      proType: _summary.proType.isNotEmpty ? _summary.proType : '异常处理',
      taskId: _summary.taskId,
    );

    final stock = FloorExceptionStock(
      id: id,
      matCode: current.matCode,
      batchNo: current.batchNo,
      sn: current.sn,
      taskQty: 0,
      collectQty: current.collectQty,
      storeRoom: _summary.storeRoom,
      storeSite: current.storeSite,
      taskId: _summary.taskId,
      exceptionType: current.exceptionType,
    );

    final updatedItems = List<FloorExceptionCollectionItem>.from(current.items)
      ..add(item);
    final updatedStocks = List<FloorExceptionStock>.from(current.stocks)
      ..add(stock);

    var nextState = current.copyWith(
      items: List.unmodifiable(updatedItems),
      stocks: List.unmodifiable(updatedStocks),
      selectedIds: const [],
      barcodeContent: BarcodeContent.fromJson({}),
      collectQty: 0,
      matCode: '',
      batchNo: '',
      sn: '',
      matControlFlag: '',
    );
    nextState = _applyPlaceholder(nextState);
    return nextState;
  }

  void _onSelectionChanged(
    FloorExceptionSelectionChangedEvent event,
    Emitter<FloorExceptionCollectState> emit,
  ) {
    emit(state.copyWith(selectedIds: List.unmodifiable(event.selectedIds)));
  }

  void _onDeleteSelected(
    FloorExceptionDeleteSelectedEvent event,
    Emitter<FloorExceptionCollectState> emit,
  ) {
    if (state.selectedIds.isEmpty) {
      emit(state.copyWith(error: '请至少选择一行记录'));
      return;
    }

    final idSet = state.selectedIds.toSet();
    final remainingItems = state.items
        .where((item) => !idSet.contains(item.id))
        .toList();
    final remainingStocks = state.stocks
        .where((stock) => !idSet.contains(stock.id))
        .toList();

    emit(
      state.copyWith(
        items: List.unmodifiable(remainingItems),
        stocks: List.unmodifiable(remainingStocks),
        selectedIds: const [],
      ),
    );
  }

  Future<void> _onCommitRequested(
    FloorExceptionCommitRequestedEvent event,
    Emitter<FloorExceptionCollectState> emit,
  ) async {
    if (state.stocks.isEmpty) {
      emit(state.copyWith(error: '本次无采集明细，请确认！'));
      return;
    }

    emit(state.copyWith(isLoading: true, error: null));

    try {
      final payload = state.stocks
          .map(
            (stock) => stock.toPayload(
              taskNo: _summary.taskNo,
              proType: _summary.proType.isNotEmpty ? _summary.proType : '异常处理',
              proofNo: _summary.proofNo,
            ),
          )
          .toList();

      await _service.commitExceptionShelves(payload);

      var clearedState = state.copyWith(
        isLoading: false,
        successMessage: '提交成功',
        items: const [],
        stocks: const [],
        selectedIds: const [],
        barcodeContent: BarcodeContent.fromJson({}),
        collectQty: 0,
        matCode: '',
        batchNo: '',
        sn: '',
        matControlFlag: '',
        storeSite: '',
      );
      clearedState = _applyPlaceholder(clearedState);
      emit(clearedState);
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: '提交异常：${_formatError(e)}'));
    }
  }

  void _onClearError(
    FloorExceptionClearErrorEvent event,
    Emitter<FloorExceptionCollectState> emit,
  ) {
    emit(state.copyWith(error: null));
  }

  void _onClearMessage(
    FloorExceptionClearMessageEvent event,
    Emitter<FloorExceptionCollectState> emit,
  ) {
    emit(state.copyWith(successMessage: null));
  }

  FloorExceptionCollectState _applyPlaceholder(
    FloorExceptionCollectState current,
  ) {
    final placeholder = _computePlaceholder(current);
    return current.copyWith(
      placeholder: placeholder,
      focus: placeholder == '请输入数量',
    );
  }

  String _computePlaceholder(FloorExceptionCollectState current) {
    if (current.storeSite.isEmpty) {
      return '请扫描库位';
    }
    if (current.matCode.isEmpty) {
      return '请扫描二维码';
    }
    if (current.matControlFlag == '0') {
      return '';
    }
    if (current.collectQty <= 0) {
      return '请输入数量';
    }
    return '';
  }

  String _formatError(Object error) {
    final message = error.toString();
    return message.replaceFirst('Exception: ', '');
  }

  bool _isNumeric(String value) {
    return RegExp(r'^[0-9]+(\.[0-9]+)?$').hasMatch(value);
  }
}
