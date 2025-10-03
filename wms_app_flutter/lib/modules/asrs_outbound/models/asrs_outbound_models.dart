import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class AsrsOutboundTask extends Equatable {
  const AsrsOutboundTask({
    required this.taskId,
    required this.taskNo,
    required this.taskComment,
    required this.orderNo,
    required this.sourceOrderNo,
    required this.storeRoomNo,
    required this.storeRoomName,
    required this.workstation,
    required this.scheduleGroupName,
    required this.wipSupplementFlag,
    required this.batchFlag,
    required this.beatFlag,
    required this.status,
    required this.projectNum,
  });

  factory AsrsOutboundTask.fromJson(Map<String, dynamic> json) {
    String _string(Object? value) => value?.toString() ?? '';

    return AsrsOutboundTask(
      taskId: _string(json['outtaskid'] ?? json['taskId']),
      taskNo: _string(json['outtaskno'] ?? json['taskNo']),
      taskComment: _string(json['taskcomment'] ?? json['taskComment']),
      orderNo: _string(json['orderno'] ?? json['orderNo']),
      sourceOrderNo: _string(json['po_number'] ?? json['sourceOrderNo']),
      storeRoomNo: _string(json['storeroomno'] ?? json['storeRoomNo']),
      storeRoomName: _string(json['storeroomname'] ?? json['storeRoomName']),
      workstation: _string(json['workstation']),
      scheduleGroupName: _string(json['schedule_group_name'] ?? json['scheduleGroupName']),
      wipSupplementFlag: _string(json['wip_supplement_flag'] ?? json['wipSupplementFlag']),
      batchFlag: _string(json['batchflag'] ?? json['batchFlag']),
      beatFlag: _string(json['beatflag'] ?? json['beatFlag']),
      status: _string(json['status'] ?? json['taskStatus']),
      projectNum: _string(json['projectnum'] ?? json['projectNum']),
    );
  }

  final String taskId;
  final String taskNo;
  final String taskComment;
  final String orderNo;
  final String sourceOrderNo;
  final String storeRoomNo;
  final String storeRoomName;
  final String workstation;
  final String scheduleGroupName;
  final String wipSupplementFlag;
  final String batchFlag;
  final String beatFlag;
  final String status;
  final String projectNum;

  Map<String, dynamic> toListJson() {
    return {
      'taskId': taskId,
      'taskNo': taskNo,
      'taskComment': taskComment,
      'orderNo': orderNo,
      'sourceOrderNo': sourceOrderNo,
      'storeRoomNo': storeRoomNo,
      'storeRoomName': storeRoomName,
      'workstation': workstation,
      'scheduleGroupName': scheduleGroupName,
      'wipSupplementFlag': wipSupplementFlag,
      'batchFlag': batchFlag,
      'beatFlag': beatFlag,
      'status': status,
      'projectNum': projectNum,
    };
  }

  @override
  List<Object?> get props => [
        taskId,
        taskNo,
        taskComment,
        orderNo,
        sourceOrderNo,
        storeRoomNo,
        storeRoomName,
        workstation,
        scheduleGroupName,
        wipSupplementFlag,
        batchFlag,
        beatFlag,
        status,
        projectNum,
      ];
}

class AsrsOutboundTaskDetail extends Equatable {
  const AsrsOutboundTaskDetail({
    required this.taskItemId,
    required this.taskId,
    required this.taskNo,
    required this.materialCode,
    required this.materialName,
    required this.materialInnerCode,
    required this.batchNo,
    required this.serialNo,
    required this.storeSiteNo,
    required this.storeRoomNo,
    required this.storeRoomName,
    required this.taskQty,
    required this.hintQty,
    required this.palletNo,
    required this.subInventoryCode,
    required this.erpStoreRoom,
    required this.erpOwnerCode,
    required this.projectNum,
  });

