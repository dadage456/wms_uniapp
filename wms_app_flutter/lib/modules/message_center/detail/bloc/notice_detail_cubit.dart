import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/modules/message_center/models/notice.dart';
import 'package:wms_app/modules/message_center/services/message_center_service.dart';
import 'package:wms_app/services/user_manager.dart';

enum NoticeDetailStatus { initial, loading, success, failure }

class NoticeDetailState {
  const NoticeDetailState({
    this.status = NoticeDetailStatus.initial,
    this.detail,
    this.errorMessage,
  });

  final NoticeDetailStatus status;
  final NoticeDetail? detail;
  final String? errorMessage;

  NoticeDetailState copyWith({
    NoticeDetailStatus? status,
    NoticeDetail? detail,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return NoticeDetailState(
      status: status ?? this.status,
      detail: detail ?? this.detail,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class NoticeDetailCubit extends Cubit<NoticeDetailState> {
  NoticeDetailCubit({
    required MessageCenterService service,
    required UserManager userManager,
  })  : _service = service,
        _userManager = userManager,
        super(const NoticeDetailState());

  final MessageCenterService _service;
  final UserManager _userManager;

  Future<void> loadNotice(String? noticeId) async {
    if (noticeId == null || noticeId.isEmpty) {
      emit(
        state.copyWith(
          status: NoticeDetailStatus.failure,
          errorMessage: '缺少公告ID',
        ),
      );
      return;
    }

    emit(state.copyWith(status: NoticeDetailStatus.loading));
    try {
      final detail = await _service.fetchNoticeDetail(noticeId);
      final changed = await _userManager.markNoticeAsRead(noticeId);
      if (changed && _userManager.unreadNoticeCount > 0) {
        _userManager.updateUnreadNoticeCount(_userManager.unreadNoticeCount - 1);
      }
      emit(
        state.copyWith(
          status: NoticeDetailStatus.success,
          detail: detail,
          clearErrorMessage: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: NoticeDetailStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
