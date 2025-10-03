import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/modules/floor_transfer/models/transfer_models.dart';
import 'package:wms_app/modules/floor_transfer/services/floor_transfer_service.dart';
import 'package:wms_app/modules/floor_transfer/transfer_flow/bloc/floor_transfer_event.dart';
import 'package:wms_app/modules/floor_transfer/transfer_flow/bloc/floor_transfer_state.dart';
import 'package:wms_app/modules/outbound/collection_task/models/collection_models.dart';

class FloorTransferBloc extends Bloc<FloorTransferEvent, FloorTransferState> {
  FloorTransferBloc({required FloorTransferService service})
      : _service = service,
        super(const FloorTransferState()) {
    on<FloorTransferInitialized>(_onInitialized);
    on<FloorTransferModeChanged>(_onModeChanged);
    on<FloorTransferScanReceived>(_onScanReceived);
    on<FloorTransferQuantitySubmitted>(_onQuantitySubmitted);
    on<FloorTransferStockSelected>(_onStockSelected);
    on<FloorTransferSelectionChanged>(_onSelectionChanged);
    on<FloorTransferDeleteSelected>(_onDeleteSelected);
    on<FloorTransferSubmitRequested>(_onSubmitRequested);
    on<FloorTransferTabChanged>(_onTabChanged);
    on<FloorTransferInventorySearchRequested>(_onInventorySearchRequested);
    on<FloorTransferInventoryPageChanged>(_onInventoryPageChanged);
    on<FloorTransferMessageCleared>(_onMessageCleared);
    on<FloorTransferResetRequested>(_onResetRequested);
  }

  final FloorTransferService _service;
  final Map<String, double> _collectedQtyByKey = {};
  final Set<String> _collectedSerials = {};

  static const _inventoryPageSize = 20;

  FutureOr<void> _onInitialized(
    FloorTransferInitialized event,
    Emitter<FloorTransferState> emit,
  ) {
    var initialState = state.copyWith(
      mode: event.initialMode ?? state.mode,
      errorMessage: null,
      successMessage: null,
      records: const [],
      selectedRecordIds: const [],
      sourceStocks: const [],
      inventoryQueryResults: const [],
      inventoryQueryPage: 1,
      inventoryQueryTotalPages: 1,
      inventoryQueryKeyword: '',
      inventoryQueryStep: 'M',
      barcodeContent: null,
    );
    initialState = _applyPlaceholder(initialState.copyWith(
      sourceSite: '',
      targetSite: '',
      storeRoom: '',
      materialCode: '',
      materialName: '',
      batchNo: '',
      serialNo: '',
      projectNum: '',
      erpStoreRoom: '',
      erpOwnerCode: '',
      quantity: 0,
      materialControl: MaterialControl.none,
    ));
    _rebuildAggregations(const []);
    emit(initialState);
  }

  FutureOr<void> _onModeChanged(
    FloorTransferModeChanged event,
    Emitter<FloorTransferState> emit,
  ) {
    var nextState = state.copyWith(mode: event.mode);
    nextState = _resetCollectionFields(nextState, clearRecords: true);
    emit(nextState);
  }

  Future<void> _onScanReceived(
    FloorTransferScanReceived event,
    Emitter<FloorTransferState> emit,
  ) async {
    final code = event.code.trim();
    if (code.isEmpty) {
      emit(state.copyWith(errorMessage: '采集内容为空,请重新采集'));
      return;
    }

    try {
      var workingState = state.copyWith(
        errorMessage: null,
        successMessage: null,
        focusInput: false,
      );

      if (_isNumeric(code) && workingState.step == TransferStep.quantity) {
        workingState = _handleQuantity(workingState, code);
        workingState = _applyPlaceholder(workingState);
        if (workingState.step == TransferStep.idle) {
          workingState = await _finalizeCollection(workingState, emit);
        } else {
          emit(workingState);
        }
        return;
      }

      if (code.contains(r'$KW$')) {
        emit(workingState.copyWith(isLoading: true));
        workingState = await _handleSite(workingState, code);
        workingState = _applyPlaceholder(workingState.copyWith(isLoading: false));
        emit(workingState);
        return;
      }

      if (code.contains('MC')) {
        emit(workingState.copyWith(isLoading: true));
        workingState = await _handleMaterial(workingState, code);
        workingState = _applyPlaceholder(workingState.copyWith(isLoading: false));
        if (workingState.step == TransferStep.idle) {
          workingState = await _finalizeCollection(workingState, emit);
        } else {
          emit(workingState);
        }
        return;
      }

      if (_isNumeric(code)) {
        // 如果当前步骤不是数量，提示错误
        throw Exception('请先完成前序采集，再输入数量');
      }

      throw Exception('采集内容不合法!');
    } catch (e) {
      final error = e is Exception ? e.toString().replaceFirst('Exception: ', '') : e.toString();
      var resetState = state.copyWith(
        isLoading: false,
        errorMessage: error,
        barcodeContent: null,
      );
      if (state.step == TransferStep.quantity) {
        resetState = resetState.copyWith(quantity: 0);
      }
      emit(_applyPlaceholder(resetState));
    }
  }

