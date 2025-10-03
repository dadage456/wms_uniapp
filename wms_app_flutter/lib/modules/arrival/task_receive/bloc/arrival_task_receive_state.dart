import 'package:equatable/equatable.dart';

class ArrivalTaskReceiveState extends Equatable {
  const ArrivalTaskReceiveState({
    this.isProcessing = false,
    this.successMessage,
    this.errorMessage,
  });

  final bool isProcessing;
  final String? successMessage;
  final String? errorMessage;

  ArrivalTaskReceiveState copyWith({
    bool? isProcessing,
    String? successMessage,
    String? errorMessage,
  }) {
    return ArrivalTaskReceiveState(
      isProcessing: isProcessing ?? this.isProcessing,
      successMessage: successMessage,
      errorMessage: errorMessage,
    );
  }

  ArrivalTaskReceiveState clearMessages() {
    return const ArrivalTaskReceiveState();
  }

  @override
  List<Object?> get props => [isProcessing, successMessage, errorMessage];
}
