import 'package:equatable/equatable.dart';

abstract class AsrsInventoryListEvent extends Equatable {
  const AsrsInventoryListEvent();

  @override
  List<Object?> get props => [];
}

class AsrsInventoryListInitialized extends AsrsInventoryListEvent {
  const AsrsInventoryListInitialized({this.keyword});

  final String? keyword;

  @override
  List<Object?> get props => [keyword];
}

class AsrsInventoryListKeywordChanged extends AsrsInventoryListEvent {
  const AsrsInventoryListKeywordChanged(this.keyword);

  final String keyword;

  @override
  List<Object?> get props => [keyword];
}

class AsrsInventoryListToggleProcessing extends AsrsInventoryListEvent {
  const AsrsInventoryListToggleProcessing(this.onlyProcessing);

  final bool onlyProcessing;

  @override
  List<Object?> get props => [onlyProcessing];
}

class AsrsInventoryListRefreshed extends AsrsInventoryListEvent {
  const AsrsInventoryListRefreshed();
}
