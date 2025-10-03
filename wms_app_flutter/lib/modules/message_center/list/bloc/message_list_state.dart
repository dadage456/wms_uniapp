import 'package:equatable/equatable.dart';
import 'package:wms_app/modules/message_center/models/notice.dart';

enum MessageListStatus { initial, loading, success, failure }

class MessageListState extends Equatable {
  const MessageListState({
    this.status = MessageListStatus.initial,
    this.notices = const <NoticeSummary>[],
    this.errorMessage,
    this.unreadCount = 0,
  });

  final MessageListStatus status;
  final List<NoticeSummary> notices;
  final String? errorMessage;
  final int unreadCount;

  MessageListState copyWith({
    MessageListStatus? status,
    List<NoticeSummary>? notices,
    String? errorMessage,
    int? unreadCount,
    bool clearErrorMessage = false,
  }) {
    return MessageListState(
      status: status ?? this.status,
      notices: notices ?? this.notices,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  List<Object?> get props => [status, notices, errorMessage, unreadCount];
}
