import 'package:equatable/equatable.dart';
import 'package:wms_app/modules/floor_inbound/task_details/models/inbound_task_item.dart';

enum InboundScanStep {
  site,
  material,
  hazardProduction,
  hazardExpiry,
  quantity,
}

class InboundBarcodeContent extends Equatable {
  const InboundBarcodeContent({
    required this.matCode,
    this.matName,
    this.batchNo,
    this.sn,
    this.seqCtrl,
    this.idOld,
    this.qty,
    this.dgFlag,
    this.productionDate,
    this.validDays,
    this.supplierName,
    this.subInventoryCode,
  });

  factory InboundBarcodeContent.fromJson(Map<String, dynamic> json) {
    DateTime? productionDate;
    final pdate = json['pdate']?.toString();
    if (pdate != null && pdate.isNotEmpty) {
      productionDate = DateTime.tryParse(pdate);
    }

    int? validDays;
    final vdays = json['vdays']?.toString();
    if (vdays != null && vdays.isNotEmpty) {
      validDays = int.tryParse(vdays);
    }

    return InboundBarcodeContent(
      matCode: json['matcode']?.toString() ?? '',
      matName: json['matname']?.toString(),
      batchNo: json['batchno']?.toString(),
      sn: json['sn']?.toString(),
      seqCtrl: json['seqctrl']?.toString(),
      idOld: json['id_old']?.toString(),
      qty: double.tryParse(json['qty']?.toString() ?? ''),
      dgFlag: json['dgFlg']?.toString(),
      productionDate: productionDate,
      validDays: validDays,
      supplierName: json['suppliername']?.toString(),
      subInventoryCode: json['subinventoryCode']?.toString(),
    );
  }

  final String matCode;
  final String? matName;
  final String? batchNo;
  final String? sn;
  final String? seqCtrl;
  final String? idOld;
  final double? qty;
  final String? dgFlag;
  final DateTime? productionDate;
  final int? validDays;
  final String? supplierName;
  final String? subInventoryCode;

  bool get isHazard => (dgFlag ?? '').toUpperCase() == 'Y';

  InboundBarcodeContent copyWith({
    DateTime? productionDate,
    bool clearProductionDate = false,
    int? validDays,
    bool clearValidDays = false,
  }) {
    return InboundBarcodeContent(
      matCode: matCode,
      matName: matName,
      batchNo: batchNo,
      sn: sn,
      seqCtrl: seqCtrl,
      idOld: idOld,
      qty: qty,
      dgFlag: dgFlag,
      productionDate: clearProductionDate
          ? null
          : (productionDate ?? this.productionDate),
      validDays: clearValidDays ? null : (validDays ?? this.validDays),
      supplierName: supplierName,
      subInventoryCode: subInventoryCode,
    );
  }

  @override
  List<Object?> get props => [
        matCode,
        matName,
        batchNo,
        sn,
        seqCtrl,
        idOld,
        qty,
        dgFlag,
        productionDate,
        validDays,
        supplierName,
        subInventoryCode,
      ];
}

class InboundCollectionRecord extends Equatable {
  const InboundCollectionRecord({
    required this.itemId,
    required this.inTaskId,
    required this.storeSiteNo,
    required this.matCode,
    required this.matName,
    required this.batchNo,
    required this.quantity,
    this.sn,
    this.supplierName,
    this.subInventoryCode,
    this.productionDate,
    this.validDays,
  });

  final String itemId;
  final String inTaskId;
  final String storeSiteNo;
  final String matCode;
  final String matName;
  final String batchNo;
  final double quantity;
  final String? sn;
  final String? supplierName;
  final String? subInventoryCode;
  final DateTime? productionDate;
  final int? validDays;

  Map<String, dynamic> toJson() {
    return {
      'intaskitemid': itemId,
      'intaskid': inTaskId,
      'storeSite': storeSiteNo,
      'matCode': matCode,
      'matName': matName,
      'batchNo': batchNo,
      'qty': quantity,
      if (sn != null) 'sn': sn,
      if (supplierName != null) 'supplierName': supplierName,
      if (subInventoryCode != null) 'subinventoryCode': subInventoryCode,
      if (productionDate != null) 'data1': _formatDate(productionDate!),
      if (validDays != null) 'data2': validDays,
    };
  }

  static String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [
        itemId,
        inTaskId,
        storeSiteNo,
        matCode,
        matName,
        batchNo,
        quantity,
        sn,
        supplierName,
        subInventoryCode,
        productionDate,
        validDays,
      ];
}

