import 'package:equatable/equatable.dart';
import 'package:wms_app/modules/asrs_inbound/models/asrs_inbound_models.dart';

abstract class AsrsInboundDetailEvent extends Equatable {
  const AsrsInboundDetailEvent();

  @override
  List<Object?> get props => [];
}

class AsrsInboundDetailLoaded extends AsrsInboundDetailEvent {
  const AsrsInboundDetailLoaded({required this.task});

  final AsrsInboundTask task;

  @override
  List<Object?> get props => [task];
}

class AsrsInboundDetailSearchChanged extends AsrsInboundDetailEvent {
  const AsrsInboundDetailSearchChanged(this.keyword);

  final String keyword;

  @override
  List<Object?> get props => [keyword];
}

class AsrsInboundDetailRefreshed extends AsrsInboundDetailEvent {
  const AsrsInboundDetailRefreshed();
}
