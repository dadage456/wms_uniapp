import 'package:equatable/equatable.dart';

/// 到货单明细
class ArrivalTaskDetail extends Equatable {
  const ArrivalTaskDetail({
    required this.detailId,
    required this.materialCode,
    required this.materialName,
    required this.batchNo,
    required this.serialNo,
    required this.planQty,
    required this.collectedQty,
    required this.storeRoom,
    required this.subInventory,
    required this.sapLineNo,
    required this.supplierName,
    required this.controlMode,
    required this.orderNo,
    required this.arrivalsBillNo,
  });

  factory ArrivalTaskDetail.fromJson(Map<String, dynamic> json) {
    return ArrivalTaskDetail(
      detailId: json['arrivalsDetailid']?.toString() ?? '',
      materialCode: json['matcode']?.toString() ?? '',
      materialName: json['matname']?.toString() ?? '',
      batchNo: json['batchno']?.toString() ?? '',
      serialNo: json['sn']?.toString() ?? '',
      planQty: double.tryParse(json['qty']?.toString() ?? '') ?? 0,
      collectedQty: double.tryParse(json['goodqty']?.toString() ?? '') ?? 0,
      storeRoom: json['storeroomno']?.toString() ?? '',
      subInventory: json['subinventoryCode']?.toString() ?? '',
      sapLineNo: json['posnr']?.toString() ?? '',
      supplierName: json['parname']?.toString() ?? '',
      controlMode: json['matcodecontrol']?.toString() ?? '',
      orderNo: json['orderno']?.toString() ?? '',
      arrivalsBillNo: json['arrivalsBillno']?.toString() ?? '',
    );
  }

  final String detailId;
  final String materialCode;
  final String materialName;
  final String batchNo;
  final String serialNo;
  final double planQty;
  final double collectedQty;
  final String storeRoom;
  final String subInventory;
  final String sapLineNo;
  final String supplierName;
  final String controlMode;
  final String orderNo;
  final String arrivalsBillNo;

  ArrivalTaskDetail copyWith({double? collectedQty}) {
    return ArrivalTaskDetail(
      detailId: detailId,
      materialCode: materialCode,
      materialName: materialName,
      batchNo: batchNo,
      serialNo: serialNo,
      planQty: planQty,
      collectedQty: collectedQty ?? this.collectedQty,
      storeRoom: storeRoom,
      subInventory: subInventory,
      sapLineNo: sapLineNo,
      supplierName: supplierName,
      controlMode: controlMode,
      orderNo: orderNo,
      arrivalsBillNo: arrivalsBillNo,
    );
  }

  @override
  List<Object?> get props => [
        detailId,
        materialCode,
        materialName,
        batchNo,
        serialNo,
        planQty,
        collectedQty,
        storeRoom,
        subInventory,
        sapLineNo,
        supplierName,
        controlMode,
        orderNo,
        arrivalsBillNo,
      ];
}

class ArrivalTaskDetailListData {
  ArrivalTaskDetailListData({required this.total, required this.rows});

  factory ArrivalTaskDetailListData.fromJson(Map<String, dynamic> json) {
    final rows = (json['rows'] as List<dynamic>? ?? [])
        .map((item) => ArrivalTaskDetail.fromJson(
              Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
            ))
        .toList();
    final total = json['total'] is int
        ? json['total'] as int
        : int.tryParse(json['total']?.toString() ?? '') ?? rows.length;
    return ArrivalTaskDetailListData(total: total, rows: rows);
  }

  final int total;
  final List<ArrivalTaskDetail> rows;
}

class ArrivalTaskDetailQuery extends Equatable {
  const ArrivalTaskDetailQuery({
    required this.arrivalsBillId,
    this.sortType = 'desc',
    this.sortColumn = 'matcode',
    this.searchKey = '',
    this.pageIndex = 1,
    this.pageSize = 100,
  });

  final String arrivalsBillId;
  final String sortType;
  final String sortColumn;
  final String searchKey;
  final int pageIndex;
  final int pageSize;

  Map<String, dynamic> toJson() {
    return {
      'arrivalsBillid': arrivalsBillId,
      'sortType': sortType,
      'sortColumn': sortColumn,
      'searchKey': searchKey,
      'PageIndex': pageIndex.toString(),
      'PageSize': pageSize.toString(),
    };
  }

  ArrivalTaskDetailQuery copyWith({
    String? arrivalsBillId,
    String? sortType,
    String? sortColumn,
    String? searchKey,
    int? pageIndex,
    int? pageSize,
  }) {
    return ArrivalTaskDetailQuery(
      arrivalsBillId: arrivalsBillId ?? this.arrivalsBillId,
      sortType: sortType ?? this.sortType,
      sortColumn: sortColumn ?? this.sortColumn,
      searchKey: searchKey ?? this.searchKey,
      pageIndex: pageIndex ?? this.pageIndex,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  List<Object?> get props => [
        arrivalsBillId,
        sortType,
        sortColumn,
        searchKey,
        pageIndex,
        pageSize,
      ];
}
