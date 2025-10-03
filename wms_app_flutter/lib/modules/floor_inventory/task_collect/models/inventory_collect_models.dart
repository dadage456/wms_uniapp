import 'package:equatable/equatable.dart';

class InventoryCollectionRecord extends Equatable {
  const InventoryCollectionRecord({
    required this.taskComment,
    required this.taskNo,
    required this.invTaskItemId,
    required this.storeRoomNo,
    required this.storeSiteNo,
    required this.matCode,
    required this.matName,
    required this.collectQty,
    this.batchNo,
    this.sn,
    this.materialId,
  });

  factory InventoryCollectionRecord.fromJson(Map<String, dynamic> json) {
    final batchNo = json['batchno'] ?? json['batchNo'];
    final sn = json['sn'];
    final collectQtyRaw = json['collectQty'] ?? json['collectqty'] ?? json['InventoryQty'];
    return InventoryCollectionRecord(
      taskComment: json['taskcomment']?.toString() ?? json['TaskComment']?.toString() ?? '',
      taskNo: json['checktaskno']?.toString() ?? json['taskNo']?.toString() ?? '',
      invTaskItemId: json['co_checkitemid']?.toString() ?? json['invTaskItemid']?.toString() ?? '',
      storeRoomNo: json['storeroomno']?.toString() ?? json['storeRoomNo']?.toString() ?? '',
      storeSiteNo: json['storesite']?.toString() ?? json['storeSiteNo']?.toString() ?? json['storesiteno']?.toString() ?? '',
      matCode: json['matcode']?.toString() ?? json['matCode']?.toString() ?? '',
      matName: json['matname']?.toString() ?? json['matName']?.toString() ?? '',
      collectQty: double.tryParse(collectQtyRaw?.toString() ?? '') ?? 0,
      batchNo: batchNo?.toString(),
      sn: sn?.toString(),
      materialId: json['materialid']?.toString(),
    );
  }

  final String taskComment;
  final String taskNo;
  final String invTaskItemId;
  final String storeRoomNo;
  final String storeSiteNo;
  final String matCode;
  final String matName;
  final double collectQty;
  final String? batchNo;
  final String? sn;
  final String? materialId;

  InventoryCollectionRecord copyWith({
    double? collectQty,
  }) {
    return InventoryCollectionRecord(
      taskComment: taskComment,
      taskNo: taskNo,
      invTaskItemId: invTaskItemId,
      storeRoomNo: storeRoomNo,
      storeSiteNo: storeSiteNo,
      matCode: matCode,
      matName: matName,
      collectQty: collectQty ?? this.collectQty,
      batchNo: batchNo,
      sn: sn,
      materialId: materialId,
    );
  }

  Map<String, dynamic> toSubmitJson() {
    return {
      'TaskComment': taskComment,
      'matCode': matCode,
      'batchNo': batchNo ?? '',
      'sn': sn ?? '',
      'collectQty': collectQty,
      'storeRoomNo': storeRoomNo,
      'storeSiteNo': storeSiteNo,
      'invTaskItemid': invTaskItemId,
      'materialId': materialId ?? '',
    };
  }

  bool isSameTarget(InventoryCollectionRecord other) {
    return matCode == other.matCode &&
        (batchNo ?? '') == (other.batchNo ?? '') &&
        (sn ?? '') == (other.sn ?? '') &&
        storeSiteNo == other.storeSiteNo &&
        invTaskItemId == other.invTaskItemId;
  }

  @override
  List<Object?> get props => [
        taskComment,
        taskNo,
        invTaskItemId,
        storeRoomNo,
        storeSiteNo,
        matCode,
        matName,
        collectQty,
        batchNo,
        sn,
        materialId,
      ];
}

class InventoryCollectionListData {
  InventoryCollectionListData({required this.rows});

  factory InventoryCollectionListData.fromJson(Map<String, dynamic> json) {
    final list = json['rows'];
    if (list is List) {
      return InventoryCollectionListData(
        rows: list
            .map(
              (e) => InventoryCollectionRecord.fromJson(
                Map<String, dynamic>.from(e as Map<dynamic, dynamic>),
              ),
            )
            .toList(),
      );
    }

    return InventoryCollectionListData(rows: const []);
  }

