import 'package:equatable/equatable.dart';

abstract class AsrsOutboundListEvent extends Equatable {
  const AsrsOutboundListEvent();

  @override
  List<Object?> get props => [];
}

class AsrsOutboundListInitialized extends AsrsOutboundListEvent {
  const AsrsOutboundListInitialized({this.keyword});

  final String? keyword;

  @override
  List<Object?> get props => [keyword];
}

class AsrsOutboundListKeywordChanged extends AsrsOutboundListEvent {
  const AsrsOutboundListKeywordChanged(this.keyword);

  final String keyword;

  @override
  List<Object?> get props => [keyword];
}

class AsrsOutboundListRefreshed extends AsrsOutboundListEvent {
  const AsrsOutboundListRefreshed();
}

class AsrsOutboundListReceiveRequested extends AsrsOutboundListEvent {
  const AsrsOutboundListReceiveRequested({
    required this.taskItemIds,
    required this.cancel,
  });

  final List<String> taskItemIds;
  final bool cancel;

  @override
  List<Object?> get props => [taskItemIds, cancel];
}
