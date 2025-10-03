import 'package:equatable/equatable.dart';

class InboundTaskDetailEvent extends Equatable {
  const InboundTaskDetailEvent();

  @override
  List<Object?> get props => [];
}

class InitializeInboundTaskDetail extends InboundTaskDetailEvent {
  const InitializeInboundTaskDetail({required this.inTaskId, required this.workStation});

  final String inTaskId;
  final String workStation;

  @override
  List<Object?> get props => [inTaskId, workStation];
}

class SearchInboundTaskItems extends InboundTaskDetailEvent {
  const SearchInboundTaskItems(this.keyword, {this.decode = false});

  final String keyword;
  final bool decode;

  @override
  List<Object?> get props => [keyword, decode];
}

class ToggleInboundTaskItemSelection extends InboundTaskDetailEvent {
  const ToggleInboundTaskItemSelection(this.itemId);

  final String itemId;

  @override
  List<Object?> get props => [itemId];
}

class SelectAllInboundTaskItems extends InboundTaskDetailEvent {
  const SelectAllInboundTaskItems(this.checked);

  final bool checked;

  @override
  List<Object?> get props => [checked];
}

class CommitInboundTaskItems extends InboundTaskDetailEvent {
  const CommitInboundTaskItems({required this.cancel});

  final bool cancel;

  @override
  List<Object?> get props => [cancel];
}

class RefreshInboundTaskItems extends InboundTaskDetailEvent {
  const RefreshInboundTaskItems();
}
