import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:wms_app/app_module.dart';
import 'package:wms_app/modules/pull_feeding/bloc/pull_feeding_bloc.dart';
import 'package:wms_app/modules/pull_feeding/pages/pull_feeding_page.dart';
import 'package:wms_app/modules/pull_feeding/services/pull_feeding_service.dart';
import 'package:wms_app/services/dio_client.dart';

class PullFeedingModule extends Module {
  @override
  List<Module> get imports => [AppModule()];

  @override
  void binds(Injector i) {
    i.addSingleton<PullFeedingService>(
      () => PullFeedingService(i.get<DioClient>().dio),
    );

    i.add<PullFeedingBloc>(
      () => PullFeedingBloc(service: i.get<PullFeedingService>()),
    );
  }

  @override
  void routes(RouteManager r) {
    r.child(
      '/',
      child: (context) => BlocProvider(
        create: (_) => Modular.get<PullFeedingBloc>(),
        child: const PullFeedingPage(),
      ),
    );
  }
}
