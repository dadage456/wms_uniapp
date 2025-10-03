import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/modules/account/services/account_service.dart';
import 'package:wms_app/utils/error_handler.dart';

part 'change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit({required AccountService service})
      : _service = service,
        super(const ChangePasswordState());

  final AccountService _service;

  void updateOldPassword(String value) {
    emit(state.copyWith(oldPassword: value, clearError: true));
  }

  void updateNewPassword(String value) {
    emit(state.copyWith(newPassword: value, clearError: true));
  }

  void updateConfirmPassword(String value) {
    emit(state.copyWith(confirmPassword: value, clearError: true));
  }

  Future<bool> submit() async {
    final validation = _validate();
    if (validation != null) {
      emit(state.copyWith(errorMessage: validation));
      return false;
    }

    emit(state.copyWith(submitting: true, clearError: true));

    try {
      await _service.changePassword(
        oldPassword: state.oldPassword,
        newPassword: state.newPassword,
      );
      emit(state.copyWith(submitting: false, success: true));
      return true;
    } catch (e) {
      emit(state.copyWith(
        submitting: false,
        errorMessage: ErrorHandler.handleError(e),
      ));
      return false;
    }
  }

  void acknowledgeSuccess() {
    if (state.success) {
      emit(state.copyWith(success: false));
    }
  }

  String? _validate() {
    if (state.oldPassword.isEmpty) {
      return '请输入原密码';
    }
    if (state.newPassword.isEmpty) {
      return '请输入新密码';
    }
    if (state.confirmPassword.isEmpty) {
      return '请再次输入新密码';
    }
    if (state.newPassword != state.confirmPassword) {
      return '两次输入的新密码不一致';
    }
    if (state.newPassword == state.oldPassword) {
      return '新密码不能与原密码相同';
    }
    if (state.newPassword.length < 6) {
      return '新密码长度至少为6位';
    }
    return null;
  }
}
