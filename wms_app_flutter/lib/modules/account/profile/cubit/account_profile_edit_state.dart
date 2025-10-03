part of 'account_profile_edit_cubit.dart';

class AccountProfileEditState extends Equatable {
  const AccountProfileEditState({
    required this.form,
    this.profile,
    this.saving = false,
    this.success = false,
    this.errorMessage,
  });

  factory AccountProfileEditState.initial(AccountProfile profile) {
    return AccountProfileEditState(
      form: profile.user.toUpdateRequest(),
      profile: profile,
    );
  }

  final AccountProfileUpdateRequest form;
  final AccountProfile? profile;
  final bool saving;
  final bool success;
  final String? errorMessage;

  bool get hasError => (errorMessage ?? '').isNotEmpty;

  AccountProfileEditState copyWith({
    AccountProfileUpdateRequest? form,
    AccountProfile? profile,
    bool? saving,
    bool? success,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AccountProfileEditState(
      form: form ?? this.form,
      profile: profile ?? this.profile,
      saving: saving ?? this.saving,
      success: success ?? this.success,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [form, profile, saving, success, errorMessage];
}
