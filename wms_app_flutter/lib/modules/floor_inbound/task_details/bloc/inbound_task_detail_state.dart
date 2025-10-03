import 'package:equatable/equatable.dart';
import 'package:wms_app/modules/floor_inbound/task_details/models/inbound_task_item.dart';

class InboundTaskDetailState extends Equatable {
  const InboundTaskDetailState({
    this.isLoading = false,
    this.items = const [],
    this.selectedIds = const <String>{},
    this.errorMessage,
    this.query,
  });

  final bool isLoading;
  final List<InboundTaskItem> items;
  final Set<String> selectedIds;
  final String? errorMessage;
  final InboundTaskItemQuery? query;

  InboundTaskDetailState copyWith({
    bool? isLoading,
    List<InboundTaskItem>? items,
    Set<String>? selectedIds,
    String? errorMessage,
    InboundTaskItemQuery? query,
  }) {
    return InboundTaskDetailState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      selectedIds: selectedIds ?? this.selectedIds,
      errorMessage: errorMessage,
      query: query ?? this.query,
    );
  }

  @override
  List<Object?> get props => [isLoading, items, selectedIds, errorMessage, query];
}
