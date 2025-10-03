import 'package:equatable/equatable.dart';
import 'package:wms_app/modules/arrival/task_details/models/arrival_task_detail.dart';
import 'package:wms_app/modules/floor_inbound/collection_task/models/inbound_collection_models.dart';

class ArrivalCollectionPrompt extends Equatable {
  const ArrivalCollectionPrompt({
    required this.detail,
    this.material,
    required this.remainingQty,
    this.suggestedQty,
  });

  final ArrivalTaskDetail detail;
  final InboundBarcodeContent? material;
  final double remainingQty;
  final double? suggestedQty;

  @override
  List<Object?> get props => [detail, material, remainingQty, suggestedQty];
}

class ArrivalCollectionRecord extends Equatable {
  const ArrivalCollectionRecord({
    required this.id,
    required this.detailId,
    required this.arrivalsBillId,
    required this.materialCode,
    required this.materialName,
    this.batchNo,
    this.serialNo,
    required this.quantity,
    required this.taskQty,
    required this.storeRoom,
    this.subInventory,
    this.supplierName,
    required this.collectFlag,
    this.productionDate,
    this.validDays,
  });

  final String id;
  final String detailId;
  final String arrivalsBillId;
  final String materialCode;
  final String materialName;
  final String? batchNo;
  final String? serialNo;
  final double quantity;
  final double taskQty;
  final String storeRoom;
  final String? subInventory;
  final String? supplierName;
  final String collectFlag;
  final DateTime? productionDate;
  final int? validDays;

  ArrivalCollectionRecord copyWith({double? quantity}) {
    return ArrivalCollectionRecord(
      id: id,
      detailId: detailId,
      arrivalsBillId: arrivalsBillId,
      materialCode: materialCode,
      materialName: materialName,
      batchNo: batchNo,
      serialNo: serialNo,
      quantity: quantity ?? this.quantity,
      taskQty: taskQty,
      storeRoom: storeRoom,
      subInventory: subInventory,
      supplierName: supplierName,
      collectFlag: collectFlag,
      productionDate: productionDate,
      validDays: validDays,
    );
  }

  bool isSameTarget(ArrivalCollectionRecord other) {
    return detailId == other.detailId &&
        (batchNo ?? '') == (other.batchNo ?? '') &&
        (serialNo ?? '') == (other.serialNo ?? '') &&
        collectFlag == other.collectFlag;
  }

  @override
  List<Object?> get props => [
        id,
        detailId,
        arrivalsBillId,
        materialCode,
        materialName,
        batchNo,
        serialNo,
        quantity,
        taskQty,
        storeRoom,
        subInventory,
        supplierName,
        collectFlag,
        productionDate,
        validDays,
      ];
}
