import 'package:equatable/equatable.dart';

abstract class MessageListEvent extends Equatable {
  const MessageListEvent();

  @override
  List<Object?> get props => [];
}

class MessageListSubscriptionRequested extends MessageListEvent {
  const MessageListSubscriptionRequested();
}

class MessageListRefreshRequested extends MessageListEvent {
  const MessageListRefreshRequested();
}

class MessageListMarkAsReadRequested extends MessageListEvent {
  const MessageListMarkAsReadRequested(this.noticeId);

  final String noticeId;

  @override
  List<Object?> get props => [noticeId];
}
