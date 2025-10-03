import 'package:equatable/equatable.dart';
import 'package:wms_app/modules/floor_inventory/task_collect/models/inventory_collect_models.dart';
import 'package:wms_app/modules/floor_inventory/task_details/models/inventory_task_detail.dart';
import 'package:wms_app/modules/floor_inventory/task_list/models/inventory_task.dart';

enum InventoryCollectStatus {
  initial,
  loading,
  success,
  failure,
  submitting,
  submitSuccess,
}

enum InventoryCollectStep { site, material, quantity }

const Object _unset = Object();

class InventoryCollectState extends Equatable {
  const InventoryCollectState({
    this.status = InventoryCollectStatus.initial,
    this.step = InventoryCollectStep.site,
    this.task,
    this.taskItems = const [],
    this.collectRecords = const [],
    this.currentStoreSite = '',
    this.currentMaterial,
    this.collectQty = 0,
    this.currentTab = 0,
    this.placeholder = '请扫描库位',
    this.errorMessage,
    this.successMessage,
  });

  final InventoryCollectStatus status;
  final InventoryCollectStep step;
  final InventoryTask? task;
  final List<InventoryTaskDetail> taskItems;
  final List<InventoryCollectionRecord> collectRecords;
  final String currentStoreSite;
  final InventoryMaterialInfo? currentMaterial;
  final double collectQty;
  final int currentTab;
  final String placeholder;
  final String? errorMessage;
  final String? successMessage;

  bool get requiresQuantity => step == InventoryCollectStep.quantity;
  bool get isLoading => status == InventoryCollectStatus.loading;
  bool get isSubmitting => status == InventoryCollectStatus.submitting;

  InventoryCollectState copyWith({
    InventoryCollectStatus? status,
    InventoryCollectStep? step,
    InventoryTask? task,
    List<InventoryTaskDetail>? taskItems,
    List<InventoryCollectionRecord>? collectRecords,
    String? currentStoreSite,
    InventoryMaterialInfo? currentMaterial,
    double? collectQty,
    int? currentTab,
    String? placeholder,
    Object? errorMessage = _unset,
    Object? successMessage = _unset,
    bool clearMaterial = false,
  }) {
    return InventoryCollectState(
      status: status ?? this.status,
      step: step ?? this.step,
      task: task ?? this.task,
      taskItems: taskItems ?? this.taskItems,
      collectRecords: collectRecords ?? this.collectRecords,
      currentStoreSite: currentStoreSite ?? this.currentStoreSite,
      currentMaterial: clearMaterial ? null : (currentMaterial ?? this.currentMaterial),
      collectQty: collectQty ?? this.collectQty,
      currentTab: currentTab ?? this.currentTab,
      placeholder: placeholder ?? this.placeholder,
      errorMessage:
          errorMessage == _unset ? this.errorMessage : errorMessage as String?,
      successMessage:
          successMessage == _unset ? this.successMessage : successMessage as String?,
    );
  }

  InventoryCollectState clearMessages() {
    return copyWith(errorMessage: null, successMessage: null);
  }

  @override
  List<Object?> get props => [
        status,
        step,
        task,
        taskItems,
        collectRecords,
        currentStoreSite,
        currentMaterial,
        collectQty,
        currentTab,
        placeholder,
        errorMessage,
        successMessage,
      ];
}
