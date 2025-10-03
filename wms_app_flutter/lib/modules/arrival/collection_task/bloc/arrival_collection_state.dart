import 'package:equatable/equatable.dart';
import 'package:wms_app/modules/arrival/collection_task/models/arrival_collection_models.dart';
import 'package:wms_app/modules/arrival/task_details/models/arrival_task_detail.dart';
import 'package:wms_app/modules/arrival/task_list/models/arrival_task.dart';

class ArrivalCollectionState extends Equatable {
  const ArrivalCollectionState({
    this.task,
    this.isLoading = false,
    this.isSubmitting = false,
    this.details = const [],
    this.records = const [],
    this.initialCollected = const {},
    this.prompt,
    this.errorMessage,
    this.successMessage,
    this.currentTab = 0,
    this.placeholder = '请扫描物料二维码',
  });

  final ArrivalTask? task;
  final bool isLoading;
  final bool isSubmitting;
  final List<ArrivalTaskDetail> details;
  final List<ArrivalCollectionRecord> records;
  final Map<String, double> initialCollected;
  final ArrivalCollectionPrompt? prompt;
  final String? errorMessage;
  final String? successMessage;
  final int currentTab;
  final String placeholder;

  ArrivalCollectionState copyWith({
    ArrivalTask? task,
    bool? isLoading,
    bool? isSubmitting,
    List<ArrivalTaskDetail>? details,
    List<ArrivalCollectionRecord>? records,
    Map<String, double>? initialCollected,
    ArrivalCollectionPrompt? prompt,
    bool clearPrompt = false,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
    int? currentTab,
    String? placeholder,
  }) {
    return ArrivalCollectionState(
      task: task ?? this.task,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      details: details ?? this.details,
      records: records ?? this.records,
      initialCollected: initialCollected ?? this.initialCollected,
      prompt: clearPrompt ? null : (prompt ?? this.prompt),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      currentTab: currentTab ?? this.currentTab,
      placeholder: placeholder ?? this.placeholder,
    );
  }

  @override
  List<Object?> get props => [
        task,
        isLoading,
        isSubmitting,
        details,
        records,
        initialCollected,
        prompt,
        errorMessage,
        successMessage,
        currentTab,
        placeholder,
      ];
}
