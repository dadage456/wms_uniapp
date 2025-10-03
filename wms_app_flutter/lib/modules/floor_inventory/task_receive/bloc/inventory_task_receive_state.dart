import 'package:equatable/equatable.dart';

class InventoryTaskReceiveState extends Equatable {
  const InventoryTaskReceiveState({
    this.isActionInProgress = false,
    this.successMessage,
    this.errorMessage,
  });

  final bool isActionInProgress;
  final String? successMessage;
  final String? errorMessage;

  InventoryTaskReceiveState copyWith({
    bool? isActionInProgress,
    String? successMessage,
    String? errorMessage,
  }) {
    return InventoryTaskReceiveState(
      isActionInProgress: isActionInProgress ?? this.isActionInProgress,
      successMessage: successMessage,
      errorMessage: errorMessage,
    );
  }

  InventoryTaskReceiveState clearMessages() {
    return InventoryTaskReceiveState(
      isActionInProgress: isActionInProgress,
    );
  }

  @override
  List<Object?> get props => [isActionInProgress, successMessage, errorMessage];
}
