import 'package:equatable/equatable.dart';

class InventoryTaskDetail extends Equatable {
  const InventoryTaskDetail({
    required this.detailId,
    required this.taskNo,
    required this.storeSite,
    required this.storeRoomNo,
    required this.materialCode,
    required this.materialName,
    required this.batchNo,
    required this.serialNo,
    required this.planQty,
    required this.collectedQty,
    required this.checkMethod,
  });

  factory InventoryTaskDetail.fromJson(Map<String, dynamic> json) {
    return InventoryTaskDetail(
      detailId: json['co_checkitemid']?.toString() ?? '',
      taskNo: json['checktaskno']?.toString() ?? '',
      storeSite: json['storesite']?.toString() ?? '',
      storeRoomNo: json['storeroomno']?.toString() ?? '',
      materialCode: json['matcode']?.toString() ?? '',
      materialName: json['matname']?.toString() ?? '',
      batchNo: json['batchno']?.toString() ?? '',
      serialNo: json['sn']?.toString() ?? '',
      planQty: double.tryParse(json['collectdataqty']?.toString() ?? '') ?? 0,
      collectedQty: double.tryParse(json['goodqty']?.toString() ?? '') ?? 0,
      checkMethod: json['checkmethod_nm']?.toString() ?? '',
    );
  }

  final String detailId;
  final String taskNo;
  final String storeSite;
  final String storeRoomNo;
  final String materialCode;
  final String materialName;
  final String batchNo;
  final String serialNo;
  final double planQty;
  final double collectedQty;
  final String checkMethod;

  InventoryTaskDetail copyWith({
    double? planQty,
    double? collectedQty,
  }) {
    return InventoryTaskDetail(
      detailId: detailId,
      taskNo: taskNo,
      storeSite: storeSite,
      storeRoomNo: storeRoomNo,
      materialCode: materialCode,
      materialName: materialName,
      batchNo: batchNo,
      serialNo: serialNo,
      planQty: planQty ?? this.planQty,
      collectedQty: collectedQty ?? this.collectedQty,
      checkMethod: checkMethod,
    );
  }

  @override
  List<Object?> get props => [
        detailId,
        taskNo,
        storeSite,
        storeRoomNo,
        materialCode,
        materialName,
        batchNo,
        serialNo,
        planQty,
        collectedQty,
        checkMethod,
      ];
}

class InventoryTaskDetailListData {
  InventoryTaskDetailListData({required this.total, required this.rows});

  factory InventoryTaskDetailListData.fromJson(Map<String, dynamic> json) {
    final rows = (json['rows'] as List<dynamic>? ?? [])
        .map((item) => InventoryTaskDetail.fromJson(
              Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
            ))
        .toList();
    final total = json['total'] is int
        ? json['total'] as int
        : int.tryParse(json['total']?.toString() ?? '') ?? rows.length;
    return InventoryTaskDetailListData(total: total, rows: rows);
  }

  final int total;
  final List<InventoryTaskDetail> rows;
}

class InventoryTaskDetailQuery extends Equatable {
  const InventoryTaskDetailQuery({
    required this.taskComment,
    required this.taskNo,
    this.roomTag = '0',
    this.pageIndex = 1,
    this.pageSize = 200,
  });

  final String taskComment;
  final String taskNo;
  final String roomTag;
  final int pageIndex;
  final int pageSize;

  Map<String, dynamic> toJson() {
    return {
      'taskComment': taskComment,
      'taskNo': taskNo,
      'roomTag': roomTag,
      'PageIndex': pageIndex.toString(),
      'PageSize': pageSize.toString(),
    };
  }

  InventoryTaskDetailQuery copyWith({
    String? taskComment,
    String? taskNo,
    String? roomTag,
    int? pageIndex,
    int? pageSize,
  }) {
    return InventoryTaskDetailQuery(
      taskComment: taskComment ?? this.taskComment,
      taskNo: taskNo ?? this.taskNo,
      roomTag: roomTag ?? this.roomTag,
      pageIndex: pageIndex ?? this.pageIndex,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  List<Object?> get props => [taskComment, taskNo, roomTag, pageIndex, pageSize];
}