class InboundCollectionCache extends Equatable {
  const InboundCollectionCache({
    this.records = const [],
    this.step = InboundScanStep.site,
    this.serialNumbers = const <String>{},
  });

  final List<InboundCollectionRecord> records;
  final InboundScanStep step;
  final Set<String> serialNumbers;

  InboundCollectionCache copyWith({
    List<InboundCollectionRecord>? records,
    InboundScanStep? step,
    Set<String>? serialNumbers,
  }) {
    return InboundCollectionCache(
      records: records ?? this.records,
      step: step ?? this.step,
      serialNumbers: serialNumbers ?? this.serialNumbers,
    );
  }

  @override
  List<Object?> get props {
    final serialList = serialNumbers.toList()..sort();
    return [records, step, serialList];
  }
}

class InboundCollectionContext extends Equatable {
  const InboundCollectionContext({
    required this.taskItems,
    required this.currentStep,
    this.currentSite,
    this.currentTaskItem,
    this.currentBarcode,
    this.inputQty,
    this.availableQty = 0,
    this.materialInfo,
    this.cache = const InboundCollectionCache(),
  });

  final List<InboundTaskItem> taskItems;
  final InboundScanStep currentStep;
  final String? currentSite;
  final InboundTaskItem? currentTaskItem;
  final String? currentBarcode;
  final double? inputQty;
  final double availableQty;
  final InboundBarcodeContent? materialInfo;
  final InboundCollectionCache cache;

  InboundCollectionContext copyWith({
    List<InboundTaskItem>? taskItems,
    InboundScanStep? currentStep,
    String? currentSite,
    InboundTaskItem? currentTaskItem,
    String? currentBarcode,
    double? inputQty,
    double? availableQty,
    InboundBarcodeContent? materialInfo,
    bool clearMaterialInfo = false,
    InboundCollectionCache? cache,
  }) {
    return InboundCollectionContext(
      taskItems: taskItems ?? this.taskItems,
      currentStep: currentStep ?? this.currentStep,
      currentSite: currentSite ?? this.currentSite,
      currentTaskItem: currentTaskItem ?? this.currentTaskItem,
      currentBarcode: currentBarcode ?? this.currentBarcode,
      inputQty: inputQty ?? this.inputQty,
      availableQty: availableQty ?? this.availableQty,
      materialInfo: clearMaterialInfo ? null : (materialInfo ?? this.materialInfo),
      cache: cache ?? this.cache,
    );
  }

  @override
  List<Object?> get props => [
        taskItems,
        currentStep,
        currentSite,
        currentTaskItem,
        currentBarcode,
        inputQty,
        availableQty,
        materialInfo,
        cache,
      ];
}

class InboundCollectionQuery extends Equatable {
  const InboundCollectionQuery({
    required this.inTaskNo,
    required this.inTaskId,
    required this.storeRoomNo,
    required this.workStation,
    this.forceSite = '',
    this.forceBatch = '',
    this.taskComment = '',
    this.taskFinishFlag = '0',
    this.roomTag = '0',
    this.sortType = '',
    this.sortColumn = '',
    this.searchKey = '',
    this.userId = '',
  });

  final String inTaskNo;
  final String inTaskId;
  final String storeRoomNo;
  final String workStation;
  final String forceSite;
  final String forceBatch;
  final String taskComment;
  final String taskFinishFlag;
  final String roomTag;
  final String sortType;
  final String sortColumn;
  final String searchKey;
  final String userId;

  Map<String, dynamic> toJson() {
    return {
      'intaskno': inTaskNo,
      'intaskid': inTaskId,
      'storeroomno': storeRoomNo,
      'forcesite': forceSite,
      'forcebatch': forceBatch,
      'taskcomment': taskComment,
      'taskFinishFlag': taskFinishFlag,
      'roomtag': roomTag,
      'workstation': workStation,
      'sortType': sortType,
      'sortColumn': sortColumn,
      'searchKey': searchKey,
      'userId': userId,
    };
  }

  @override
  List<Object?> get props => [
        inTaskNo,
        inTaskId,
        storeRoomNo,
        workStation,
        forceSite,
        forceBatch,
        taskComment,
        taskFinishFlag,
        roomTag,
        sortType,
        sortColumn,
        searchKey,
        userId,
      ];
}