  FutureOr<void> _onQuantitySubmitted(
    FloorTransferQuantitySubmitted event,
    Emitter<FloorTransferState> emit,
  ) async {
    final code = event.quantityText.trim();
    if (code.isEmpty) {
      emit(state.copyWith(errorMessage: '数量不能为空'));
      return;
    }

    try {
      var workingState = state.copyWith(errorMessage: null, successMessage: null);
      workingState = _handleQuantity(workingState, code);
      workingState = _applyPlaceholder(workingState);
      if (workingState.step == TransferStep.idle) {
        workingState = await _finalizeCollection(workingState, emit);
      } else {
        emit(workingState);
      }
    } catch (e) {
      final error = e is Exception ? e.toString().replaceFirst('Exception: ', '') : e.toString();
      emit(state.copyWith(errorMessage: error));
    }
  }

  FutureOr<void> _onStockSelected(
    FloorTransferStockSelected event,
    Emitter<FloorTransferState> emit,
  ) {
    final stock = event.stock;
    var nextState = state.copyWith(
      erpStoreRoom: stock.erpStoreRoom,
      erpOwnerCode: stock.erpOwnerCode,
      projectNum: stock.projectNum,
      storeRoom: stock.storeRoomNo,
    );
    if (nextState.sourceSite.isEmpty) {
      nextState = nextState.copyWith(sourceSite: stock.storeSiteNo);
    }
    nextState = _applyPlaceholder(nextState);
    emit(nextState);
  }

  FutureOr<void> _onSelectionChanged(
    FloorTransferSelectionChanged event,
    Emitter<FloorTransferState> emit,
  ) {
    emit(state.copyWith(selectedRecordIds: List<String>.from(event.selectedIds)));
  }

  FutureOr<void> _onDeleteSelected(
    FloorTransferDeleteSelected event,
    Emitter<FloorTransferState> emit,
  ) {
    if (state.selectedRecordIds.isEmpty) {
      emit(state.copyWith(errorMessage: '请至少选择一条记录'));
      return;
    }
    final remaining = state.records
        .where((record) => !state.selectedRecordIds.contains(record.id))
        .toList();
    _rebuildAggregations(remaining);
    emit(state.copyWith(
      records: remaining,
      selectedRecordIds: const [],
      successMessage: '已删除选中的采集记录',
    ));
  }

  Future<void> _onSubmitRequested(
    FloorTransferSubmitRequested event,
    Emitter<FloorTransferState> emit,
  ) async {
    if (state.records.isEmpty) {
      emit(state.copyWith(errorMessage: '本次无采集明细，请确认！'));
      return;
    }

    emit(state.copyWith(isSubmitting: true, errorMessage: null, successMessage: null));
    try {
      final payload = _buildSubmissionPayload(state.records);
      await _service.commitTransfer(payload);
      final clearedState = state.copyWith(
        records: const [],
        selectedRecordIds: const [],
        inventoryQueryResults: const [],
        inventoryQueryKeyword: '',
        inventoryQueryPage: 1,
        inventoryQueryTotalPages: 1,
      );
      final resetState = _resetCollectionFields(
        clearedState,
        clearRecords: true,
      ).copyWith(
        isSubmitting: false,
        successMessage: '提交成功',
      );
      emit(resetState);
    } catch (e) {
      final error = e is Exception ? e.toString().replaceFirst('Exception: ', '') : e.toString();
      emit(state.copyWith(isSubmitting: false, errorMessage: error));
    }
  }

