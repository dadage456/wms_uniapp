import 'package:equatable/equatable.dart';

/// 平库上架任务模型
class InboundTask extends Equatable {
  const InboundTask({
    required this.inTaskId,
    required this.inTaskNo,
    required this.orderNo,
    required this.sourceOrderNo,
    required this.storeRoomNo,
    required this.workStation,
    required this.supplierName,
    required this.voucherNo,
    required this.batchFlag,
    required this.forceSite,
    required this.planQty,
    required this.finishQty,
    required this.status,
    this.createdTime,
  });

  factory InboundTask.fromJson(Map<String, dynamic> json) {
    return InboundTask(
      inTaskId: (json['intaskid'] ?? json['inTaskId']).toString(),
      inTaskNo: json['intaskno']?.toString() ?? '',
      orderNo: json['data2']?.toString() ?? json['orderNo']?.toString() ?? '',
      sourceOrderNo:
          json['data3']?.toString() ?? json['sourceOrderNo']?.toString() ?? '',
      storeRoomNo: json['storeroomno']?.toString() ?? '',
      workStation: json['workstation']?.toString() ?? '',
      supplierName: json['parname']?.toString() ?? json['supplierName']?.toString() ?? '',
      voucherNo: json['taskcomment']?.toString() ?? '',
      batchFlag: json['batchflag']?.toString() ?? json['batchFlag']?.toString() ?? 'N',
      forceSite: json['forcesite']?.toString() ?? json['forceSite']?.toString() ?? 'N',
      planQty: double.tryParse(json['planqty']?.toString() ?? '') ??
          double.tryParse(json['taskqty']?.toString() ?? '') ?? 0,
      finishQty: double.tryParse(json['finishqty']?.toString() ?? '') ?? 0,
      status: json['status']?.toString() ?? '',
      createdTime: json['createtime']?.toString(),
    );
  }

  final String inTaskId;
  final String inTaskNo;
  final String orderNo;
  final String sourceOrderNo;
  final String storeRoomNo;
  final String workStation;
  final String supplierName;
  final String voucherNo;
  final String batchFlag;
  final String forceSite;
  final double planQty;
  final double finishQty;
  final String status;
  final String? createdTime;

  @override
  List<Object?> get props => [
        inTaskId,
        inTaskNo,
        orderNo,
        sourceOrderNo,
        storeRoomNo,
        workStation,
        supplierName,
        voucherNo,
        batchFlag,
        forceSite,
        planQty,
        finishQty,
        status,
        createdTime,
      ];
}

/// 平库上架任务列表响应
class InboundTaskListData {
  InboundTaskListData({required this.total, required this.rows});

  factory InboundTaskListData.fromJson(Map<String, dynamic> json) {
    final rows = (json['rows'] as List<dynamic>? ?? [])
        .map((item) => InboundTask.fromJson(item as Map<String, dynamic>))
        .toList();
    final total = json['total'] is int
        ? json['total'] as int
        : int.tryParse(json['total']?.toString() ?? '') ?? rows.length;
    return InboundTaskListData(total: total, rows: rows);
  }

  final int total;
  final List<InboundTask> rows;
}

/// 平库上架任务列表查询参数
class InboundTaskQuery extends Equatable {
  const InboundTaskQuery({
    this.sortType = '',
    this.sortColumn = '',
    this.searchKey = '',
    required this.userId,
    required this.roleOrUserId,
    this.roomTag = '0',
    this.transferType = '0',
    this.finishFlag = '0',
    this.beatFlag = 'N',
    this.pageIndex = 0,
    this.pageSize = 100,
  });

  final String sortType;
  final String sortColumn;
  final String searchKey;
  final String userId;
  final String roleOrUserId;
  final String roomTag;
  final String transferType;
  final String finishFlag;
  final String beatFlag;
  final int pageIndex;
  final int pageSize;

  Map<String, dynamic> toJson() {
    return {
      'sortType': sortType,
      'sortColumn': sortColumn,
      'searchKey': searchKey,
      'userId': userId,
      'roleoRuserId': roleOrUserId,
      'roomTag': roomTag,
      'transferType': transferType,
      'beatflag': beatFlag,
      'PageIndex': (pageIndex + 1).toString(),
      'PageSize': pageSize.toString(),
      'finishFlag': finishFlag,
    };
  }

  InboundTaskQuery copyWith({
    String? sortType,
    String? sortColumn,
    String? searchKey,
    String? userId,
    String? roleOrUserId,
    String? roomTag,
    String? transferType,
    String? finishFlag,
    String? beatFlag,
    int? pageIndex,
    int? pageSize,
  }) {
    return InboundTaskQuery(
      sortType: sortType ?? this.sortType,
      sortColumn: sortColumn ?? this.sortColumn,
      searchKey: searchKey ?? this.searchKey,
      userId: userId ?? this.userId,
      roleOrUserId: roleOrUserId ?? this.roleOrUserId,
      roomTag: roomTag ?? this.roomTag,
      transferType: transferType ?? this.transferType,
      finishFlag: finishFlag ?? this.finishFlag,
      beatFlag: beatFlag ?? this.beatFlag,
      pageIndex: pageIndex ?? this.pageIndex,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  List<Object?> get props => [
        sortType,
        sortColumn,
        searchKey,
        userId,
        roleOrUserId,
        roomTag,
        transferType,
        finishFlag,
        beatFlag,
        pageIndex,
        pageSize,
      ];
}
