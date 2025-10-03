import 'package:equatable/equatable.dart';

abstract class InboundTaskEvent extends Equatable {
  const InboundTaskEvent();

  @override
  List<Object?> get props => [];
}

class SearchInboundTasksEvent extends InboundTaskEvent {
  const SearchInboundTasksEvent(this.searchKey);

  final String searchKey;

  @override
  List<Object?> get props => [searchKey];
}

class FilterInboundTasksEvent extends InboundTaskEvent {
  const FilterInboundTasksEvent(this.finishFlag);

  final String finishFlag;

  @override
  List<Object?> get props => [finishFlag];
}

class RefreshInboundTasksEvent extends InboundTaskEvent {
  const RefreshInboundTasksEvent();
}

class SetInboundTaskUserScopeEvent extends InboundTaskEvent {
  const SetInboundTaskUserScopeEvent({required this.userId, required this.roleOrUserId});

  final String userId;
  final String roleOrUserId;

  @override
  List<Object?> get props => [userId, roleOrUserId];
}
