import 'package:equatable/equatable.dart';
import 'package:wms_app/modules/asrs_outbound/models/asrs_outbound_models.dart';

abstract class AsrsOutboundDetailEvent extends Equatable {
  const AsrsOutboundDetailEvent();

  @override
  List<Object?> get props => [];
}

class AsrsOutboundDetailStarted extends AsrsOutboundDetailEvent {
  const AsrsOutboundDetailStarted(this.task, {this.keyword});

  final AsrsOutboundTask task;
  final String? keyword;

  @override
  List<Object?> get props => [task, keyword];
}

class AsrsOutboundDetailSearchChanged extends AsrsOutboundDetailEvent {
  const AsrsOutboundDetailSearchChanged(this.keyword);

  final String keyword;

  @override
  List<Object?> get props => [keyword];
}

class AsrsOutboundDetailSelectionToggled extends AsrsOutboundDetailEvent {
  const AsrsOutboundDetailSelectionToggled(this.taskItemId, this.selected);

  final String taskItemId;
  final bool selected;

  @override
  List<Object?> get props => [taskItemId, selected];
}

class AsrsOutboundDetailToggleAll extends AsrsOutboundDetailEvent {
  const AsrsOutboundDetailToggleAll(this.selectAll);

  final bool selectAll;

  @override
  List<Object?> get props => [selectAll];
}

class AsrsOutboundDetailReceiveRequested extends AsrsOutboundDetailEvent {
  const AsrsOutboundDetailReceiveRequested({required this.cancel});

  final bool cancel;

  @override
  List<Object?> get props => [cancel];
}
