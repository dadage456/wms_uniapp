import 'package:equatable/equatable.dart';
import 'package:wms_app/modules/pull_feeding/models/pull_feeding_models.dart';

enum PullFeedingStatus { initial, loading, ready, submitting }

const Object _unset = Object();

class PullFeedingState extends Equatable {
  const PullFeedingState({
    this.status = PullFeedingStatus.initial,
    this.step = PullFeedingStep.site,
    this.storeSite = '',
    this.barcodeContent,
    this.inventoryQty = 0,
    this.collectQty = 0,
    this.quantityRule = const PullFeedingQuantityRule(),
    this.records = const [],
    this.selectedRecordIds = const <String>{},
    this.placeholder = '请扫描货架号',
    this.errorMessage,
    this.successMessage,
    this.focusInput = false,
  });

  final PullFeedingStatus status;
  final PullFeedingStep step;
  final String storeSite;
  final PullFeedingBarcodeContent? barcodeContent;
  final double inventoryQty;
  final double collectQty;
  final PullFeedingQuantityRule quantityRule;
  final List<PullFeedingRecord> records;
  final Set<String> selectedRecordIds;
  final String placeholder;
  final String? errorMessage;
  final String? successMessage;
  final bool focusInput;

  bool get isLoading => status == PullFeedingStatus.loading;
  bool get isSubmitting => status == PullFeedingStatus.submitting;
  bool get requiresQuantity => step == PullFeedingStep.quantity;

  PullFeedingState copyWith({
    PullFeedingStatus? status,
    PullFeedingStep? step,
    String? storeSite,
    PullFeedingBarcodeContent? barcodeContent,
    double? inventoryQty,
    double? collectQty,
    PullFeedingQuantityRule? quantityRule,
    List<PullFeedingRecord>? records,
    Set<String>? selectedRecordIds,
    String? placeholder,
    bool? focusInput,
    Object? errorMessage = _unset,
    Object? successMessage = _unset,
    bool clearBarcode = false,
  }) {
    return PullFeedingState(
      status: status ?? this.status,
      step: step ?? this.step,
      storeSite: storeSite ?? this.storeSite,
      barcodeContent: clearBarcode ? null : (barcodeContent ?? this.barcodeContent),
      inventoryQty: inventoryQty ?? this.inventoryQty,
      collectQty: collectQty ?? this.collectQty,
      quantityRule: quantityRule ?? this.quantityRule,
      records: records ?? this.records,
      selectedRecordIds: selectedRecordIds ?? this.selectedRecordIds,
      placeholder: placeholder ?? this.placeholder,
      focusInput: focusInput ?? this.focusInput,
      errorMessage:
          errorMessage == _unset ? this.errorMessage : errorMessage as String?,
      successMessage:
          successMessage == _unset ? this.successMessage : successMessage as String?,
    );
  }

  PullFeedingState clearMessages() {
    return copyWith(errorMessage: null, successMessage: null);
  }

  @override
  List<Object?> get props => [
        status,
        step,
        storeSite,
        barcodeContent,
        inventoryQty,
        collectQty,
        quantityRule,
        records,
        selectedRecordIds,
        placeholder,
        errorMessage,
        successMessage,
        focusInput,
      ];
}
