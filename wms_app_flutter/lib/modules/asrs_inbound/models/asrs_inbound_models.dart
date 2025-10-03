import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class AsrsInboundTask extends Equatable {
  const AsrsInboundTask({
    required this.taskId,
    required this.taskNo,
    required this.taskComment,
    required this.workstation,
    required this.storeRoomName,
    required this.status,
    required this.projectNum,
    required this.batchFlag,
    required this.beatFlag,
    required this.trayQty,
  });

  factory AsrsInboundTask.fromJson(Map<String, dynamic> json) {
    String _string(Object? value) => value?.toString() ?? '';
    double _double(Object? value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0;
    }

    return AsrsInboundTask(
      taskId: _string(json['intaskid'] ?? json['taskId']),
      taskNo: _string(json['intaskno'] ?? json['taskNo']),
      taskComment: _string(json['taskcomment'] ?? json['taskComment']),
      workstation: _string(json['workstation'] ?? json['station']),
      storeRoomName: _string(json['storeroomname'] ?? json['storeRoomName']),
      status: _string(json['status'] ?? json['taskStatus']),
      projectNum: _string(json['projectnum'] ?? json['projectNum']),
      batchFlag: _string(json['batchflag'] ?? json['batchFlag']),
      beatFlag: _string(json['beatflag'] ?? json['beatFlag']),
      trayQty: _double(json['trayqty'] ?? json['trayQty']),
    );
  }

  final String taskId;
  final String taskNo;
  final String taskComment;
  final String workstation;
  final String storeRoomName;
  final String status;
  final String projectNum;
  final String batchFlag;
  final String beatFlag;
  final double trayQty;

  String get title => taskComment.isNotEmpty ? taskComment : taskNo;

  @override
  List<Object?> get props => [
        taskId,
        taskNo,
        taskComment,
        workstation,
        storeRoomName,
        status,
        projectNum,
        batchFlag,
        beatFlag,
        trayQty,
      ];
}

class AsrsInboundTaskDetail extends Equatable {
  const AsrsInboundTaskDetail({
    required this.taskItemId,
    required this.taskId,
    required this.taskNo,
    required this.materialCode,
    required this.materialName,
    required this.batchNo,
    required this.serialNo,
    required this.storeSiteNo,
    required this.unit,
    required this.taskQty,
    required this.collectedQty,
    required this.palletNo,
  });

  factory AsrsInboundTaskDetail.fromJson(Map<String, dynamic> json) {
    String _string(Object? value) => value?.toString() ?? '';
    double _double(Object? value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0;
    }

    return AsrsInboundTaskDetail(
      taskItemId: _string(json['intaskitemid'] ?? json['taskItemId']),
      taskId: _string(json['intaskid'] ?? json['taskId']),
      taskNo: _string(json['intaskno'] ?? json['taskNo']),
      materialCode: _string(json['matcode'] ?? json['materialCode']),
      materialName: _string(json['matname'] ?? json['materialName']),
      batchNo: _string(json['batchno'] ?? json['batchNo']),
      serialNo: _string(json['sn'] ?? json['serialNo']),
      storeSiteNo: _string(json['storesiteno'] ?? json['storeSiteNo']),
      unit: _string(json['unit'] ?? json['uom']),
      taskQty: _double(json['taskqty'] ?? json['qty'] ?? json['taskQty']),
      collectedQty:
          _double(json['collectqty'] ?? json['collectedQty'] ?? json['commitQty']),
      palletNo: _string(json['palletno'] ?? json['palletNo']),
    );
  }

  final String taskItemId;
  final String taskId;
  final String taskNo;
  final String materialCode;
  final String materialName;
  final String batchNo;
  final String serialNo;
  final String storeSiteNo;
  final String unit;
  final double taskQty;
  final double collectedQty;
  final String palletNo;

  bool get isCompleted => collectedQty >= taskQty && taskQty > 0;