  final List<InventoryCollectionRecord> rows;
}

class InventoryMaterialInfo extends Equatable {
  const InventoryMaterialInfo({
    required this.matCode,
    required this.matName,
    required this.batchNo,
    required this.sn,
    required this.seqCtrl,
    required this.materialId,
    this.idOld,
  });

  factory InventoryMaterialInfo.fromJson(Map<String, dynamic> json) {
    return InventoryMaterialInfo(
      matCode: json['matcode']?.toString() ?? json['matCode']?.toString() ?? '',
      matName: json['matname']?.toString() ?? json['matName']?.toString() ?? '',
      batchNo: json['batchno']?.toString() ?? json['batchNo']?.toString() ?? '',
      sn: json['sn']?.toString() ?? '',
      seqCtrl: json['seqctrl']?.toString() ?? json['seqCtrl']?.toString() ?? '',
      materialId: json['materialid']?.toString() ?? json['materialId']?.toString() ?? '',
      idOld: json['id_old']?.toString(),
    );
  }

  final String matCode;
  final String matName;
  final String batchNo;
  final String sn;
  final String seqCtrl;
  final String materialId;
  final String? idOld;

  bool get isSerialControl => seqCtrl == '0';

  @override
  List<Object?> get props => [
        matCode,
        matName,
        batchNo,
        sn,
        seqCtrl,
        materialId,
        idOld,
      ];
}

class InventoryStoreSiteInfo extends Equatable {
  const InventoryStoreSiteInfo({
    required this.storeRoomNo,
    required this.storeSiteNo,
    required this.isFrozen,
  });

  factory InventoryStoreSiteInfo.fromJson(Map<String, dynamic> json) {
    return InventoryStoreSiteInfo(
      storeRoomNo: json['storeroomno']?.toString() ?? json['storeRoomNo']?.toString() ?? '',
      storeSiteNo: json['storesiteno']?.toString() ?? json['storeSiteNo']?.toString() ?? json['storesite']?.toString() ?? '',
      isFrozen: json['isfrozen']?.toString() ?? json['isFrozen']?.toString() ?? '',
    );
  }

  final String storeRoomNo;
  final String storeSiteNo;
  final String isFrozen;

  bool get isAvailable => isFrozen != '1' && isFrozen != 'Y';

  @override
  List<Object?> get props => [storeRoomNo, storeSiteNo, isFrozen];
}

class InventoryStockInfo extends Equatable {
  const InventoryStockInfo({
    required this.stockId,
    required this.matCode,
    required this.batchNo,
    required this.sn,
    required this.taskQty,
    required this.collectQty,
    required this.storeRoomNo,
    required this.storeSiteNo,
  });

  factory InventoryStockInfo.fromJson(Map<String, dynamic> json) {
    return InventoryStockInfo(
      stockId: json['stockid']?.toString() ?? json['stockId']?.toString() ?? '',
      matCode: json['matcode']?.toString() ?? json['matCode']?.toString() ?? '',
      batchNo: json['batchno']?.toString() ?? json['batchNo']?.toString() ?? '',
      sn: json['sn']?.toString() ?? '',
      taskQty: double.tryParse(json['taskQty']?.toString() ?? json['taskqty']?.toString() ?? '') ?? 0,
      collectQty: double.tryParse(json['collectQty']?.toString() ?? json['collectqty']?.toString() ?? '') ?? 0,
      storeRoomNo: json['storeroomno']?.toString() ?? json['storeRoomNo']?.toString() ?? '',
      storeSiteNo: json['storesiteno']?.toString() ?? json['storeSiteNo']?.toString() ?? json['storesite']?.toString() ?? '',
    );
  }

  final String stockId;
  final String matCode;
  final String batchNo;
  final String sn;
  final double taskQty;
  final double collectQty;
  final String storeRoomNo;
  final String storeSiteNo;

  @override
  List<Object?> get props => [
        stockId,
        matCode,
        batchNo,
        sn,
        taskQty,
        collectQty,
        storeRoomNo,
        storeSiteNo,
      ];
}
