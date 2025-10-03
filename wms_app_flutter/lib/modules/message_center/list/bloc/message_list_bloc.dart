import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/modules/message_center/list/bloc/message_list_event.dart';
import 'package:wms_app/modules/message_center/list/bloc/message_list_state.dart';
import 'package:wms_app/modules/message_center/models/notice.dart';
import 'package:wms_app/modules/message_center/services/message_center_service.dart';
import 'package:wms_app/services/user_manager.dart';

class MessageListBloc extends Bloc<MessageListEvent, MessageListState> {
  MessageListBloc({
    required MessageCenterService service,
    required UserManager userManager,
  })  : _service = service,
        _userManager = userManager,
        super(const MessageListState()) {
    on<MessageListSubscriptionRequested>(_onSubscriptionRequested);
    on<MessageListRefreshRequested>(_onRefreshRequested);
    on<MessageListMarkAsReadRequested>(_onMarkAsReadRequested);
  }

  final MessageCenterService _service;
  final UserManager _userManager;

  Future<void> _onSubscriptionRequested(
    MessageListSubscriptionRequested event,
    Emitter<MessageListState> emit,
  ) async {
    emit(state.copyWith(status: MessageListStatus.loading, clearErrorMessage: true));
    await _userManager.ensureNoticeHistoryLoaded();
    await _loadNotices(emit, isRefresh: false);
  }

  Future<void> _onRefreshRequested(
    MessageListRefreshRequested event,
    Emitter<MessageListState> emit,
  ) async {
    await _loadNotices(emit, isRefresh: true);
  }

  Future<void> _loadNotices(
    Emitter<MessageListState> emit, {
    required bool isRefresh,
  }) async {
    try {
      if (isRefresh) {
        emit(state.copyWith(status: MessageListStatus.loading));
      }
      final notices = await _service.fetchNotices();
      final decorated = _decorateWithReadState(notices);
      final unread = _calculateUnread(decorated);
      _userManager.updateUnreadNoticeCount(unread);
      emit(
        state.copyWith(
          status: MessageListStatus.success,
          notices: decorated,
          unreadCount: unread,
          clearErrorMessage: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: MessageListStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> _onMarkAsReadRequested(
    MessageListMarkAsReadRequested event,
    Emitter<MessageListState> emit,
  ) async {
    if (event.noticeId.isEmpty) return;
    final changed = await _userManager.markNoticeAsRead(event.noticeId);
    final updated = state.notices
        .map(
          (notice) => notice.noticeId == event.noticeId
              ? notice.copyWith(isRead: true)
              : notice,
        )
        .toList();
    final unread = _calculateUnread(updated);
    if (changed) {
      _userManager.updateUnreadNoticeCount(unread);
    }
    emit(
      state.copyWith(
        notices: updated,
        unreadCount: unread,
      ),
    );
  }

  List<NoticeSummary> _decorateWithReadState(List<NoticeSummary> notices) {
    return notices
        .map(
          (notice) => notice.copyWith(
            isRead: _userManager.isNoticeReadSync(notice.noticeId),
          ),
        )
        .toList();
  }

  int _calculateUnread(List<NoticeSummary> notices) {
    return notices.where((notice) => !notice.isRead).length;
  }
}
