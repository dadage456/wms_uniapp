part of 'account_profile_cubit.dart';

class AccountProfileState extends Equatable {
  const AccountProfileState({
    this.loading = false,
    this.refreshing = false,
    this.profile,
    this.errorMessage,
  });

  final bool loading;
  final bool refreshing;
  final AccountProfile? profile;
  final String? errorMessage;

  bool get hasError => (errorMessage ?? '').isNotEmpty;
  bool get ready => profile != null;

  AccountProfileState copyWith({
    bool? loading,
    bool? refreshing,
    AccountProfile? profile,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AccountProfileState(
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      profile: profile ?? this.profile,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [loading, refreshing, profile, errorMessage];
}
