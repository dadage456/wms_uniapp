import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:wms_app/modules/account/models/account_profile.dart';
import 'package:wms_app/modules/account/services/account_service.dart';
import 'package:wms_app/utils/error_handler.dart';

part 'account_profile_state.dart';

class AccountProfileCubit extends Cubit<AccountProfileState> {
  AccountProfileCubit({required AccountService service})
      : _service = service,
        super(const AccountProfileState());

  final AccountService _service;

  Future<void> loadProfile({bool refresh = false}) async {
    if (refresh) {
      emit(state.copyWith(refreshing: true, clearError: true));
    } else {
      emit(state.copyWith(loading: true, clearError: true));
    }

    try {
      final profile = await _service.fetchProfile();
      emit(state.copyWith(
        loading: false,
        refreshing: false,
        profile: profile,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        loading: false,
        refreshing: false,
        errorMessage: ErrorHandler.handleError(e),
      ));
    }
  }
}
