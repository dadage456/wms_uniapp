import 'package:equatable/equatable.dart';
import 'package:wms_app/modules/floor_exception/exception_task_list/models/exception_task.dart';

abstract class ExceptionTaskListEvent extends Equatable {
  const ExceptionTaskListEvent();

  @override
  List<Object?> get props => [];
}

class ExceptionTaskListSearchSubmitted extends ExceptionTaskListEvent {
  const ExceptionTaskListSearchSubmitted(this.keyword);

  final String keyword;

  @override
  List<Object?> get props => [keyword];
}

class ExceptionTaskListRefreshRequested extends ExceptionTaskListEvent {
  const ExceptionTaskListRefreshRequested();
}

class ExceptionTaskListReprocessRequested extends ExceptionTaskListEvent {
  const ExceptionTaskListReprocessRequested(this.record);

  final ExceptionTaskRecord record;

  @override
  List<Object?> get props => [record];
}

class ExceptionTaskListMessageCleared extends ExceptionTaskListEvent {
  const ExceptionTaskListMessageCleared();
}