  Map<String, dynamic> toCollectPayload({required double quantity}) {
    return {
      'intaskitemid': taskItemId,
      'intaskid': taskId,
      'quantity': quantity,
    };
  }

  @override
  List<Object?> get props => [
        taskItemId,
        taskId,
        taskNo,
        materialCode,
        materialName,
        batchNo,
        serialNo,
        storeSiteNo,
        unit,
        taskQty,
        collectedQty,
        palletNo,
      ];
}

class AsrsInboundTrayInfo extends Equatable {
  const AsrsInboundTrayInfo({
    required this.trayNo,
    required this.storeSiteNo,
    required this.quantity,
    required this.weight,
    required this.capacity,
  });

  factory AsrsInboundTrayInfo.fromJson(Map<String, dynamic> json) {
    String _string(Object? value) => value?.toString() ?? '';
    double _double(Object? value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0;
    }

    return AsrsInboundTrayInfo(
      trayNo: _string(json['trayno'] ?? json['trayNo']),
      storeSiteNo: _string(json['storesiteno'] ?? json['storeSiteNo']),
      quantity: _double(json['quantity'] ?? json['qty']),
      weight: _double(json['weight'] ?? json['currentWeight']),
      capacity: _double(json['capacity'] ?? json['currentCapacity']),
    );
  }

  final String trayNo;
  final String storeSiteNo;
  final double quantity;
  final double weight;
  final double capacity;

  @override
  List<Object?> get props => [trayNo, storeSiteNo, quantity, weight, capacity];
}

class AsrsInboundCollectionRecord extends Equatable {
  AsrsInboundCollectionRecord({
    required this.materialCode,
    required this.materialName,
    required this.batchNo,
    required this.serialNo,
    required this.quantity,
    required this.unit,
    required this.storeSiteNo,
    required this.taskItemId,
  }) : id = const Uuid().v4();

  final String id;
  final String materialCode;
  final String materialName;
  final String batchNo;
  final String serialNo;
  final double quantity;
  final String unit;
  final String storeSiteNo;
  final String taskItemId;

  Map<String, dynamic> toPayload() {
    return {
      'matcode': materialCode,
      'matname': materialName,
      'batchno': batchNo,
      'sn': serialNo,
      'quantity': quantity,
      'unit': unit,
      'storesiteno': storeSiteNo,
      'intaskitemid': taskItemId,
    };
  }

  @override
  List<Object?> get props => [
        id,
        materialCode,
        materialName,
        batchNo,
        serialNo,
        quantity,
        unit,
        storeSiteNo,
        taskItemId,
      ];
}

enum AsrsInboundCommandType { normal, trayBinding }

class AsrsInboundWcsCommand extends Equatable {
  const AsrsInboundWcsCommand({
    required this.commandId,
    required this.taskId,
    required this.commandNo,
    required this.trayNo,
    required this.startAddress,
    required this.endAddress,
    required this.status,
    required this.createdTime,
  });

  factory AsrsInboundWcsCommand.fromJson(Map<String, dynamic> json) {
    String _string(Object? value) => value?.toString() ?? '';

    return AsrsInboundWcsCommand(
      commandId: _string(json['commandid'] ?? json['id']),
      taskId: _string(json['taskid'] ?? json['taskId']),
      commandNo: _string(json['commandno'] ?? json['commandNo']),
      trayNo: _string(json['trayno'] ?? json['trayNo']),
      startAddress: _string(json['startaddr'] ?? json['startAddress']),
      endAddress: _string(json['endaddr'] ?? json['endAddress']),
      status: _string(json['status']),
      createdTime: _string(json['createdate'] ?? json['createTime']),
    );
  }

  final String commandId;
  final String taskId;
  final String commandNo;
  final String trayNo;
  final String startAddress;
  final String endAddress;
  final String status;
  final String createdTime;

  @override
  List<Object?> get props => [
        commandId,
        taskId,
        commandNo,
        trayNo,
        startAddress,
        endAddress,
        status,
        createdTime,
      ];
}
