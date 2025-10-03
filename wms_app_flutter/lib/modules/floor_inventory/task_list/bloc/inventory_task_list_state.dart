import 'package:equatable/equatable.dart';

class InventoryTaskListState extends Equatable {
  const InventoryTaskListState({
    this.isActionInProgress = false,
    this.successMessage,
    this.errorMessage,
  });

  final bool isActionInProgress;
  final String? successMessage;
  final String? errorMessage;

  InventoryTaskListState copyWith({
    bool? isActionInProgress,
    String? successMessage,
    String? errorMessage,
  }) {
    return InventoryTaskListState(
      isActionInProgress: isActionInProgress ?? this.isActionInProgress,
      successMessage: successMessage,
      errorMessage: errorMessage,
    );
  }

  InventoryTaskListState clearMessages() {
    return InventoryTaskListState(
      isActionInProgress: isActionInProgress,
    );
  }

  @override
  List<Object?> get props => [isActionInProgress, successMessage, errorMessage];
}
