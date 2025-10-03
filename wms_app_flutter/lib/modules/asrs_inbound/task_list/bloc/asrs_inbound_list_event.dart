import 'package:equatable/equatable.dart';

abstract class AsrsInboundListEvent extends Equatable {
  const AsrsInboundListEvent();

  @override
  List<Object?> get props => [];
}

class AsrsInboundListInitialized extends AsrsInboundListEvent {
  const AsrsInboundListInitialized({this.keyword});

  final String? keyword;

  @override
  List<Object?> get props => [keyword];
}

class AsrsInboundListKeywordChanged extends AsrsInboundListEvent {
  const AsrsInboundListKeywordChanged(this.keyword);

  final String keyword;

  @override
  List<Object?> get props => [keyword];
}

class AsrsInboundListRefreshed extends AsrsInboundListEvent {
  const AsrsInboundListRefreshed();
}
