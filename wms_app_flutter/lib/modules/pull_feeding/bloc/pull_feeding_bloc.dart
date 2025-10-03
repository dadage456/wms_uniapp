import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/modules/pull_feeding/bloc/pull_feeding_event.dart';
import 'package:wms_app/modules/pull_feeding/bloc/pull_feeding_state.dart';
import 'package:wms_app/modules/pull_feeding/models/pull_feeding_models.dart';
import 'package:wms_app/modules/pull_feeding/services/pull_feeding_service.dart';

class PullFeedingBloc extends Bloc<PullFeedingEvent, PullFeedingState> {
  PullFeedingBloc({required PullFeedingService service})
      : _service = service,
        super(const PullFeedingState()) {
    on<PullFeedingInitialized>(_onInitialized);
    on<PullFeedingScanReceived>(_onScanReceived);
    on<PullFeedingQuantitySubmitted>(_onQuantitySubmitted);
    on<PullFeedingSelectionChanged>(_onSelectionChanged);
    on<PullFeedingDeleteSelected>(_onDeleteSelected);
    on<PullFeedingSubmitRequested>(_onSubmitRequested);
    on<PullFeedingResetRequested>(_onResetRequested);
    on<PullFeedingMessageCleared>(_onMessageCleared);
  }

  final PullFeedingService _service;
  final Map<String, double> _collectedByMaterial = {};
  final Map<String, PullFeedingRecord> _recordsByKey = {};

  FutureOr<void> _onInitialized(
    PullFeedingInitialized event,
    Emitter<PullFeedingState> emit,
  ) {
    emit(const PullFeedingState());
    _collectedByMaterial.clear();
    _recordsByKey.clear();
  }

  Future<void> _onScanReceived(
    PullFeedingScanReceived event,
    Emitter<PullFeedingState> emit,
  ) async {
    final code = event.code.trim();
    if (code.isEmpty) {
      emit(state.copyWith(errorMessage: '采集内容为空,请重新采集'));
      return;
    }

    try {
      if (_isNumeric(code)) {
        if (state.step != PullFeedingStep.quantity) {
          throw Exception('请先完成前序采集，再输入数量');
        }
        await _finalizeQuantity(double.parse(code), emit);
        return;
      }

      if (code.contains(r'$KW$')) {
        final site = _parseStoreSite(code);
        if (site.isEmpty) {
          throw Exception('库位条码不合法');
        }
        emit(
          state
              .clearMessages()
              .copyWith(
                storeSite: site,
                step: PullFeedingStep.material,
                placeholder: _placeholder(
                  storeSite: site,
                  barcodeContent: null,
                  collectQty: 0,
                ),
                focusInput: false,
                status: PullFeedingStatus.ready,
                inventoryQty: 0,
                collectQty: 0,
                quantityRule: const PullFeedingQuantityRule(),
                clearBarcode: true,
              ),
        );
        return;
      }

      if (code.contains('MC')) {
        if (state.storeSite.isEmpty) {
          throw Exception('请先扫描货架号');
        }
        emit(state.clearMessages().copyWith(status: PullFeedingStatus.loading));
        final barcode = await _service.getMaterialInfo(code);
        final inventory = await _service.getInventoryQuantity(
          storeSite: state.storeSite,
          materialCode: barcode.materialCode,
        );
        PullFeedingQuantityRule rule = const PullFeedingQuantityRule();
        if (state.storeSite.isNotEmpty) {
          rule = await _service.getQuantityRule(
            materialCode: barcode.materialCode,
            storeSite: state.storeSite,
          );
        }
        emit(
          state.copyWith(
            status: PullFeedingStatus.ready,
            barcodeContent: barcode,
            inventoryQty: inventory,
            quantityRule: rule,
            step: PullFeedingStep.quantity,
            placeholder: _placeholder(
              storeSite: state.storeSite,
              barcodeContent: barcode,
              collectQty: 0,
            ),
            focusInput: true,
            collectQty: 0,
          ),
        );
        return;
      }

      throw Exception('采集内容不合法!');
    } catch (e) {
      emit(
        state.copyWith(
          status: PullFeedingStatus.ready,
          errorMessage: _formatError(e),
          focusInput: false,
        ),
      );
    }
  }

  Future<void> _onQuantitySubmitted(
    PullFeedingQuantitySubmitted event,
    Emitter<PullFeedingState> emit,
  ) async {
    final value = event.quantityText.trim();
    if (value.isEmpty) {
      emit(state.copyWith(errorMessage: '数量不能为空'));
      return;
    }

    if (!_isNumeric(value)) {
      emit(state.copyWith(errorMessage: '请输入合法的数量'));
      return;
    }

    try {
      await _finalizeQuantity(double.parse(value), emit);
    } catch (e) {
      emit(state.copyWith(errorMessage: _formatError(e)));
    }
  }

  FutureOr<void> _onSelectionChanged(
    PullFeedingSelectionChanged event,
    Emitter<PullFeedingState> emit,
  ) {
    emit(state.copyWith(selectedRecordIds: event.selectedIds.toSet()));
  }

