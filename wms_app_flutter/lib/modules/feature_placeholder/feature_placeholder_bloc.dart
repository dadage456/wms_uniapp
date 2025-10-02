import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'feature_placeholder_state.dart';

class FeaturePlaceholderBloc
    extends Cubit<FeaturePlaceholderState> {
  FeaturePlaceholderBloc({required FeaturePlaceholderInfo info})
      : super(FeaturePlaceholderState.initial(info));
}

class FeaturePlaceholderInfo extends Equatable {
  final String title;
  final String description;
  final List<String> todoItems;

  const FeaturePlaceholderInfo({
    required this.title,
    required this.description,
    this.todoItems = const [],
  });

  @override
  List<Object?> get props => [title, description, todoItems];
}
