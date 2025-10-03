import 'package:equatable/equatable.dart';
import 'package:wms_app/modules/asrs_inventory/models/asrs_inventory_models.dart';

abstract class AsrsInventoryDetailEvent extends Equatable {
  const AsrsInventoryDetailEvent();

  @override
  List<Object?> get props => [];
}

class AsrsInventoryDetailLoaded extends AsrsInventoryDetailEvent {
  const AsrsInventoryDetailLoaded({required this.task});

  final AsrsInventoryTask task;

  @override
  List<Object?> get props => [task];
}

class AsrsInventoryDetailSearchChanged extends AsrsInventoryDetailEvent {
  const AsrsInventoryDetailSearchChanged(this.keyword);

  final String keyword;

  @override
  List<Object?> get props => [keyword];
}

class AsrsInventoryDetailRefreshed extends AsrsInventoryDetailEvent {
  const AsrsInventoryDetailRefreshed();
}
