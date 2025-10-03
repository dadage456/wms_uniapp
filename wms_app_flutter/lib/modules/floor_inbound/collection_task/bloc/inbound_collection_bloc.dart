import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/modules/floor_inbound/collection_task/bloc/inbound_collection_event.dart';
import 'package:wms_app/modules/floor_inbound/collection_task/bloc/inbound_collection_state.dart';
import 'package:wms_app/modules/floor_inbound/collection_task/models/inbound_collection_models.dart';
import 'package:wms_app/modules/floor_inbound/services/floor_inbound_service.dart';
import 'package:wms_app/modules/floor_inbound/task_details/models/inbound_task_item.dart';

class InboundCollectionBloc extends Bloc<InboundCollectionEvent, InboundCollectionState> {
  InboundCollectionBloc(this._service) : super(const InboundCollectionState()) {
    on<InitializeInboundCollection>(_onInitialize);
    on<InboundScanPerformed>(_onScan);
    on<InboundManualQuantityConfirmed>(_onManualQuantityConfirmed);
    on<InboundRemoveRecord>(_onRemoveRecord);
    on<SubmitInboundCollection>(_onSubmit);
  }

  final FloorInboundService _service;

  Future<void> _onInitialize(
    InitializeInboundCollection event,
    Emitter<InboundCollectionState> emit,
  ) async {
    emit(
      state.copyWith(
        isLoading: true,
        task: event.task,
        errorMessage: null,
        infoMessage: null,
      ),
    );
    try {
      final query = InboundCollectionQuery(
        inTaskNo: event.task.inTaskNo,
        inTaskId: event.task.inTaskId,
        storeRoomNo: event.task.storeRoomNo,
        workStation: event.task.workStation,
        forceSite: event.task.forceSite,
        forceBatch: event.task.batchFlag,
        taskComment: event.task.voucherNo,
        userId: event.userId.toString(),
      );

      final detailList = await _service.getCollectionDetail(query);
      emit(
        state.copyWith(
          isLoading: false,
          context: InboundCollectionContext(
            taskItems: detailList,
            currentStep: InboundScanStep.site,
          ),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onScan(
    InboundScanPerformed event,
    Emitter<InboundCollectionState> emit,
  ) async {
    final ctx = state.context;
    if (ctx == null) return;
    switch (ctx.currentStep) {
      case InboundScanStep.site:
        await _handleSiteScan(event.content, emit);
        break;
      case InboundScanStep.material:
        await _handleMaterialScan(event.content, emit);
        break;
      case InboundScanStep.hazardProduction:
        await _handleHazardProductionScan(event.content, emit);
        break;
      case InboundScanStep.hazardExpiry:
        await _handleHazardExpiryScan(event.content, emit);
        break;
      case InboundScanStep.quantity:
        final qty = double.tryParse(event.content);
        if (qty == null || qty <= 0) {
          emit(state.copyWith(errorMessage: '数量条码无效'));
          return;
        }
        await _confirmQuantity(qty, emit);
        break;
    }
  }

  Future<void> _onManualQuantityConfirmed(
    InboundManualQuantityConfirmed event,
    Emitter<InboundCollectionState> emit,
  ) async {
    await _confirmQuantity(event.quantity, emit);
  }

  Future<void> _confirmQuantity(double quantity, Emitter<InboundCollectionState> emit) async {
    final ctx = state.context;
    final task = state.task;
    if (ctx == null || ctx.currentTaskItem == null || ctx.currentSite == null || task == null) {
      emit(state.copyWith(errorMessage: '请先扫描库位与物料'));
      return;
    }

    final taskItem = ctx.currentTaskItem!;
    final site = ctx.currentSite!;
    final materialInfo = ctx.materialInfo;
    final seqCtrl = materialInfo?.seqCtrl?.trim();
    final sn = (materialInfo?.sn?.trim().isNotEmpty ?? false)
        ? materialInfo!.sn!.trim()
        : taskItem.sn?.trim();

    if (seqCtrl == '0') {
      if (sn == null || sn.isEmpty) {
        emit(state.copyWith(errorMessage: '序列号物料必须提供序列号'));
        return;
      }
      if (quantity != 1) {
        emit(state.copyWith(errorMessage: '序列号物料数量必须为1'));
        return;
      }
      final serialKey = '${taskItem.matCode}@$sn';
      if (ctx.cache.serialNumbers.contains(serialKey)) {
        emit(state.copyWith(errorMessage: '物料 ${taskItem.matCode} 序列号【$sn】不允许重复采集'));
        return;
      }
    }

    if (materialInfo?.isHazard == true) {
      if (materialInfo?.productionDate == null) {
        emit(state.copyWith(errorMessage: '危化品需要先录入生产日期'));
        return;
      }
      if (materialInfo?.validDays == null) {
        emit(state.copyWith(errorMessage: '危化品需要先录入有效期天数'));
        return;
      }
    }

    final existingInCache = _sumCacheQuantity(taskItem.itemId, ctx);
    final alreadyCollected = taskItem.collectedQty + existingInCache;
    final remainingPlan = taskItem.planQty - alreadyCollected;
    if (remainingPlan <= 0) {
      emit(state.copyWith(errorMessage: '物料 ${taskItem.matCode} 已完成采集'));
      return;
    }
    if (quantity > remainingPlan) {
      emit(state.copyWith(errorMessage: '本次采集数量超过计划剩余数量 $remainingPlan'));
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: null, infoMessage: null));
    try {
      double availableQty = ctx.availableQty;
      if (availableQty <= 0) {
        availableQty = await _fetchInventory(site, taskItem.matCode);
      }

      if (availableQty <= 0) {
        throw Exception('库位【$site】未查询到物料【${taskItem.matCode}】库存');
      }
      if (quantity > availableQty) {
        throw Exception('库位【$site】仅剩库存 $availableQty，无法采集 $quantity');
      }

      final batchNo = (materialInfo?.batchNo?.isNotEmpty ?? false)
          ? materialInfo!.batchNo!
          : taskItem.batchNo;

      final record = InboundCollectionRecord(
        itemId: taskItem.itemId,
        inTaskId: taskItem.inTaskId,
        storeSiteNo: site,
        matCode: taskItem.matCode,
        matName: taskItem.matName,
        batchNo: batchNo,
        quantity: quantity,
        sn: sn,
        supplierName: materialInfo?.supplierName ?? taskItem.supplierName,
        subInventoryCode: materialInfo?.subInventoryCode ?? taskItem.subInventoryCode,
        productionDate: materialInfo?.productionDate,
        validDays: materialInfo?.validDays,
      );

      final updatedRecords = List<InboundCollectionRecord>.from(ctx.cache.records)
        ..add(record);
      final updatedItems = ctx.taskItems.map((item) {
        if (item.itemId == taskItem.itemId) {
          return item.copyWith(collectedQty: item.collectedQty + quantity);
        }
        return item;
      }).toList();

      final updatedSerials = Set<String>.from(ctx.cache.serialNumbers);
      if (seqCtrl == '0' && (sn?.isNotEmpty ?? false)) {
        updatedSerials.add('${taskItem.matCode}@$sn');
      }

      final remainingInventory = availableQty - quantity;

      emit(
        state.copyWith(
          isLoading: false,
          context: ctx.copyWith(
            taskItems: updatedItems,
            cache: ctx.cache
                .copyWith(records: updatedRecords, serialNumbers: updatedSerials),
            currentStep: InboundScanStep.site,
            currentTaskItem: null,
            currentSite: null,
            currentBarcode: null,
            materialInfo: null,
            clearMaterialInfo: true,
            availableQty: remainingInventory > 0 ? remainingInventory : 0,
          ),
          infoMessage: '已采集 ${record.matCode} 数量 $quantity',
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _handleHazardProductionScan(
    String raw,
    Emitter<InboundCollectionState> emit,
  ) async {
    final ctx = state.context;
    if (ctx == null || ctx.materialInfo == null) {
      emit(state.copyWith(errorMessage: '请先扫描危化品物料条码'));
      return;
    }

    final date = _parseDateInput(raw);
    if (date == null) {
      emit(state.copyWith(errorMessage: '生产日期格式不正确，示例：2024-01-01'));
      return;
    }

    final updatedInfo = ctx.materialInfo!.copyWith(productionDate: date);
    final nextStep = updatedInfo.validDays == null
        ? InboundScanStep.hazardExpiry
        : InboundScanStep.quantity;

    final updatedContext = ctx.copyWith(
      materialInfo: updatedInfo,
      currentStep: nextStep,
    );

    emit(
      state.copyWith(
        context: updatedContext,
        infoMessage: nextStep == InboundScanStep.quantity
            ? '危化品信息已补全，请录入数量'
            : '生产日期已录入，请继续录入有效期天数',
      ),
    );

    if ((updatedInfo.seqCtrl ?? '').trim() == '0' &&
        nextStep == InboundScanStep.quantity) {
      await _confirmQuantity(1, emit);
    }
  }

  Future<void> _handleHazardExpiryScan(
    String raw,
    Emitter<InboundCollectionState> emit,
  ) async {
    final ctx = state.context;
    if (ctx == null || ctx.materialInfo == null) {
      emit(state.copyWith(errorMessage: '请先扫描危化品物料条码'));
      return;
    }

    final trimmed = raw.trim();
    final days = int.tryParse(trimmed);
    if (days == null || days <= 0) {
      emit(state.copyWith(errorMessage: '有效期天数必须为正整数'));
      return;
    }

    final updatedInfo = ctx.materialInfo!.copyWith(validDays: days);
    final updatedContext = ctx.copyWith(
      materialInfo: updatedInfo,
      currentStep: InboundScanStep.quantity,
    );

    emit(
      state.copyWith(
        context: updatedContext,
        infoMessage: '有效期已录入，请录入数量',
      ),
    );

    if ((updatedInfo.seqCtrl ?? '').trim() == '0') {
      await _confirmQuantity(1, emit);
    }
  }

  Future<void> _onRemoveRecord(
    InboundRemoveRecord event,
    Emitter<InboundCollectionState> emit,
  ) async {
    final ctx = state.context;
    if (ctx == null) return;
    if (event.recordIndex < 0 || event.recordIndex >= ctx.cache.records.length) {
      return;
    }
    final record = ctx.cache.records[event.recordIndex];
    final updated = List<InboundCollectionRecord>.from(ctx.cache.records)
      ..removeAt(event.recordIndex);
    final updatedItems = ctx.taskItems.map((item) {
      if (item.itemId == record.itemId) {
        final newCollected = item.collectedQty - record.quantity;
        return item.copyWith(collectedQty: newCollected < 0 ? 0 : newCollected);
      }
      return item;
    }).toList();

    final updatedSerials = Set<String>.from(ctx.cache.serialNumbers);
    if ((record.sn ?? '').isNotEmpty) {
      updatedSerials.remove('${record.matCode}@${record.sn}');
    }

    emit(
      state.copyWith(
        context: ctx.copyWith(
          taskItems: updatedItems,
          cache: ctx.cache.copyWith(records: updated, serialNumbers: updatedSerials),
        ),
        infoMessage: '已删除 ${record.matCode} 数量 ${record.quantity}',
      ),
    );
  }

  Future<void> _onSubmit(
    SubmitInboundCollection event,
    Emitter<InboundCollectionState> emit,
  ) async {
    final ctx = state.context;
    final task = state.task;
    if (ctx == null || task == null) {
      return;
    }
    if (ctx.cache.records.isEmpty) {
      emit(state.copyWith(errorMessage: '没有可提交的采集记录'));
      return;
    }
    emit(state.copyWith(isLoading: true));
    try {
      final upShelvesInfos = ctx.cache.records.map((record) {
        return {
          'intaskno': task.inTaskNo,
          'intaskid': task.inTaskId,
          'storesite': record.storeSiteNo,
          'matcode': record.matCode,
          'matname': record.matName,
          'batchno': record.batchNo,
          'qty': record.quantity,
          if (record.sn != null) 'sn': record.sn,
          if (record.subInventoryCode != null) 'subinventorycode': record.subInventoryCode,
        };
      }).toList();
      final itemInfos = ctx.cache.records.map((record) {
        return {
          'intaskitemid': record.itemId,
          'qty': record.quantity,
        };
      }).toList();
      final filter = ctx.cache.records
          .where((record) => record.sn != null && record.sn!.isNotEmpty)
          .map((record) => record.sn!)
          .join(',');
      await _service.submitCollection(
        upShelvesInfos: upShelvesInfos,
        itemListInfos: itemInfos,
        serialFilter: filter,
      );
      emit(
        state.copyWith(
          isLoading: false,
          context: ctx.copyWith(cache: const InboundCollectionCache()),
          infoMessage: '提交成功',
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _handleSiteScan(
    String raw,
    Emitter<InboundCollectionState> emit,
  ) async {
    final site = _extractSiteCode(raw);
    if (site == null || site.isEmpty) {
      emit(state.copyWith(errorMessage: '无效的库位条码'));
      return;
    }

    final task = state.task;
    final ctx = state.context;
    if (task == null || ctx == null) {
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: null, infoMessage: null));
    try {
      final response = await _service.getStoreSite(
        storeRoomNo: task.storeRoomNo,
        storeSiteNo: site,
      );
      final code = response['code']?.toString();
      if (code != '200') {
        throw Exception(response['msg']?.toString() ?? '库位验证失败');
      }

      final data = response['data'];
      if (data is! List || data.isEmpty) {
        throw Exception('库房【${task.storeRoomNo}】下无库位号【$site】');
      }

      final first = Map<String, dynamic>.from(data.first as Map);
      if (first['isfrozen']?.toString() != '0') {
        throw Exception('库位【$site】被锁定或者冻结');
      }

      emit(
        state.copyWith(
          isLoading: false,
          context: ctx.copyWith(
            currentSite: site,
            currentStep: InboundScanStep.material,
            currentTaskItem: null,
            currentBarcode: null,
            materialInfo: null,
            clearMaterialInfo: true,
            availableQty: 0,
          ),
          infoMessage: '库位 $site 已识别，请扫码物料',
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  Future<void> _handleMaterialScan(
    String raw,
    Emitter<InboundCollectionState> emit,
  ) async {
    final ctx = state.context;
    if (ctx == null) return;

    final barcode = raw.trim();
    if (barcode.isEmpty) {
      emit(state.copyWith(errorMessage: '无效的物料条码'));
      return;
    }

    if ((ctx.currentSite ?? '').isEmpty) {
      emit(state.copyWith(errorMessage: '请先扫描库位'));
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: null, infoMessage: null));
    try {
      final materialInfo = await _service.getMaterialInfo(barcode);
      final matCode = materialInfo.matCode.trim();
      if (matCode.isEmpty) {
        throw Exception('无法识别物料条码');
      }

      final target = _matchTaskItem(
        ctx.taskItems,
        matCode,
        materialInfo.batchNo?.trim(),
        materialInfo.sn?.trim(),
        materialInfo.seqCtrl,
      );

      final availableQty = await _fetchInventory(ctx.currentSite!, target.matCode);

      InboundScanStep nextStep = InboundScanStep.quantity;
      if (materialInfo.isHazard && materialInfo.productionDate == null) {
        nextStep = InboundScanStep.hazardProduction;
      } else if (materialInfo.isHazard && materialInfo.validDays == null) {
        nextStep = InboundScanStep.hazardExpiry;
      }

      final updatedContext = ctx.copyWith(
        currentBarcode: barcode,
        currentTaskItem: target,
        currentStep: nextStep,
        materialInfo: materialInfo,
        availableQty: availableQty,
      );

      emit(
        state.copyWith(
          isLoading: false,
          context: updatedContext,
          infoMessage: _buildMaterialRecognisedMessage(materialInfo, target, nextStep),
        ),
      );

      final seqCtrl = materialInfo.seqCtrl?.trim();
      if (seqCtrl == '0' && nextStep == InboundScanStep.quantity) {
        await _confirmQuantity(1, emit);
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }


  InboundTaskItem _matchTaskItem(
    List<InboundTaskItem> items,
    String matCode,
    String? batchNo,
    String? sn,
    String? seqCtrl,
  ) {
    final normalized = matCode.trim();
    final serialCtrl = seqCtrl?.trim();

    if (serialCtrl == '0' && sn != null && sn.isNotEmpty) {
      try {
        return items.firstWhere(
          (item) =>
              item.matCode == normalized &&
              ((item.sn?.isEmpty ?? true) || item.sn == sn),
        );
      } catch (_) {
        // fall back to batch matching
      }
    }

    if (batchNo != null && batchNo.isNotEmpty) {
      try {
        return items.firstWhere(
          (item) =>
              item.matCode == normalized &&
              (item.batchNo.isEmpty || item.batchNo == batchNo),
        );
      } catch (_) {
        // fall back to mat code only
      }
    }

    return items.firstWhere(
      (item) => item.matCode == normalized,
      orElse: () => throw Exception('物料$normalized不在任务明细中'),
    );
  }

  String _buildMaterialRecognisedMessage(
    InboundBarcodeContent info,
    InboundTaskItem item,
    InboundScanStep step,
  ) {
    if (step == InboundScanStep.hazardProduction) {
      return '物料 ${item.matCode}(${item.matName}) 为危化品，请录入生产日期';
    }
    if (step == InboundScanStep.hazardExpiry) {
      return '物料 ${item.matCode}(${item.matName}) 为危化品，请录入有效期天数';
    }
    if ((info.seqCtrl ?? '').trim() == '0') {
      return '物料 ${item.matCode}(${item.matName}) 为序列管理，将自动采集数量1';
    }
    return '物料 ${item.matCode}(${item.matName}) 已识别，请录入数量';
  }

  String? _extractSiteCode(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    if (trimmed.contains(r'$KW$')) {
      final parts = trimmed.split(r'$');
      if (parts.length > 2 && parts[2].isNotEmpty) {
        return parts[2];
      }
      return null;
    }
    return trimmed;
  }

  DateTime? _parseDateInput(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    final normalized = trimmed.contains('-')
        ? trimmed
        : trimmed.length == 8
            ? '${trimmed.substring(0, 4)}-${trimmed.substring(4, 6)}-${trimmed.substring(6)}'
            : trimmed;
    return DateTime.tryParse(normalized);
  }

  double _sumCacheQuantity(String itemId, InboundCollectionContext ctx) {
    return ctx.cache.records
        .where((record) => record.itemId == itemId)
        .fold<double>(0, (sum, record) => sum + record.quantity);
  }

  Future<double> _fetchInventory(String storeSite, String matCode) async {
    final response = await _service.getInventoryBySite(
      storeSite: storeSite,
      matCode: matCode,
    );

    final code = response['code']?.toString();
    if (code != '200') {
      throw Exception(response['msg']?.toString() ?? '获取库存失败');
    }

    final data = response['data'];
    if (data is List) {
      double total = 0;
      for (final item in data) {
        if (item is Map) {
          total += double.tryParse(item['repqty']?.toString() ?? '') ?? 0;
        }
      }
      return total;
    }

    return 0;
  }
}
