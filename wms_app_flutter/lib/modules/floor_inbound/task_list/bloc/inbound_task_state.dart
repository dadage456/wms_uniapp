import 'package:equatable/equatable.dart';

class InboundTaskState extends Equatable {
  const InboundTaskState({this.finishFlag = '0'});

  final String finishFlag;

  InboundTaskState copyWith({String? finishFlag}) {
    return InboundTaskState(
      finishFlag: finishFlag ?? this.finishFlag,
    );
  }

  @override
  List<Object?> get props => [finishFlag];
}
