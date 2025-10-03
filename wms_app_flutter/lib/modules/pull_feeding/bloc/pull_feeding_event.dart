import 'package:equatable/equatable.dart';

abstract class PullFeedingEvent extends Equatable {
  const PullFeedingEvent();

  @override
  List<Object?> get props => [];
}

class PullFeedingInitialized extends PullFeedingEvent {
  const PullFeedingInitialized();
}

class PullFeedingScanReceived extends PullFeedingEvent {
  const PullFeedingScanReceived(this.code);

  final String code;

  @override
  List<Object?> get props => [code];
}

class PullFeedingQuantitySubmitted extends PullFeedingEvent {
  const PullFeedingQuantitySubmitted(this.quantityText);

  final String quantityText;

  @override
  List<Object?> get props => [quantityText];
}

class PullFeedingSelectionChanged extends PullFeedingEvent {
  const PullFeedingSelectionChanged(this.selectedIds);

  final List<String> selectedIds;

  @override
  List<Object?> get props => [selectedIds];
}

class PullFeedingDeleteSelected extends PullFeedingEvent {
  const PullFeedingDeleteSelected();
}

class PullFeedingSubmitRequested extends PullFeedingEvent {
  const PullFeedingSubmitRequested();
}

class PullFeedingResetRequested extends PullFeedingEvent {
  const PullFeedingResetRequested();
}

class PullFeedingMessageCleared extends PullFeedingEvent {
  const PullFeedingMessageCleared();
}
