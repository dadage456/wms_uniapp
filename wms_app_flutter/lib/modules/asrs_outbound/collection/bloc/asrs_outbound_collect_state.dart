import 'package:equatable/equatable.dart';
import 'package:wms_app/modules/asrs_outbound/models/asrs_outbound_models.dart';

enum AsrsOutboundCollectStatus { initial, loading, ready, submitting, success, failure }

class AsrsOutboundCollectState extends Equatable {
  const AsrsOutboundCollectState({
    this.status = AsrsOutboundCollectStatus.initial,
    this.task,
    this.details = const [],
    this.selectedDetail,
    this.step = AsrsCollectStep.scanSite,
    this.storeSite = '',
    this.trayNo = '',
    this.materialInfo,
    this.inventoryQty = 0,
    this.inputQuantity = 0,
    this.records = const [],
    this.errorMessage,
    this.successMessage,
    this.focusQuantity = false,
    this.clearScanField = false,
    this.isLoadingMaterial = false,
  });

  final AsrsOutboundCollectStatus status;
  final AsrsOutboundTask? task;
  final List<AsrsOutboundTaskDetail> details;
  final AsrsOutboundTaskDetail? selectedDetail;
  final AsrsCollectStep step;
  final String storeSite;
  final String trayNo;
  final AsrsMaterialInfo? materialInfo;
  final double inventoryQty;
  final double inputQuantity;
  final List<AsrsOutboundCollectRecord> records;
  final String? errorMessage;
  final String? successMessage;
  final bool focusQuantity;
  final bool clearScanField;
  final bool isLoadingMaterial;

  AsrsOutboundCollectState copyWith({
    AsrsOutboundCollectStatus? status,
    AsrsOutboundTask? task,
    List<AsrsOutboundTaskDetail>? details,
    AsrsOutboundTaskDetail? selectedDetail,
    bool removeSelectedDetail = false,
    AsrsCollectStep? step,
    String? storeSite,
    String? trayNo,
    AsrsMaterialInfo? materialInfo,
    bool removeMaterialInfo = false,
    double? inventoryQty,
    double? inputQuantity,
    List<AsrsOutboundCollectRecord>? records,
    String? errorMessage,
    String? successMessage,
    bool? focusQuantity,
    bool? clearScanField,
    bool? isLoadingMaterial,
  }) {
    return AsrsOutboundCollectState(
      status: status ?? this.status,
      task: task ?? this.task,
      details: details ?? this.details,
      selectedDetail: removeSelectedDetail ? null : selectedDetail ?? this.selectedDetail,
      step: step ?? this.step,
      storeSite: storeSite ?? this.storeSite,
      trayNo: trayNo ?? this.trayNo,
      materialInfo: removeMaterialInfo ? null : materialInfo ?? this.materialInfo,
      inventoryQty: inventoryQty ?? this.inventoryQty,
      inputQuantity: inputQuantity ?? this.inputQuantity,
      records: records ?? this.records,
      errorMessage: errorMessage,
      successMessage: successMessage,
      focusQuantity: focusQuantity ?? this.focusQuantity,
      clearScanField: clearScanField ?? this.clearScanField,
      isLoadingMaterial: isLoadingMaterial ?? this.isLoadingMaterial,
    );
  }

  AsrsOutboundCollectState clearMessages() {
    return copyWith(errorMessage: null, successMessage: null);
  }

  @override
  List<Object?> get props => [
        status,
        task,
        details,
        selectedDetail,
        step,
        storeSite,
        trayNo,
        materialInfo,
        inventoryQty,
        inputQuantity,
        records,
        errorMessage,
        successMessage,
        focusQuantity,
        clearScanField,
        isLoadingMaterial,
      ];
}
