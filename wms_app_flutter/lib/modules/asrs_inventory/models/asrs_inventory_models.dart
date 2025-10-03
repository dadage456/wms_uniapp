import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class AsrsInventoryTask extends Equatable {
  const AsrsInventoryTask({
    required this.taskId,
    required this.taskNo,
    required this.taskComment,
    required this.storeRoomNo,
    required this.storeRoomName,
    this.finishFlag = '0',
    this.createdDate,
  });

  factory AsrsInventoryTask.fromJson(Map<String, dynamic> json) {
    return AsrsInventoryTask(
      taskId: (json['checktaskid'] ?? json['taskId'] ?? '').toString(),
      taskNo: (json['checktaskno'] ?? json['taskNo'] ?? '').toString(),
      taskComment: (json['taskcomment'] ?? json['taskComment'] ?? '').toString(),
      storeRoomNo: (json['storeroomno'] ?? json['storeRoomNo'] ?? '').toString(),
      storeRoomName: (json['storeroomname'] ?? json['storeRoomName'] ?? '').toString(),
      finishFlag: (json['finshflg'] ?? json['finishFlag'] ?? '0').toString(),
      createdDate: json['createdate']?.toString(),
    );
  }

  final String taskId;
  final String taskNo;
  final String taskComment;
  final String storeRoomNo;
  final String storeRoomName;
  final String finishFlag;
  final String? createdDate;

  @override
  List<Object?> get props => [taskId, taskNo, taskComment, finishFlag];

  bool get isFinished => finishFlag == '1';
}

class AsrsInventoryTaskDetail extends Equatable {
  const AsrsInventoryTaskDetail({
    required this.taskItemId,
    required this.taskNo,
    required this.storeSiteNo,
    required this.trayNo,
    required this.materialCode,
    required this.materialName,
    required this.unit,
    this.batchNo,
    this.serialNo,
    this.taskQty = 0,
    this.collectedQty = 0,
    this.inventoryQty = 0,
    this.endAddress,
  });

  factory AsrsInventoryTaskDetail.fromJson(Map<String, dynamic> json) {
    double _parseNum(dynamic value) {
      if (value == null) return 0;
      return double.tryParse(value.toString()) ?? 0;
    }

    return AsrsInventoryTaskDetail(
      taskItemId: (json['checktaskitemid'] ?? json['taskItemId'] ?? '').toString(),
      taskNo: (json['checktaskno'] ?? json['taskNo'] ?? '').toString(),
      storeSiteNo: (json['storesiteno'] ?? json['storeSiteNo'] ?? '').toString(),
      trayNo: (json['palletno'] ?? json['trayNo'] ?? '').toString(),
      materialCode: (json['matcode'] ?? json['materialcode'] ?? json['materialCode'] ?? '').toString(),
      materialName: (json['matname'] ?? json['materialname'] ?? json['materialName'] ?? '').toString(),
      unit: (json['unit'] ?? json['unitName'] ?? 'EA').toString(),
      batchNo: json['batchno']?.toString(),
      serialNo: json['sn']?.toString(),
      taskQty: _parseNum(json['planqty'] ?? json['taskqty'] ?? json['planQty']),
      collectedQty: _parseNum(json['collectqty'] ?? json['collectedqty'] ?? json['collectQty']),
      inventoryQty: _parseNum(json['repertoryqty'] ?? json['repqty'] ?? json['inventoryQty']),
      endAddress: json['endaddr']?.toString(),
    );
  }

  final String taskItemId;
  final String taskNo;
  final String storeSiteNo;
  final String trayNo;
  final String materialCode;
  final String materialName;
  final String unit;
  final String? batchNo;
  final String? serialNo;
  final double taskQty;
  final double collectedQty;
  final double inventoryQty;
  final String? endAddress;

  @override
  List<Object?> get props => [taskItemId, materialCode, batchNo, serialNo];

  double get remainingQty => (taskQty - collectedQty).clamp(0, taskQty);
}

class AsrsInventoryTrayItem extends Equatable {
  const AsrsInventoryTrayItem({
    required this.trayNo,
    required this.materialCode,
    required this.materialName,
    this.batchNo,
    this.serialNo,
    this.quantity = 0,
  });

  factory AsrsInventoryTrayItem.fromJson(Map<String, dynamic> json) {
    double _parseNum(dynamic value) {
      if (value == null) return 0;
      return double.tryParse(value.toString()) ?? 0;
    }

    return AsrsInventoryTrayItem(
      trayNo: (json['trayno'] ?? json['palletno'] ?? '').toString(),
      materialCode: (json['matcode'] ?? json['materialcode'] ?? '').toString(),
      materialName: (json['matname'] ?? json['materialname'] ?? '').toString(),
      batchNo: json['batchno']?.toString(),
      serialNo: json['sn']?.toString(),
      quantity: _parseNum(json['qty'] ?? json['quantity']),
    );
  }

  final String trayNo;
  final String materialCode;
  final String materialName;
  final String? batchNo;
  final String? serialNo;
  final double quantity;

  @override
  List<Object?> get props => [trayNo, materialCode, batchNo, serialNo, quantity];
}

class AsrsInventoryCollectionRecord extends Equatable {
  AsrsInventoryCollectionRecord({
    required this.taskItemId,
    required this.storeSiteNo,
    required this.materialCode,
    required this.materialName,
    required this.quantity,
    required this.unit,
    this.batchNo,
    this.serialNo,
  }) : id = const Uuid().v4();

  final String id;
  final String taskItemId;
  final String storeSiteNo;
  final String materialCode;
  final String materialName;
  final double quantity;
  final String unit;
  final String? batchNo;
  final String? serialNo;

  Map<String, dynamic> toJson() {
    return {
      'checktaskitemid': taskItemId,
      'storesiteno': storeSiteNo,
      'matcode': materialCode,
      'matname': materialName,
      'qty': quantity,
      'unit': unit,
      if (batchNo != null && batchNo!.isNotEmpty) 'batchno': batchNo,
      if (serialNo != null && serialNo!.isNotEmpty) 'sn': serialNo,
    };
  }

  @override
  List<Object?> get props => [id, taskItemId, materialCode, batchNo, serialNo, quantity];
}

enum AsrsInventoryCommandType { down, reset }

class AsrsInventoryWcsCommand extends Equatable {
  const AsrsInventoryWcsCommand({
    required this.commandId,
    required this.taskNo,
    required this.trayNo,
    required this.startAddress,
    required this.endAddress,
    required this.commandType,
    this.status,
    this.createdTime,
  });

  factory AsrsInventoryWcsCommand.fromJson(Map<String, dynamic> json) {
    return AsrsInventoryWcsCommand(
      commandId: (json['commandid'] ?? json['id'] ?? '').toString(),
      taskNo: (json['taskno'] ?? json['taskNo'] ?? '').toString(),
      trayNo: (json['trayno'] ?? json['trayNo'] ?? '').toString(),
      startAddress: (json['startaddr'] ?? json['startAddr'] ?? '').toString(),
      endAddress: (json['endaddr'] ?? json['endAddr'] ?? '').toString(),
      commandType:
          (json['commandtype'] ?? json['commandType'] ?? '').toString().toUpperCase(),
      status: json['status']?.toString(),
      createdTime: json['createdate']?.toString() ?? json['createTime']?.toString(),
    );
  }

  final String commandId;
  final String taskNo;
  final String trayNo;
  final String startAddress;
  final String endAddress;
  final String commandType;
  final String? status;
  final String? createdTime;

  @override
  List<Object?> get props => [commandId, trayNo, startAddress, endAddress, commandType];
}
