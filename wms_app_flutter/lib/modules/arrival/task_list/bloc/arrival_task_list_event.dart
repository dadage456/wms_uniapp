import 'package:equatable/equatable.dart';

abstract class ArrivalTaskListEvent extends Equatable {
  const ArrivalTaskListEvent();

  @override
  List<Object?> get props => [];
}

class ArrivalTaskListSearchSubmitted extends ArrivalTaskListEvent {
  const ArrivalTaskListSearchSubmitted(this.searchKey);

  final String searchKey;

  @override
  List<Object?> get props => [searchKey];
}

class ArrivalTaskListRefreshRequested extends ArrivalTaskListEvent {
  const ArrivalTaskListRefreshRequested();
}

class ArrivalTaskCancelRequested extends ArrivalTaskListEvent {
  const ArrivalTaskCancelRequested(this.arrivalsBillId);

  final String arrivalsBillId;

  @override
  List<Object?> get props => [arrivalsBillId];
}

class ArrivalTaskActionMessageCleared extends ArrivalTaskListEvent {
  const ArrivalTaskActionMessageCleared();
}