  factory AsrsOutboundTaskDetail.fromJson(Map<String, dynamic> json) {
    double _double(Object? value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0;
    }

    String _string(Object? value) => value?.toString() ?? '';

    return AsrsOutboundTaskDetail(
      taskItemId: _string(json['outtaskitemid'] ?? json['taskItemId']),
      taskId: _string(json['outtaskid'] ?? json['taskId']),
      taskNo: _string(json['outtaskno'] ?? json['taskNo']),
      materialCode: _string(json['matcode'] ?? json['materialCode']),
      materialName: _string(json['matname'] ?? json['materialName']),
      materialInnerCode: _string(json['matinnercode'] ?? json['materialInnerCode']),
      batchNo: _string(json['batchno'] ?? json['batchNo']),
      serialNo: _string(json['sn'] ?? json['serialNo']),
      storeSiteNo: _string(json['storesiteno'] ?? json['storeSiteNo']),
      storeRoomNo: _string(json['storeroomno'] ?? json['storeRoomNo']),
      storeRoomName: _string(json['storeroomname'] ?? json['storeRoomName']),
      taskQty: _double(json['taskqty'] ?? json['qty'] ?? json['taskQty']),
      hintQty: _double(json['hintqty'] ?? json['hintQty']),
      palletNo: _string(json['palletno'] ?? json['palletNo']),
      subInventoryCode: _string(json['subinventoryCode'] ?? json['subInventoryCode']),
      erpStoreRoom: _string(json['erpStoreroom'] ?? json['erpStoreRoom']),
      erpOwnerCode: _string(json['erpOwnerCode'] ?? json['supplier']),
      projectNum: _string(json['projectnum'] ?? json['projectNum']),
    );
  }

  final String taskItemId;
  final String taskId;
  final String taskNo;
  final String materialCode;
  final String materialName;
  final String materialInnerCode;
  final String batchNo;
  final String serialNo;
  final String storeSiteNo;
  final String storeRoomNo;
  final String storeRoomName;
  final double taskQty;
  final double hintQty;
  final String palletNo;
  final String subInventoryCode;
  final String erpStoreRoom;
  final String erpOwnerCode;
  final String projectNum;

  Map<String, dynamic> toReceivePayload() {
    return {
      'outtaskitemid': taskItemId,
      'outtaskid': taskId,
      'outtaskno': taskNo,
    };
  }

  @override
  List<Object?> get props => [
        taskItemId,
        taskId,
        taskNo,
        materialCode,
        materialName,
        materialInnerCode,
        batchNo,
        serialNo,
        storeSiteNo,
        storeRoomNo,
        storeRoomName,
        taskQty,
        hintQty,
        palletNo,
        subInventoryCode,
        erpStoreRoom,
        erpOwnerCode,
        projectNum,
      ];
}

