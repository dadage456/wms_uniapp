import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

enum PullFeedingStep { site, material, quantity }

class PullFeedingBarcodeContent extends Equatable {
  const PullFeedingBarcodeContent({
    required this.materialCode,
    this.materialName,
    this.batchNo,
    this.serialNumber,
    this.controlMode,
    this.originalId,
    this.quantity,
  });

  factory PullFeedingBarcodeContent.fromJson(Map<String, dynamic> json) {
    return PullFeedingBarcodeContent(
      materialCode: json['matcode']?.toString() ?? '',
      materialName: json['matname']?.toString(),
      batchNo: json['batchno']?.toString(),
      serialNumber: json['sn']?.toString(),
      controlMode: json['seqctrl']?.toString(),
      originalId: json['id_old']?.toString(),
      quantity: double.tryParse(json['qty']?.toString() ?? ''),
    );
  }

  final String materialCode;
  final String? materialName;
  final String? batchNo;
  final String? serialNumber;
  final String? controlMode;
  final String? originalId;
  final double? quantity;

  @override
  List<Object?> get props => [
        materialCode,
        materialName,
        batchNo,
        serialNumber,
        controlMode,
        originalId,
        quantity,
      ];
}

class PullFeedingRecord extends Equatable {
  PullFeedingRecord({
    required this.storeSite,
    required this.materialCode,
    required this.quantity,
    this.materialName,
  }) : id = const Uuid().v4();

  PullFeedingRecord.withId({
    required this.id,
    required this.storeSite,
    required this.materialCode,
    required this.quantity,
    this.materialName,
  });

  PullFeedingRecord copyWith({
    double? quantity,
  }) {
    return PullFeedingRecord.withId(
      id: id,
      storeSite: storeSite,
      materialCode: materialCode,
      materialName: materialName,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'locationNo': storeSite,
      'matCode': materialCode,
      'qty': quantity,
    };
  }

  final String id;
  final String storeSite;
  final String materialCode;
  final double quantity;
  final String? materialName;

  @override
  List<Object?> get props => [id, storeSite, materialCode, quantity, materialName];
}

class PullFeedingQuantityRule extends Equatable {
  const PullFeedingQuantityRule({
    this.minPackageQty = 0,
    this.defaultDeliveryQty = 0,
  });

  factory PullFeedingQuantityRule.fromJson(Map<String, dynamic> json) {
    return PullFeedingQuantityRule(
      minPackageQty: double.tryParse(json['minQty']?.toString() ?? '') ?? 0,
      defaultDeliveryQty: double.tryParse(json['deliveryQty']?.toString() ?? '') ?? 0,
    );
  }

  final double minPackageQty;
  final double defaultDeliveryQty;

  @override
  List<Object?> get props => [minPackageQty, defaultDeliveryQty];
}
