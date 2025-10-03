import 'package:equatable/equatable.dart';

class ExceptionTaskRecord extends Equatable {
  const ExceptionTaskRecord({
    required this.dcConnectId,
    required this.connectNo,
    required this.handleStatus,
    required this.handleTime,
    required this.operatorName,
    required this.errorMessage,
    required this.taskNo,
    required this.proofNo,
    required this.collectorType,
    required this.businessKind,
    required this.palletNo,
    required this.taskId,
    required this.storeRoom,
    required this.proType,
  });

  factory ExceptionTaskRecord.fromJson(Map<String, dynamic> json) {
    return ExceptionTaskRecord(
      dcConnectId: json['dcConnectid']?.toString() ?? '',
      connectNo: json['dcConnectno']?.toString() ?? '',
      handleStatus: json['constateName']?.toString() ?? '',
      handleTime: json['contime']?.toString() ?? '',
      operatorName: json['cname']?.toString() ?? '',
      errorMessage: json['data5']?.toString() ?? '',
      taskNo: json['taskno']?.toString() ?? '',
      proofNo: json['proofno']?.toString() ?? '',
      collectorType: json['collectortype']?.toString() ?? '',
      businessKind: json['businesskind']?.toString() ?? '',
      palletNo: json['palletno']?.toString() ?? '',
      taskId: json['taskid']?.toString() ?? '',
      storeRoom: json['storeroomno']?.toString() ?? '',
      proType: json['protype']?.toString() ?? '',
    );
  }

  final String dcConnectId;
  final String connectNo;
  final String handleStatus;
  final String handleTime;
  final String operatorName;
  final String errorMessage;
  final String taskNo;
  final String proofNo;
  final String collectorType;
  final String businessKind;
  final String palletNo;
  final String taskId;
  final String storeRoom;
  final String proType;

  FloorExceptionTaskSummary toSummary() {
    return FloorExceptionTaskSummary(
      taskNo: taskNo,
      taskId: taskId,
      proofNo: proofNo,
      storeRoom: storeRoom,
      proType: proType,
      trayNo: palletNo,
    );
  }

  @override
  List<Object?> get props => [
        dcConnectId,
        connectNo,
        handleStatus,
        handleTime,
        operatorName,
        errorMessage,
        taskNo,
        proofNo,
        collectorType,
        businessKind,
        palletNo,
        taskId,
        storeRoom,
        proType,
      ];
}

class ExceptionTaskListData {
  ExceptionTaskListData({required this.total, required this.rows});

  factory ExceptionTaskListData.fromJson(Map<String, dynamic> json) {
    final rows = (json['rows'] as List<dynamic>? ?? [])
        .map((item) => ExceptionTaskRecord.fromJson(
              Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
            ))
        .toList();
    final total = json['total'] is int
        ? json['total'] as int
        : int.tryParse(json['total']?.toString() ?? '') ?? rows.length;
    return ExceptionTaskListData(total: total, rows: rows);
  }

  final int total;
  final List<ExceptionTaskRecord> rows;
}

class ExceptionTaskQuery extends Equatable {
  const ExceptionTaskQuery({
    required this.userId,
    required this.roleOrUserId,
    this.searchKey = '',
    this.sortType = 'desc',
    this.sortColumn = 'contime',
    this.roomTag = '0',
    this.transferType = '0',
    this.pageIndex = 1,
    this.pageSize = 100,
  });

  final String userId;
  final String roleOrUserId;
  final String searchKey;
  final String sortType;
  final String sortColumn;
  final String roomTag;
  final String transferType;
  final int pageIndex;
  final int pageSize;

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'roleoRuserId': roleOrUserId,
      'searchKey': searchKey,
      'sortType': sortType,
      'sortColumn': sortColumn,
      'roomTag': roomTag,
      'transferType': transferType,
      'PageIndex': pageIndex.toString(),
      'PageSize': pageSize.toString(),
    };
  }

  ExceptionTaskQuery copyWith({
    String? userId,
    String? roleOrUserId,
    String? searchKey,
    String? sortType,
    String? sortColumn,
    String? roomTag,
    String? transferType,
    int? pageIndex,
    int? pageSize,
  }) {
    return ExceptionTaskQuery(
      userId: userId ?? this.userId,
      roleOrUserId: roleOrUserId ?? this.roleOrUserId,
      searchKey: searchKey ?? this.searchKey,
      sortType: sortType ?? this.sortType,
      sortColumn: sortColumn ?? this.sortColumn,
      roomTag: roomTag ?? this.roomTag,
      transferType: transferType ?? this.transferType,
      pageIndex: pageIndex ?? this.pageIndex,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        roleOrUserId,
        searchKey,
        sortType,
        sortColumn,
        roomTag,
        transferType,
        pageIndex,
        pageSize,
      ];
}

class FloorExceptionTaskSummary extends Equatable {
  const FloorExceptionTaskSummary({
    this.taskNo = '',
    this.taskId = '',
    this.proofNo = '',
    this.storeRoom = '',
    this.proType = '',
    this.trayNo = '',
  });

  final String taskNo;
  final String taskId;
  final String proofNo;
  final String storeRoom;
  final String proType;
  final String trayNo;

  bool get hasTaskBinding => taskNo.isNotEmpty || taskId.isNotEmpty;

  @override
  List<Object?> get props => [taskNo, taskId, proofNo, storeRoom, proType, trayNo];
}
