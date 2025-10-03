import 'package:equatable/equatable.dart';

abstract class SapExceptionEvent extends Equatable {
  const SapExceptionEvent();

  @override
  List<Object?> get props => [];
}

class SapExceptionSearchSubmitted extends SapExceptionEvent {
  const SapExceptionSearchSubmitted(this.keyword);

  final String keyword;

  @override
  List<Object?> get props => [keyword];
}

class SapExceptionRefreshRequested extends SapExceptionEvent {
  const SapExceptionRefreshRequested();
}

class SapExceptionClearError extends SapExceptionEvent {
  const SapExceptionClearError();
}
