import 'package:equatable/equatable.dart';
import 'package:wms_app/modules/floor_exception/message_center/task_messages/models/exception_task_message.dart';

abstract class TaskMessageEvent extends Equatable {
  const TaskMessageEvent();

  @override
  List<Object?> get props => [];
}

class TaskMessageSearchSubmitted extends TaskMessageEvent {
  const TaskMessageSearchSubmitted(this.keyword);

  final String keyword;

  @override
  List<Object?> get props => [keyword];
}

class TaskMessageRefreshRequested extends TaskMessageEvent {
  const TaskMessageRefreshRequested();
}

class TaskMessageConfirmRequested extends TaskMessageEvent {
  const TaskMessageConfirmRequested(this.message);

  final ExceptionTaskMessage message;

  @override
  List<Object?> get props => [message];
}

class TaskMessageClearFeedback extends TaskMessageEvent {
  const TaskMessageClearFeedback();
}