  FutureOr<void> _onTabChanged(
    FloorTransferTabChanged event,
    Emitter<FloorTransferState> emit,
  ) {
    emit(state.copyWith(currentTab: event.index));
  }

  Future<void> _onInventorySearchRequested(
    FloorTransferInventorySearchRequested event,
    Emitter<FloorTransferState> emit,
  ) async {
    final keyword = event.keyword.trim();
    if (keyword.isEmpty) {
      emit(state.copyWith(
        inventoryQueryKeyword: '',
        inventoryQueryResults: const [],
        inventoryQueryPage: 1,
        inventoryQueryTotalPages: 1,
        isInventoryQueryLoading: false,
        inventoryQueryStep: event.step,
      ));
      return;
    }

    emit(state.copyWith(
      isInventoryQueryLoading: true,
      inventoryQueryKeyword: keyword,
      inventoryQueryStep: event.step,
      inventoryQueryPage: event.page,
      errorMessage: null,
      successMessage: null,
    ));

    try {
      final page = await _service.getRepertoryByBarcode(
        barcode: keyword,
        step: event.step,
        pageIndex: event.page,
        pageSize: _inventoryPageSize,
      );
      emit(state.copyWith(
        isInventoryQueryLoading: false,
        inventoryQueryResults: page.rows,
        inventoryQueryPage: page.currentPage,
        inventoryQueryTotalPages: page.totalPages,
      ));
    } catch (e) {
      final error = e is Exception ? e.toString().replaceFirst('Exception: ', '') : e.toString();
      emit(state.copyWith(
        isInventoryQueryLoading: false,
        errorMessage: error,
      ));
    }
  }

  Future<void> _onInventoryPageChanged(
    FloorTransferInventoryPageChanged event,
    Emitter<FloorTransferState> emit,
  ) async {
    final keyword = state.inventoryQueryKeyword;
    if (keyword.isEmpty) {
      return;
    }
    add(FloorTransferInventorySearchRequested(
      keyword: keyword,
      step: state.inventoryQueryStep,
      page: event.pageIndex,
    ));
  }

  FutureOr<void> _onMessageCleared(
    FloorTransferMessageCleared event,
    Emitter<FloorTransferState> emit,
  ) {
    emit(state.copyWith(errorMessage: null, successMessage: null));
  }

  FutureOr<void> _onResetRequested(
    FloorTransferResetRequested event,
    Emitter<FloorTransferState> emit,
  ) {
    emit(_resetCollectionFields(state));
  }

  Future<FloorTransferState> _handleSite(
    FloorTransferState state,
    String barcode,
  ) async {
    final parts = barcode.split(r'$');
    if (parts.length < 3 || parts[2].isEmpty) {
      throw Exception('库位条码不合法');
    }
    final siteCode = parts[2];
    final sites = await _service.getStoreSiteByRoom(storeSiteNo: siteCode);
    if (sites.isEmpty) {
      throw Exception('库位号【$siteCode】不存在，请确认');
    }
    final site = sites.first;
    if (site.isLocked) {
      throw Exception('库位【$siteCode】被锁定或者冻结');
    }

    var storeRoom = state.storeRoom;
    if (storeRoom.isEmpty) {
      storeRoom = site.storeRoomNo;
    } else if (storeRoom != site.storeRoomNo) {
      throw Exception('库位【$siteCode】与已采集库位不属于同一库房');
    }

    if (state.step == TransferStep.sourceSite) {
      var next = state.copyWith(
        storeRoom: storeRoom,
        sourceSite: siteCode,
        erpStoreRoom: site.erpStoreRoom ?? state.erpStoreRoom,
        erpOwnerCode: site.erpOwnerCode ?? state.erpOwnerCode,
      );
      if (next.sourceSite.isNotEmpty && next.materialCode.isNotEmpty) {
        next = await _loadSourceInventory(next);
      }
      return next;
    } else {
      if (siteCode == state.sourceSite) {
        throw Exception('扫描的目标库位与来源库位一样，请确认');
      }
      var next = state.copyWith(
        storeRoom: storeRoom,
        targetSite: siteCode,
      );
      if (next.sourceSite.isNotEmpty && next.materialCode.isNotEmpty) {
        next = await _loadSourceInventory(next);
      }
      return next;
    }
  }

