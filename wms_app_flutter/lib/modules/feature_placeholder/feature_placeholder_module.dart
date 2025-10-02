import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'feature_placeholder_bloc.dart';
import 'feature_placeholder_page.dart';

class FeaturePlaceholderModule extends Module {
  final FeaturePlaceholderInfo info;

  FeaturePlaceholderModule({required this.info});

  @override
  void binds(Injector i) {
    i.add<FeaturePlaceholderBloc>(() => FeaturePlaceholderBloc(info: info));
  }

  @override
  void routes(RouteManager r) {
    r.child(
      '/',
      child: (_) => BlocProvider(
        create: (context) => Modular.get<FeaturePlaceholderBloc>(),
        child: const FeaturePlaceholderPage(),
      ),
    );
  }
}
