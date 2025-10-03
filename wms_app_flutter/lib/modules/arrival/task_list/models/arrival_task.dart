import 'package:equatable/equatable.dart';

/// 到货单任务信息
class ArrivalTask extends Equatable {
  const ArrivalTask({
    required this.arrivalsBillId,
    required this.arrivalsBillNo,
    required this.orderNo,
    required this.poNumber,
    required this.createDate,
    required this.factory,
    required this.supplierName,
    required this.planQty,
    required this.collectedQty,
  });

  factory ArrivalTask.fromJson(Map<String, dynamic> json) {
    final planQty = double.tryParse(json['qty']?.toString() ?? '') ?? 0;
    final collectedQty = double.tryParse(json['goodqty']?.toString() ?? '') ?? 0;

    return ArrivalTask(
      arrivalsBillId: json['arrivalsBillid']?.toString() ?? '',
      arrivalsBillNo: json['arrivalsBillno']?.toString() ?? '',
      orderNo: json['orderno']?.toString() ?? '',
      poNumber: json['poNumber']?.toString() ?? '',
      createDate: json['createdate']?.toString() ?? '',
      factory: json['werks']?.toString() ?? '',
      supplierName: json['parname']?.toString() ?? '',
      planQty: planQty,
      collectedQty: collectedQty,
    );
  }

  final String arrivalsBillId;
  final String arrivalsBillNo;
  final String orderNo;
  final String poNumber;
  final String createDate;
  final String factory;
  final String supplierName;
  final double planQty;
  final double collectedQty;

  @override
  List<Object?> get props => [
        arrivalsBillId,
        arrivalsBillNo,
        orderNo,
        poNumber,
        createDate,
        factory,
        supplierName,
        planQty,
        collectedQty,
      ];
}

/// 到货任务列表数据
class ArrivalTaskListData {
  ArrivalTaskListData({required this.total, required this.rows});

  factory ArrivalTaskListData.fromJson(Map<String, dynamic> json) {
    final rows = (json['rows'] as List<dynamic>? ?? [])
        .map((item) => ArrivalTask.fromJson(
              Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
            ))
        .toList();
    final total = json['total'] is int
        ? json['total'] as int
        : int.tryParse(json['total']?.toString() ?? '') ?? rows.length;
    return ArrivalTaskListData(total: total, rows: rows);
  }

  final int total;
  final List<ArrivalTask> rows;
}

/// 到货任务查询参数
class ArrivalTaskQuery extends Equatable {
  const ArrivalTaskQuery({
    this.sortType = 'desc',
    this.sortColumn = 'createdate',
    this.searchKey = '',
    this.pageIndex = 1,
    this.pageSize = 100,
  });

  final String sortType;
  final String sortColumn;
  final String searchKey;
  final int pageIndex;
  final int pageSize;

  Map<String, dynamic> toJson() {
    return {
      'sortType': sortType,
      'sortColumn': sortColumn,
      'searchKey': searchKey,
      'PageIndex': pageIndex.toString(),
      'PageSize': pageSize.toString(),
    };
  }

  ArrivalTaskQuery copyWith({
    String? sortType,
    String? sortColumn,
    String? searchKey,
    int? pageIndex,
    int? pageSize,
  }) {
    return ArrivalTaskQuery(
      sortType: sortType ?? this.sortType,
      sortColumn: sortColumn ?? this.sortColumn,
      searchKey: searchKey ?? this.searchKey,
      pageIndex: pageIndex ?? this.pageIndex,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  List<Object?> get props => [sortType, sortColumn, searchKey, pageIndex, pageSize];
}