class AsrsInventoryStock extends Equatable {
  const AsrsInventoryStock({
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

  factory AsrsInventoryStock.fromJson(Map<String, dynamic> json) {
    double _double(Object? value) {
      if (value == null) return 0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0;
    }

    String _string(Object? value) => value?.toString() ?? '';

    return AsrsInventoryStock(
      storeSiteNo: _string(json['storesiteno'] ?? json['storeSiteNo']),
      materialCode: _string(json['matcode'] ?? json['materialCode']),
      materialName: _string(json['matname'] ?? json['materialName']),
      batchNo: _string(json['batchno'] ?? json['batchNo']),
      serialNo: _string(json['sn'] ?? json['serialNo']),
      availableQty: _double(json['repqty'] ?? json['availableQty'] ?? json['qty']),
      erpStoreRoom: _string(json['erpStoreroom'] ?? json['erpStoreRoom']),
      erpOwnerCode: _string(json['erpOwnerCode'] ?? json['supplier']),
      projectNum: _string(json['projectnum'] ?? json['projectNum']),
      storeRoomNo: _string(json['storeroomno'] ?? json['storeRoomNo']),
      storeRoomName: _string(json['storeroomname'] ?? json['storeRoomName']),
      palletNo: json['palletno']?.toString(),
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

  @override
  List<Object?> get props => [
        storeSiteNo,
        materialCode,
        materialName,
        batchNo,
        serialNo,
        availableQty,
        erpStoreRoom,
        erpOwnerCode,
        projectNum,
        storeRoomNo,
        storeRoomName,
        palletNo,
      ];
}

class AsrsMaterialInfo extends Equatable {
  const AsrsMaterialInfo({
    required this.materialCode,
    required this.materialName,
    required this.batchNo,
    required this.serialNo,
    required this.erpStoreRoom,
    required this.erpOwnerCode,
    required this.projectNum,
    required this.unit,
  });

  factory AsrsMaterialInfo.fromJson(Map<String, dynamic> json) {
    String _string(Object? value) => value?.toString() ?? '';

    return AsrsMaterialInfo(
      materialCode: _string(json['matcode'] ?? json['materialCode']),
      materialName: _string(json['matname'] ?? json['materialName']),
      batchNo: _string(json['batchno'] ?? json['batchNo']),
      serialNo: _string(json['sn'] ?? json['serialNo']),
      erpStoreRoom: _string(json['erpStoreroom'] ?? json['erpStoreRoom']),
      erpOwnerCode: _string(json['erpOwnerCode'] ?? json['supplier']),
      projectNum: _string(json['projectnum'] ?? json['projectNum']),
      unit: _string(json['uom'] ?? json['unit'] ?? json['uomCode']),
    );
  }

  final String materialCode;
  final String materialName;
  final String batchNo;
  final String serialNo;
  final String erpStoreRoom;
  final String erpOwnerCode;
  final String projectNum;
  final String unit;

  @override
  List<Object?> get props => [
        materialCode,
        materialName,
        batchNo,
        serialNo,
        erpStoreRoom,
        erpOwnerCode,
        projectNum,
        unit,
      ];
}

enum AsrsCollectStep {
  scanSite,
  scanTray,
  scanMaterial,
  inputQuantity,
  idle,
}

class AsrsOutboundCollectRecord extends Equatable {
  AsrsOutboundCollectRecord({
    String? id,
    required this.taskItemId,
    required this.taskNo,
    required this.taskId,
    required this.storeSite,
    required this.trayNo,
    required this.materialCode,
    required this.materialName,
    required this.batchNo,
    required this.serialNo,
    required this.quantity,
    required this.erpStoreRoom,
    required this.erpOwnerCode,
    required this.projectNum,
  }) : id = id ?? const Uuid().v4();

  final String id;
  final String taskItemId;
  final String taskNo;
  final String taskId;
  final String storeSite;
  final String trayNo;
  final String materialCode;
  final String materialName;
  final String batchNo;
  final String serialNo;
  final double quantity;
  final String erpStoreRoom;
  final String erpOwnerCode;
  final String projectNum;

  Map<String, dynamic> toDownShelvesJson() {
    return {
      'taskId': taskId,
      'taskNo': taskNo,
      'taskItemId': taskItemId,
      'storeSite': storeSite,
      'trayNo': trayNo,
      'materialCode': materialCode,
      'materialName': materialName,
      'batchNo': batchNo,
      'sn': serialNo,
      'qty': quantity,
      'erpStoreRoom': erpStoreRoom,
      'erpOwnerCode': erpOwnerCode,
      'projectNum': projectNum,
    };
  }

  @override
  List<Object?> get props => [
        id,
        taskItemId,
        taskNo,
        taskId,
        storeSite,
        trayNo,
        materialCode,
        materialName,
        batchNo,
        serialNo,
        quantity,
        erpStoreRoom,
        erpOwnerCode,
        projectNum,
      ];
}

class AsrsLocation extends Equatable {
  const AsrsLocation({
    required this.address,
    required this.description,
  });

  factory AsrsLocation.fromJson(Map<String, dynamic> json) {
    String _string(Object? value) => value?.toString() ?? '';
    return AsrsLocation(
      address: _string(json['address'] ?? json['addr'] ?? json['startAddr']),
      description: _string(json['description'] ?? json['remark'] ?? json['text']),
    );
  }

  final String address;
  final String description;

  @override
  List<Object?> get props => [address, description];
}

enum AsrsCommandType { normal, inventory, empty }

class AsrsWcsCommandPayload extends Equatable {
  const AsrsWcsCommandPayload({
    required this.taskId,
    required this.taskNo,
    required this.trayNo,
    required this.startAddress,
    required this.endAddress,
    required this.singleFlag,
    required this.type,
  });

  final String taskId;
  final String taskNo;
  final String trayNo;
  final String startAddress;
  final String endAddress;
  final String singleFlag;
  final AsrsCommandType type;

  @override
  List<Object?> get props => [
        taskId,
        taskNo,
        trayNo,
        startAddress,
        endAddress,
        singleFlag,
        type,
      ];
}
