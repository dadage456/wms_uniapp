import 'package:equatable/equatable.dart';

class SapExceptionState extends Equatable {
  const SapExceptionState({this.errorMessage});

  final String? errorMessage;

  SapExceptionState copyWith({String? errorMessage}) {
    return SapExceptionState(errorMessage: errorMessage);
  }

  @override
  List<Object?> get props => [errorMessage];
}
