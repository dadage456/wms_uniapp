import 'package:equatable/equatable.dart';

class InboundTaskItem extends Equatable {
  const InboundTaskItem({
    required this.itemId,
    required this.inTaskId,
    required this.inTaskNo,
    required this.matCode,
    required this.matName,
    required this.batchNo,
    required this.storeSiteNo,
    required this.storeRoomNo,
    required this.planQty,
    required this.collectedQty,
    required this.inventoryQty,
    this.sn,
    this.subInventoryCode,
    this.orderNo,
    this.supplierName,
    this.trayNo,
  });

  factory InboundTaskItem.fromJson(Map<String, dynamic> json) {
    return InboundTaskItem(
      itemId: (json['intaskitemid'] ?? json['itemId']).toString(),
      inTaskId: (json['intaskid'] ?? json['inTaskId']).toString(),
      inTaskNo: json['intaskno']?.toString() ?? '',
      matCode: json['matcode']?.toString() ?? '',
      matName: json['matname']?.toString() ?? '',
      batchNo: json['batchno']?.toString() ?? '',
      storeSiteNo: json['storesiteno']?.toString() ?? json['storeSite']?.toString() ?? '',
      storeRoomNo: json['storeroomno']?.toString() ?? '',
      planQty: double.tryParse(json['hintqty']?.toString() ?? '') ??
          double.tryParse(json['planqty']?.toString() ?? '') ?? 0,
      collectedQty: double.tryParse(json['collectedqty']?.toString() ?? '') ?? 0,
      inventoryQty: double.tryParse(json['repqty']?.toString() ?? '') ?? 0,
      sn: json['sn']?.toString(),
      subInventoryCode: json['subinventorycode']?.toString(),
      orderNo: json['orderno']?.toString(),
      supplierName: json['parname']?.toString(),
      trayNo: json['trayno']?.toString(),
    );
  }

  final String itemId;
  final String inTaskId;
  final String inTaskNo;
  final String matCode;
  final String matName;
  final String batchNo;
  final String storeSiteNo;
  final String storeRoomNo;
  final double planQty;
  final double collectedQty;
  final double inventoryQty;
  final String? sn;
  final String? subInventoryCode;
  final String? orderNo;
  final String? supplierName;
  final String? trayNo;

  InboundTaskItem copyWith({
    String? itemId,
    String? inTaskId,
    String? inTaskNo,
    String? matCode,
    String? matName,
    String? batchNo,
    String? storeSiteNo,
    String? storeRoomNo,
    double? planQty,
    double? collectedQty,
    double? inventoryQty,
    String? sn,
    String? subInventoryCode,
    String? orderNo,
    String? supplierName,
    String? trayNo,
  }) {
    return InboundTaskItem(
      itemId: itemId ?? this.itemId,
      inTaskId: inTaskId ?? this.inTaskId,
      inTaskNo: inTaskNo ?? this.inTaskNo,
      matCode: matCode ?? this.matCode,
      matName: matName ?? this.matName,
      batchNo: batchNo ?? this.batchNo,
      storeSiteNo: storeSiteNo ?? this.storeSiteNo,
      storeRoomNo: storeRoomNo ?? this.storeRoomNo,
      planQty: planQty ?? this.planQty,
      collectedQty: collectedQty ?? this.collectedQty,
      inventoryQty: inventoryQty ?? this.inventoryQty,
      sn: sn ?? this.sn,
      subInventoryCode: subInventoryCode ?? this.subInventoryCode,
      orderNo: orderNo ?? this.orderNo,
      supplierName: supplierName ?? this.supplierName,
      trayNo: trayNo ?? this.trayNo,
    );
  }

  @override
  List<Object?> get props => [
        itemId,
        inTaskId,
        inTaskNo,
        matCode,
        matName,
        batchNo,
        storeSiteNo,
        storeRoomNo,
        planQty,
        collectedQty,
        inventoryQty,
        sn,
        subInventoryCode,
        orderNo,
        supplierName,
        trayNo,
      ];
}

class InboundTaskItemListData {
  InboundTaskItemListData({required this.total, required this.rows});

  factory InboundTaskItemListData.fromJson(Map<String, dynamic> json) {
    final rows = (json['rows'] as List<dynamic>? ?? [])
        .map((item) => InboundTaskItem.fromJson(item as Map<String, dynamic>))
        .toList();
    final total = json['total'] is int
        ? json['total'] as int
        : int.tryParse(json['total']?.toString() ?? '') ?? rows.length;
    return InboundTaskItemListData(total: total, rows: rows);
  }

  final int total;
  final List<InboundTaskItem> rows;
}

class InboundTaskItemQuery extends Equatable {
  const InboundTaskItemQuery({
    required this.inTaskId,
    required this.workStation,
    this.searchKey = '',
    this.roomTag = '0',
    this.pageIndex = 0,
    this.pageSize = 100,
  });

  final String inTaskId;
  final String workStation;
  final String searchKey;
  final String roomTag;
  final int pageIndex;
  final int pageSize;

  Map<String, dynamic> toJson() {
    return {
      'intaskid': inTaskId,
      'workstation': workStation,
      'searchKey': searchKey,
      'roomTag': roomTag,
      'PageIndex': (pageIndex + 1).toString(),
      'PageSize': pageSize.toString(),
    };
  }

  InboundTaskItemQuery copyWith({
    String? searchKey,
    int? pageIndex,
    int? pageSize,
  }) {
    return InboundTaskItemQuery(
      inTaskId: inTaskId,
      workStation: workStation,
      searchKey: searchKey ?? this.searchKey,
      roomTag: roomTag,
      pageIndex: pageIndex ?? this.pageIndex,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  List<Object?> get props => [inTaskId, workStation, searchKey, roomTag, pageIndex, pageSize];
}
