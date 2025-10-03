import 'package:equatable/equatable.dart';

abstract class ArrivalTaskReceiveEvent extends Equatable {
  const ArrivalTaskReceiveEvent();

  @override
  List<Object?> get props => [];
}

class ArrivalTaskReceiveSearchSubmitted extends ArrivalTaskReceiveEvent {
  const ArrivalTaskReceiveSearchSubmitted(this.searchKey);

  final String searchKey;

  @override
  List<Object?> get props => [searchKey];
}

class ArrivalTaskReceiveRefreshRequested extends ArrivalTaskReceiveEvent {
  const ArrivalTaskReceiveRefreshRequested();
}

class ArrivalTaskReceiveConfirmed extends ArrivalTaskReceiveEvent {
  const ArrivalTaskReceiveConfirmed(this.arrivalsBillId);

  final String arrivalsBillId;

  @override
  List<Object?> get props => [arrivalsBillId];
}

class ArrivalTaskReceiveMessageCleared extends ArrivalTaskReceiveEvent {
  const ArrivalTaskReceiveMessageCleared();
}
