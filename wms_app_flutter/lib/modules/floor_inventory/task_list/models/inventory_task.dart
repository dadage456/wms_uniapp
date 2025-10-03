import 'package:equatable/equatable.dart';

class InventoryTask extends Equatable {
  const InventoryTask({
    required this.taskComment,
    required this.storeRoomNo,
    required this.storeRoomName,
    required this.taskNo,
    required this.checkMethod,
    required this.createdDate,
  });

  factory InventoryTask.fromJson(Map<String, dynamic> json) {
    return InventoryTask(
      taskComment: json['taskcomment']?.toString() ?? '',
      storeRoomNo: json['storeroomno']?.toString() ?? '',
      storeRoomName: json['storeroomname']?.toString() ?? '',
      taskNo: json['checktaskno']?.toString() ?? '',
      checkMethod: json['checkmethod_nm']?.toString() ?? '',
      createdDate: json['createdate']?.toString() ?? '',
    );
  }

  final String taskComment;
  final String storeRoomNo;
  final String storeRoomName;
  final String taskNo;
  final String checkMethod;
  final String createdDate;

  @override
  List<Object?> get props => [
        taskComment,
        storeRoomNo,
        storeRoomName,
        taskNo,
        checkMethod,
        createdDate,
      ];
}

class InventoryTaskListData {
  InventoryTaskListData({required this.total, required this.rows});

  factory InventoryTaskListData.fromJson(Map<String, dynamic> json) {
    final rows = (json['rows'] as List<dynamic>? ?? [])
        .map((item) => InventoryTask.fromJson(
              Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
            ))
        .toList();
    final total = json['total'] is int
        ? json['total'] as int
        : int.tryParse(json['total']?.toString() ?? '') ?? rows.length;
    return InventoryTaskListData(total: total, rows: rows);
  }

  final int total;
  final List<InventoryTask> rows;
}

class InventoryTaskQuery extends Equatable {
  const InventoryTaskQuery({
    required this.userId,
    required this.roleOrUserId,
    this.roomTag = '0',
    this.sortType = 'desc',
    this.sortColumn = 'createdate',
    this.searchKey = '',
    this.pageIndex = 1,
    this.pageSize = 100,
  });

  final String userId;
  final String roleOrUserId;
  final String roomTag;
  final String sortType;
  final String sortColumn;
  final String searchKey;
  final int pageIndex;
  final int pageSize;

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'roleoRuserId': roleOrUserId,
      'roomTag': roomTag,
      'sortType': sortType,
      'sortColumn': sortColumn,
      'searchKey': searchKey,
      'PageIndex': pageIndex.toString(),
      'PageSize': pageSize.toString(),
    };
  }

  InventoryTaskQuery copyWith({
    String? userId,
    String? roleOrUserId,
    String? roomTag,
    String? sortType,
    String? sortColumn,
    String? searchKey,
    int? pageIndex,
    int? pageSize,
  }) {
    return InventoryTaskQuery(
      userId: userId ?? this.userId,
      roleOrUserId: roleOrUserId ?? this.roleOrUserId,
      roomTag: roomTag ?? this.roomTag,
      sortType: sortType ?? this.sortType,
      sortColumn: sortColumn ?? this.sortColumn,
      searchKey: searchKey ?? this.searchKey,
      pageIndex: pageIndex ?? this.pageIndex,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        roleOrUserId,
        roomTag,
        sortType,
        sortColumn,
        searchKey,
        pageIndex,
        pageSize,
      ];
}
