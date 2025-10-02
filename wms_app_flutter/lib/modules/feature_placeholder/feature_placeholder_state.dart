part of 'feature_placeholder_bloc.dart';

class FeaturePlaceholderState extends Equatable {
  final FeaturePlaceholderInfo info;

  const FeaturePlaceholderState({required this.info});

  factory FeaturePlaceholderState.initial(FeaturePlaceholderInfo info) {
    return FeaturePlaceholderState(info: info);
  }

  @override
  List<Object?> get props => [info];
}
