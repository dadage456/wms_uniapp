import 'package:equatable/equatable.dart';
import 'package:wms_app/modules/asrs_inventory/models/asrs_inventory_models.dart';

enum AsrsInventoryCollectStatus { initial, loading, ready, submitting, success, failure }

enum AsrsInventoryCollectStep { search, quantity, review }

class AsrsInventoryCollectState extends Equatable {
  const AsrsInventoryCollectState({
    this.status = AsrsInventoryCollectStatus.initial,
    this.step = AsrsInventoryCollectStep.search,
    this.task,
    this.details = const [],
    this.filteredDetails = const [],
    this.selectedDetail,
    this.records = const [],
    this.keyword = '',
    this.quantity = 0,
    this.errorMessage,
    this.successMessage,
  });

  final AsrsInventoryCollectStatus status;
  final AsrsInventoryCollectStep step;
  final AsrsInventoryTask? task;
  final List<AsrsInventoryTaskDetail> details;
  final List<AsrsInventoryTaskDetail> filteredDetails;
  final AsrsInventoryTaskDetail? selectedDetail;
  final List<AsrsInventoryCollectionRecord> records;
  final String keyword;
  final double quantity;
  final String? errorMessage;
  final String? successMessage;

  AsrsInventoryCollectState copyWith({
    AsrsInventoryCollectStatus? status,
    AsrsInventoryCollectStep? step,
    AsrsInventoryTask? task,
    List<AsrsInventoryTaskDetail>? details,
    List<AsrsInventoryTaskDetail>? filteredDetails,
    AsrsInventoryTaskDetail? selectedDetail,
    List<AsrsInventoryCollectionRecord>? records,
    String? keyword,
    double? quantity,
    String? errorMessage,
    String? successMessage,
  }) {
    return AsrsInventoryCollectState(
      status: status ?? this.status,
      step: step ?? this.step,
      task: task ?? this.task,
      details: details ?? this.details,
      filteredDetails: filteredDetails ?? this.filteredDetails,
      selectedDetail: selectedDetail ?? this.selectedDetail,
      records: records ?? this.records,
      keyword: keyword ?? this.keyword,
      quantity: quantity ?? this.quantity,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  AsrsInventoryCollectState clearMessages() =>
      copyWith(errorMessage: null, successMessage: null);

  @override
  List<Object?> get props => [
        status,
        step,
        task,
        details,
        filteredDetails,
        selectedDetail,
        records,
        keyword,
        quantity,
        errorMessage,
        successMessage,
      ];
}
