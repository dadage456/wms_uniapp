import 'package:equatable/equatable.dart';

abstract class InventoryTaskDetailEvent extends Equatable {
  const InventoryTaskDetailEvent();

  @override
  List<Object?> get props => [];
}

class InventoryTaskDetailLoaded extends InventoryTaskDetailEvent {
  const InventoryTaskDetailLoaded({required this.taskComment, required this.taskNo});

  final String taskComment;
  final String taskNo;

  @override
  List<Object?> get props => [taskComment, taskNo];
}

class InventoryTaskDetailRefreshed extends InventoryTaskDetailEvent {
  const InventoryTaskDetailRefreshed();
}
