import 'package:equatable/equatable.dart';

class TaskMessageState extends Equatable {
  const TaskMessageState({
    this.isProcessing = false,
    this.successMessage,
    this.errorMessage,
  });

  final bool isProcessing;
  final String? successMessage;
  final String? errorMessage;

  TaskMessageState copyWith({
    bool? isProcessing,
    String? successMessage,
    String? errorMessage,
  }) {
    return TaskMessageState(
      isProcessing: isProcessing ?? this.isProcessing,
      successMessage: successMessage,
      errorMessage: errorMessage,
    );
  }

  TaskMessageState clearMessages() => copyWith(successMessage: null, errorMessage: null);

  @override
  List<Object?> get props => [isProcessing, successMessage, errorMessage];
}
