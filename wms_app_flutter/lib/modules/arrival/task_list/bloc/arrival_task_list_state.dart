import 'package:equatable/equatable.dart';

class ArrivalTaskListState extends Equatable {
  const ArrivalTaskListState({
    this.isActionInProgress = false,
    this.successMessage,
    this.errorMessage,
  });

  final bool isActionInProgress;
  final String? successMessage;
  final String? errorMessage;

  ArrivalTaskListState copyWith({
    bool? isActionInProgress,
    String? successMessage,
    String? errorMessage,
  }) {
    return ArrivalTaskListState(
      isActionInProgress: isActionInProgress ?? this.isActionInProgress,
      successMessage: successMessage,
      errorMessage: errorMessage,
    );
  }

  ArrivalTaskListState clearMessages() {
    return const ArrivalTaskListState();
  }

  @override
  List<Object?> get props => [isActionInProgress, successMessage, errorMessage];
}
