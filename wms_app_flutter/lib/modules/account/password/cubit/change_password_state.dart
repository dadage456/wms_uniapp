part of 'change_password_cubit.dart';

class ChangePasswordState extends Equatable {
  const ChangePasswordState({
    this.oldPassword = '',
    this.newPassword = '',
    this.confirmPassword = '',
    this.submitting = false,
    this.success = false,
    this.errorMessage,
  });

  final String oldPassword;
  final String newPassword;
  final String confirmPassword;
  final bool submitting;
  final bool success;
  final String? errorMessage;

  bool get hasError => (errorMessage ?? '').isNotEmpty;

  ChangePasswordState copyWith({
    String? oldPassword,
    String? newPassword,
    String? confirmPassword,
    bool? submitting,
    bool? success,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ChangePasswordState(
      oldPassword: oldPassword ?? this.oldPassword,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      submitting: submitting ?? this.submitting,
      success: success ?? this.success,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        oldPassword,
        newPassword,
        confirmPassword,
        submitting,
        success,
        errorMessage,
      ];
}