  Future<FloorTransferState> _handleMaterial(
    FloorTransferState state,
    String barcode,
  ) async {
    final info = await _service.getMaterialInfoByQR(barcode);
    if (info.matcode == null || info.matcode!.isEmpty) {
      throw Exception('物料条码识别失败');
    }

    final matCode = info.matcode!.trim();
    final matName = info.matname?.trim() ?? '';
    final matControl = info.seqctrl?.toString() ?? '';
    final newMartTask = info.id_old?.toString() ?? '';

    MaterialControl control;
    String batch = '';
    String serial = '';
    double quantity = state.quantity;

    if (matControl == '0') {
      control = MaterialControl.serial;
      serial = info.sn?.trim() ?? '';
      if (serial.isEmpty) {
        throw Exception('物料【$matCode】序列号为空，不允许采集');
      }
      batch = newMartTask == '1' ? (info.batchno ?? '') : '';
      quantity = 1;
    } else if (matControl == '1' || matControl == '2') {
      control = MaterialControl.batch;
      batch = newMartTask == '1' ? (info.batchno ?? '') : (info.sn ?? '');
      serial = newMartTask == '1' ? (info.sn ?? '') : '';
      if (batch.isEmpty) {
        throw Exception('物料【$matCode】批次号不能为空');
      }
      quantity = 0;
    } else {
      throw Exception('物料【$matCode】编码控制维护值不合法');
    }

    var nextState = state.copyWith(
      materialCode: matCode,
      materialName: matName,
      batchNo: batch,
      serialNo: serial,
      quantity: quantity,
      materialControl: control,
      barcodeContent: info,
    );

    if (nextState.sourceSite.isNotEmpty) {
      nextState = await _loadSourceInventory(nextState);
    }

    if (control == MaterialControl.serial) {
      nextState = nextState.copyWith(step: TransferStep.idle);
    }

    return nextState;
  }

  FloorTransferState _handleQuantity(FloorTransferState state, String barcode) {
    final qty = double.tryParse(barcode);
    if (qty == null || qty <= 0) {
      throw Exception('采集数量必须大于0');
    }
    if (state.materialControl == MaterialControl.serial) {
      throw Exception('序列管控物料无需录入数量');
    }
    return state.copyWith(quantity: qty);
  }

  Future<FloorTransferState> _loadSourceInventory(FloorTransferState state) async {
    if (state.sourceSite.isEmpty || state.materialCode.isEmpty) {
      return state;
    }
    if (state.targetSite.isEmpty) {
      return state;
    }
    final stocks = await _service.getRepertoryByStoresiteNoTransfer(
      state.sourceSite,
      state.targetSite,
    );
    return state.copyWith(sourceStocks: stocks);
  }

  Future<FloorTransferState> _finalizeCollection(
    FloorTransferState state,
    Emitter<FloorTransferState> emit,
  ) async {
    if (state.sourceSite.isEmpty) {
      throw Exception('来源库位不能为空');
    }
    if (state.targetSite.isEmpty) {
      throw Exception('目标库位不能为空');
    }
    if (state.materialCode.isEmpty) {
      throw Exception('物料不能为空');
    }
    if (state.materialControl != MaterialControl.serial && state.quantity <= 0) {
      throw Exception('采集数量必须大于0');
    }
    if (state.erpStoreRoom.isEmpty) {
      throw Exception('请从库存列表中选择记录确认子库信息');
    }

    final key = _buildQtyKey(
      state.sourceSite,
      state.materialCode,
      state.batchNo,
      state.erpStoreRoom,
      state.projectNum,
    );

    final available = state.sourceStocks
        .where((stock) => stock.matchesKey(
              state.sourceSite,
              state.materialCode,
              state.batchNo,
              state.erpStoreRoom,
              state.projectNum,
            ))
        .fold<double>(0, (sum, stock) => sum + stock.availableQty);
    if (available <= 0) {
      throw Exception('来源货位没有库存，请检查采集信息');
    }

    final collected = _collectedQtyByKey[key] ?? 0;
    final totalAfter = collected + state.quantity;
    if (totalAfter - available > 0.0001) {
      throw Exception('采集数量超过库存可用数量');
    }

    if (state.serialNo.isNotEmpty) {
      final serialKey = '${state.materialCode}@${state.serialNo}';
      if (_collectedSerials.contains(serialKey)) {
        throw Exception('序列号【${state.serialNo}】已采集，请勿重复');
      }
      _collectedSerials.add(serialKey);
    }
    _collectedQtyByKey[key] = totalAfter;

    final record = TransferRecord(
      sourceSite: state.sourceSite,
      targetSite: state.targetSite,
      materialCode: state.materialCode,
      materialName: state.materialName,
      batchNo: state.batchNo,
      serialNo: state.serialNo,
      quantity: state.quantity,
      erpStoreRoom: state.erpStoreRoom,
      erpOwnerCode: state.erpOwnerCode,
      projectNum: state.projectNum,
      mode: state.mode,
    );

    final records = List<TransferRecord>.from(state.records)..insert(0, record);

    var nextState = state.copyWith(
      records: records,
      selectedRecordIds: const [],
      materialCode: '',
      materialName: '',
      batchNo: '',
      serialNo: '',
      quantity: 0,
      materialControl: MaterialControl.none,
      barcodeContent: null,
      projectNum: '',
      erpStoreRoom: '',
      erpOwnerCode: '',
      successMessage: '采集成功',
    );
    nextState = _applyPlaceholder(nextState);
    emit(nextState);
    return nextState;
  }

