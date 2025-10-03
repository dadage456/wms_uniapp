import 'package:wms_app/modules/floor_transfer/models/transfer_models.dart';
import 'package:wms_app/modules/outbound/collection_task/models/collection_models.dart';

class FloorTransferState {
  const FloorTransferState({
    this.mode = TransferMode.moveOut,
    this.placeholder = '请扫描来源库位',
    this.step = TransferStep.sourceSite,
    this.focusInput = false,
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
    this.storeRoom = '',
    this.sourceSite = '',
    this.targetSite = '',
    this.materialCode = '',
    this.materialName = '',
    this.batchNo = '',
    this.serialNo = '',
    this.projectNum = '',
    this.erpStoreRoom = '',
    this.erpOwnerCode = '',
    this.quantity = 0,
    this.materialControl = MaterialControl.none,
    this.records = const [],
    this.selectedRecordIds = const [],
    this.sourceStocks = const [],
    this.currentTab = 0,
    this.inventoryQueryKeyword = '',
    this.inventoryQueryStep = 'M',
    this.inventoryQueryResults = const [],
    this.inventoryQueryPage = 1,
    this.inventoryQueryTotalPages = 1,
    this.isInventoryQueryLoading = false,
    this.barcodeContent,
  });

  final TransferMode mode;
  final String placeholder;
  final TransferStep step;
  final bool focusInput;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;
  final String storeRoom;
  final String sourceSite;
  final String targetSite;
  final String materialCode;
  final String materialName;
  final String batchNo;
  final String serialNo;
  final String projectNum;
  final String erpStoreRoom;
  final String erpOwnerCode;
  final double quantity;
  final MaterialControl materialControl;
  final List<TransferRecord> records;
  final List<String> selectedRecordIds;
  final List<InventoryStock> sourceStocks;
  final int currentTab;
  final String inventoryQueryKeyword;
  final String inventoryQueryStep;
  final List<InventoryStock> inventoryQueryResults;
  final int inventoryQueryPage;
  final int inventoryQueryTotalPages;
  final bool isInventoryQueryLoading;
  final BarcodeContent? barcodeContent;

  bool get requiresQuantity => step == TransferStep.quantity;

  static const _undefined = Object();

  FloorTransferState copyWith({
    TransferMode? mode,
    String? placeholder,
    TransferStep? step,
    bool? focusInput,
    bool? isLoading,
    bool? isSubmitting,
    Object? errorMessage = _undefined,
    Object? successMessage = _undefined,
    String? storeRoom,
    String? sourceSite,
    String? targetSite,
    String? materialCode,
    String? materialName,
    String? batchNo,
    String? serialNo,
    String? projectNum,
    String? erpStoreRoom,
    String? erpOwnerCode,
    double? quantity,
    MaterialControl? materialControl,
    List<TransferRecord>? records,
    List<String>? selectedRecordIds,
    List<InventoryStock>? sourceStocks,
    int? currentTab,
    String? inventoryQueryKeyword,
    String? inventoryQueryStep,
    List<InventoryStock>? inventoryQueryResults,
    int? inventoryQueryPage,
    int? inventoryQueryTotalPages,
    bool? isInventoryQueryLoading,
    Object? barcodeContent = _undefined,
  }) {
    return FloorTransferState(
      mode: mode ?? this.mode,
      placeholder: placeholder ?? this.placeholder,
      step: step ?? this.step,
      focusInput: focusInput ?? this.focusInput,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage:
          identical(errorMessage, _undefined) ? this.errorMessage : errorMessage as String?,
      successMessage: identical(successMessage, _undefined)
          ? this.successMessage
          : successMessage as String?,
      storeRoom: storeRoom ?? this.storeRoom,
      sourceSite: sourceSite ?? this.sourceSite,
      targetSite: targetSite ?? this.targetSite,
      materialCode: materialCode ?? this.materialCode,
      materialName: materialName ?? this.materialName,
      batchNo: batchNo ?? this.batchNo,
      serialNo: serialNo ?? this.serialNo,
      projectNum: projectNum ?? this.projectNum,
      erpStoreRoom: erpStoreRoom ?? this.erpStoreRoom,
      erpOwnerCode: erpOwnerCode ?? this.erpOwnerCode,
      quantity: quantity ?? this.quantity,
      materialControl: materialControl ?? this.materialControl,
      records: records ?? this.records,
      selectedRecordIds: selectedRecordIds ?? this.selectedRecordIds,
      sourceStocks: sourceStocks ?? this.sourceStocks,
      currentTab: currentTab ?? this.currentTab,
      inventoryQueryKeyword: inventoryQueryKeyword ?? this.inventoryQueryKeyword,
      inventoryQueryStep: inventoryQueryStep ?? this.inventoryQueryStep,
      inventoryQueryResults: inventoryQueryResults ?? this.inventoryQueryResults,
      inventoryQueryPage: inventoryQueryPage ?? this.inventoryQueryPage,
      inventoryQueryTotalPages: inventoryQueryTotalPages ?? this.inventoryQueryTotalPages,
      isInventoryQueryLoading: isInventoryQueryLoading ?? this.isInventoryQueryLoading,
      barcodeContent: identical(barcodeContent, _undefined)
          ? this.barcodeContent
          : barcodeContent as BarcodeContent?,
    );
  }
}