  FutureOr<void> _onDeleteSelected(
    PullFeedingDeleteSelected event,
    Emitter<PullFeedingState> emit,
  ) {
    if (state.selectedRecordIds.isEmpty) {
      emit(state.copyWith(errorMessage: '请至少选择一行记录'));
      return;
    }

    final remaining = <PullFeedingRecord>[];
    for (final record in state.records) {
      if (state.selectedRecordIds.contains(record.id)) {
        final materialKey = record.materialCode;
        final key = _buildKey(record.storeSite, record.materialCode);
        final currentTotal = _collectedByMaterial[materialKey] ?? 0;
        final nextTotal = currentTotal - record.quantity;
        if (nextTotal <= 0.000001) {
          _collectedByMaterial.remove(materialKey);
        } else {
          _collectedByMaterial[materialKey] = nextTotal;
        }
        _recordsByKey.remove(key);
      } else {
        remaining.add(record);
      }
    }

    emit(
      state.copyWith(
        records: remaining,
        selectedRecordIds: <String>{},
        successMessage: '删除成功',
        errorMessage: null,
      ),
    );
  }

  Future<void> _onSubmitRequested(
    PullFeedingSubmitRequested event,
    Emitter<PullFeedingState> emit,
  ) async {
    if (state.records.isEmpty) {
      emit(state.copyWith(errorMessage: '本次无采集明细，请确认！'));
      return;
    }

    emit(state.copyWith(status: PullFeedingStatus.submitting, errorMessage: null));
    try {
      await _service.submit(state.records);
      _collectedByMaterial.clear();
      _recordsByKey.clear();
      emit(
        const PullFeedingState(
          status: PullFeedingStatus.ready,
          successMessage: '提交成功',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: PullFeedingStatus.ready,
          errorMessage: _formatError(e),
        ),
      );
    }
  }

  FutureOr<void> _onResetRequested(
    PullFeedingResetRequested event,
    Emitter<PullFeedingState> emit,
  ) {
    _collectedByMaterial.clear();
    _recordsByKey.clear();
    emit(const PullFeedingState(status: PullFeedingStatus.ready));
  }

  FutureOr<void> _onMessageCleared(
    PullFeedingMessageCleared event,
    Emitter<PullFeedingState> emit,
  ) {
    emit(state.clearMessages());
  }

  Future<void> _finalizeQuantity(
    double quantity,
    Emitter<PullFeedingState> emit,
  ) async {
    if (quantity <= 0) {
      throw Exception('数量必须大于0');
    }
    if (state.storeSite.isEmpty) {
      throw Exception('请先扫描货架号');
    }
    final barcode = state.barcodeContent;
    if (barcode == null) {
      throw Exception('请先扫描二维码');
    }

    final materialCode = barcode.materialCode;
    final materialKey = materialCode;
    final key = _buildKey(state.storeSite, materialCode);
    final collected = _collectedByMaterial[materialKey] ?? 0;
    final available = state.inventoryQty;

    if (available - collected < quantity && available > 0) {
      if (collected > 0) {
        throw Exception('已经扫描数【$collected】加上本次扫描数量【$quantity】大于库存数【$available】，请确认!');
      }
      throw Exception('库存数【$available】小于本次作业数量【$quantity】，请确认!');
    }

    final updatedRecords = List<PullFeedingRecord>.from(state.records);
    final existing = _recordsByKey[key];
    PullFeedingRecord record;
    if (existing != null) {
      final index = updatedRecords.indexWhere((element) => element.id == existing.id);
      final nextQty = existing.quantity + quantity;
      record = existing.copyWith(quantity: nextQty);
      if (index >= 0) {
        updatedRecords[index] = record;
      }
    } else {
      record = PullFeedingRecord(
        storeSite: state.storeSite,
        materialCode: materialCode,
        materialName: barcode.materialName,
        quantity: quantity,
      );
      updatedRecords.add(record);
    }

    _recordsByKey[key] = record;
    _collectedByMaterial[materialKey] = collected + quantity;

    emit(
      state.copyWith(
        records: updatedRecords,
        collectQty: 0,
        inventoryQty: 0,
        quantityRule: const PullFeedingQuantityRule(),
        step: PullFeedingStep.material,
        placeholder: _placeholder(
          storeSite: state.storeSite,
          barcodeContent: null,
          collectQty: 0,
        ),
        clearBarcode: true,
        successMessage: '采集成功',
        focusInput: false,
      ),
    );
  }

  static String _buildKey(String storeSite, String materialCode) => '$storeSite|$materialCode';

  static bool _isNumeric(String value) {
    return double.tryParse(value) != null;
  }

  static String _parseStoreSite(String code) {
    final parts = code.split(r'$');
    if (parts.length >= 3) {
      return parts[2];
    }
    return '';
  }

  static String _placeholder({
    required String storeSite,
    required PullFeedingBarcodeContent? barcodeContent,
    required double collectQty,
  }) {
    if (storeSite.isEmpty) {
      return '请扫描货架号';
    }
    if (barcodeContent == null) {
      return '请扫描二维码';
    }
    if (collectQty <= 0) {
      return '请输入数量';
    }
    return '';
  }

  static String _formatError(Object error) {
    final message = error.toString();
    return message.replaceFirst('Exception: ', '');
  }
}
