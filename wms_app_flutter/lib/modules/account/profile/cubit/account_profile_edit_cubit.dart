import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/modules/account/models/account_profile.dart';
import 'package:wms_app/modules/account/services/account_service.dart';
import 'package:wms_app/utils/error_handler.dart';

part 'account_profile_edit_state.dart';

class AccountProfileEditCubit extends Cubit<AccountProfileEditState> {
  AccountProfileEditCubit({
    required AccountService service,
    required AccountProfile profile,
  })  : _service = service,
        super(AccountProfileEditState.initial(profile));

  final AccountService _service;

  void updateNickName(String value) {
    emit(state.copyWith(
      form: state.form.copyWith(nickName: value.trim()),
      clearError: true,
    ));
  }

  void updatePhone(String value) {
    emit(state.copyWith(
      form: state.form.copyWith(phonenumber: value.trim().isEmpty ? null : value.trim()),
      clearError: true,
    ));
  }

  void updateEmail(String value) {
    emit(state.copyWith(
      form: state.form.copyWith(email: value.trim().isEmpty ? null : value.trim()),
      clearError: true,
    ));
  }

  void updateSex(String? value) {
    emit(state.copyWith(
      form: state.form.copyWith(sex: value),
      clearError: true,
    ));
  }

  Future<AccountProfile?> submit() async {
    if (state.form.nickName.trim().isEmpty) {
      emit(state.copyWith(errorMessage: '请填写用户昵称'));
      return null;
    }

    emit(state.copyWith(saving: true, clearError: true));

    try {
      final updatedProfile = await _service.updateProfile(state.form);
      emit(state.copyWith(
        saving: false,
        success: true,
        profile: updatedProfile,
        form: updatedProfile.user.toUpdateRequest(),
      ));
      return updatedProfile;
    } catch (e) {
      emit(state.copyWith(
        saving: false,
        errorMessage: ErrorHandler.handleError(e),
      ));
      return null;
    }
  }

  void acknowledgeSuccess() {
    if (state.success) {
      emit(state.copyWith(success: false));
    }
  }
}
