import 'package:equatable/equatable.dart';

class ExceptionTaskListState extends Equatable {
  const ExceptionTaskListState({
    this.isActionInProgress = false,
    this.successMessage,
    this.errorMessage,
  });

  final bool isActionInProgress;
  final String? successMessage;
  final String? errorMessage;

  ExceptionTaskListState copyWith({
    bool? isActionInProgress,
    String? successMessage,
    String? errorMessage,
  }) {
    return ExceptionTaskListState(
      isActionInProgress: isActionInProgress ?? this.isActionInProgress,
      successMessage: successMessage,
      errorMessage: errorMessage,
    );
  }

  ExceptionTaskListState clearMessages() {
    return copyWith(successMessage: null, errorMessage: null);
  }

  @override
  List<Object?> get props => [isActionInProgress, successMessage, errorMessage];
}
