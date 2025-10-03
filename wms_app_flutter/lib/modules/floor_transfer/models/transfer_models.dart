import 'package:uuid/uuid.dart';

enum TransferMode {
  moveOut,
  moveIn,
}

enum TransferStep {
  sourceSite,
  targetSite,
  material,
  quantity,
  idle,
}

enum MaterialControl {
  serial,
  batch,
  none,
}

class StoreSiteInfo {
  StoreSiteInfo({
    required this.storeSiteNo,
    required this.storeRoomNo,
    required this.isFrozen,
    this.erpStoreRoom,
    this.erpOwnerCode,
  });

  factory StoreSiteInfo.fromJson(Map<String, dynamic> json) {
    return StoreSiteInfo(
      storeSiteNo: json['storeSiteNo']?.toString() ?? json['storesiteno']?.toString() ?? '',
      storeRoomNo: json['storeRoomNo']?.toString() ?? json['storeroomno']?.toString() ?? '',
      isFrozen: json['isfrozen']?.toString() ?? json['isFrozen']?.toString() ?? '0',
      erpStoreRoom: json['erpStoreroom']?.toString() ?? json['erpStoreRoom']?.toString(),
      erpOwnerCode: json['erpOwnerCode']?.toString() ?? json['erpownercode']?.toString(),
    );
  }

  final String storeSiteNo;
  final String storeRoomNo;
  final String isFrozen;
  final String? erpStoreRoom;
  final String? erpOwnerCode;

  bool get isLocked => isFrozen != '0';
}

class InventoryStock {
  InventoryStock({
    required this.storeSiteNo,
    required this.materialCode,
    required this.materialName,
    required this.batchNo,
    required this.serialNo,
    required this.availableQty,
    required this.erpStoreRoom,
    required this.erpOwnerCode,
    required this.projectNum,
    required this.storeRoomNo,
    required this.storeRoomName,
    this.palletNo,
  });

  factory InventoryStock.fromJson(Map<String, dynamic> json) {
    double _double(Object? value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0;
    }

    return InventoryStock(
      storeSiteNo: json['storesiteno']?.toString() ?? json['storeSite']?.toString() ?? '',
      materialCode: json['matcode']?.toString() ?? json['materialCode']?.toString() ?? '',
      materialName: json['matname']?.toString() ?? json['materialName']?.toString() ?? '',
      batchNo: json['batchno']?.toString() ?? json['batchNo']?.toString() ?? '',
      serialNo: json['sn']?.toString() ?? json['serialNo']?.toString() ?? '',
      availableQty: _double(json['repqty'] ?? json['qty']),
      erpStoreRoom: json['erpStoreroom']?.toString() ?? json['erpRoom']?.toString() ?? '',
      erpOwnerCode: json['erpOwnerCode']?.toString() ?? json['supplier']?.toString() ?? '',
      projectNum: json['projectNum']?.toString() ?? json['projectnum']?.toString() ?? '',
      storeRoomNo: json['storeroomno']?.toString() ?? json['storeRoomNo']?.toString() ?? '',
      storeRoomName: json['storeroomname']?.toString() ?? json['storeRoomName']?.toString() ?? '',
      palletNo: json['palletno']?.toString() ?? json['palletNo']?.toString(),
    );
  }

  final String storeSiteNo;
  final String materialCode;
  final String materialName;
  final String batchNo;
  final String serialNo;
  final double availableQty;
  final String erpStoreRoom;
  final String erpOwnerCode;
  final String projectNum;
  final String storeRoomNo;
  final String storeRoomName;
  final String? palletNo;

  Map<String, dynamic> toJson() => {
        'storesiteno': storeSiteNo,
        'matcode': materialCode,
        'matname': materialName,
        'batchno': batchNo,
        'sn': serialNo,
        'repqty': availableQty,
        'erpStoreroom': erpStoreRoom,
        'erpOwnerCode': erpOwnerCode,
        'projectNum': projectNum,
        'storeroomno': storeRoomNo,
        'storeroomname': storeRoomName,
        if (palletNo != null) 'palletno': palletNo,
      };

  bool matchesKey(String sourceSite, String materialCode, String batch, String erpRoom, String project) {
    return storeSiteNo == sourceSite &&
        this.materialCode == materialCode &&
        (batch.isEmpty || batchNo == batch) &&
        (erpRoom.isEmpty || erpStoreRoom == erpRoom) &&
        (project.isEmpty || projectNum == project);
  }
}

class TransferRecord {
  TransferRecord({
    String? id,
    required this.sourceSite,
    required this.targetSite,
    required this.materialCode,
    required this.materialName,
    required this.batchNo,
    required this.serialNo,
    required this.quantity,
    required this.erpStoreRoom,
    required this.erpOwnerCode,
    required this.projectNum,
    required this.mode,
  }) : id = id ?? const Uuid().v4();

  final String id;
  final String sourceSite;
  final String targetSite;
  final String materialCode;
  final String materialName;
  final String batchNo;
  final String serialNo;
  final double quantity;
  final String erpStoreRoom;
  final String erpOwnerCode;
  final String projectNum;
  final TransferMode mode;

  Map<String, dynamic> toSubmissionJson() {
    return {
      'inSite': targetSite,
      'outSite': sourceSite,
      'materialCode': materialCode,
      'batchNo': batchNo,
      'sn': serialNo,
      'qty': quantity,
      'moveDesc': '',
      'supplier': erpOwnerCode,
      'erpRoom': erpStoreRoom,
      'projectNum': projectNum,
    };
  }
}

class TransferFilterResult {
  TransferFilterResult({
    required this.transferInfos,
    required this.filter,
  });

  final List<Map<String, dynamic>> transferInfos;
  final String filter;
}

class InventoryQueryPage {
  InventoryQueryPage({
    required this.rows,
    required this.total,
    required this.currentPage,
    required this.pageSize,
  });

  factory InventoryQueryPage.fromJson(Map<String, dynamic> json, int currentPage, int pageSize) {
    final rows = (json['rows'] as List<dynamic>? ?? const [])
        .map((e) => InventoryStock.fromJson(
              Map<String, dynamic>.from(e as Map<dynamic, dynamic>),
            ))
        .toList();
    final total = json['total'] is num
        ? (json['total'] as num).toInt()
        : int.tryParse('${json['total']}') ?? rows.length;
    return InventoryQueryPage(
      rows: rows,
      total: total,
      currentPage: currentPage,
      pageSize: pageSize,
    );
  }

  final List<InventoryStock> rows;
  final int total;
  final int currentPage;
  final int pageSize;

  int get totalPages {
    if (pageSize <= 0) return 1;
    final raw = total / pageSize;
    final computed = raw.ceil();
    return computed > 0 ? computed : 1;
  }
}