  FloorTransferState _applyPlaceholder(FloorTransferState state) {
    TransferStep step;
    String placeholder;
    bool focus = false;

    if (state.sourceSite.isEmpty) {
      step = TransferStep.sourceSite;
      placeholder = '请扫描来源库位';
    } else if (state.targetSite.isEmpty) {
      step = TransferStep.targetSite;
      placeholder = '请扫描目标库位';
    } else if (state.materialCode.isEmpty) {
      step = TransferStep.material;
      placeholder = '请扫描物料条码';
    } else if (state.materialControl != MaterialControl.serial && state.quantity <= 0) {
      step = TransferStep.quantity;
      placeholder = '请输入数量';
      focus = true;
    } else {
      step = TransferStep.idle;
      placeholder = '';
    }

    return state.copyWith(
      step: step,
      placeholder: placeholder,
      focusInput: focus,
    );
  }

  TransferFilterResult _buildSubmissionPayload(List<TransferRecord> records) {
    final infos = records.map((record) => record.toSubmissionJson()).toList();
    final filter = records.map((record) => record.sourceSite).toSet().join(',');
    return TransferFilterResult(transferInfos: infos, filter: filter);
  }

  FloorTransferState _resetCollectionFields(
    FloorTransferState state, {
    bool clearRecords = false,
  }) {
    final records = clearRecords ? <TransferRecord>[] : state.records;
    _rebuildAggregations(records);
    var nextState = state.copyWith(
      records: records,
      selectedRecordIds: const [],
      sourceSite: '',
      targetSite: '',
      materialCode: '',
      materialName: '',
      batchNo: '',
      serialNo: '',
      quantity: 0,
      materialControl: MaterialControl.none,
      projectNum: '',
      erpStoreRoom: '',
      erpOwnerCode: '',
      sourceStocks: const [],
      barcodeContent: null,
      errorMessage: null,
      successMessage: null,
    );
    nextState = _applyPlaceholder(nextState);
    return nextState;
  }

  void _rebuildAggregations(List<TransferRecord> records) {
    _collectedQtyByKey.clear();
    _collectedSerials.clear();
    for (final record in records) {
      final key = _buildQtyKey(
        record.sourceSite,
        record.materialCode,
        record.batchNo,
        record.erpStoreRoom,
        record.projectNum,
      );
      _collectedQtyByKey[key] = (_collectedQtyByKey[key] ?? 0) + record.quantity;
      if (record.serialNo.isNotEmpty) {
        _collectedSerials.add('${record.materialCode}@${record.serialNo}');
      }
    }
  }

  String _buildQtyKey(
    String sourceSite,
    String materialCode,
    String batchNo,
    String erpRoom,
    String project,
  ) {
    return '$sourceSite|$materialCode|$batchNo|$erpRoom|$project';
  }

  bool _isNumeric(String value) => double.tryParse(value) != null;
}
