import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:wms_app/app_module.dart';
import 'package:wms_app/modules/asrs_outbound/collection/asrs_outbound_collection_page.dart';
import 'package:wms_app/modules/asrs_outbound/collection/bloc/asrs_outbound_collect_bloc.dart';
import 'package:wms_app/modules/asrs_outbound/command_center/asrs_command_page.dart';
import 'package:wms_app/modules/asrs_outbound/command_center/bloc/asrs_command_bloc.dart';
import 'package:wms_app/modules/asrs_outbound/models/asrs_outbound_models.dart';
import 'package:wms_app/modules/asrs_outbound/services/asrs_outbound_service.dart';
import 'package:wms_app/modules/asrs_outbound/task_detail/asrs_outbound_task_detail_page.dart';
import 'package:wms_app/modules/asrs_outbound/task_detail/bloc/asrs_outbound_detail_bloc.dart';
import 'package:wms_app/modules/asrs_outbound/task_list/asrs_outbound_task_list_page.dart';
import 'package:wms_app/modules/asrs_outbound/task_list/bloc/asrs_outbound_list_bloc.dart';
import 'package:wms_app/services/dio_client.dart';

class AsrsOutboundModule extends Module {
  @override
  List<Module> get imports => [AppModule()];

  @override
  void binds(Injector i) {
    i.addSingleton<AsrsOutboundService>(
      () => AsrsOutboundService(i.get<DioClient>().dio),
    );

    i.add<AsrsOutboundListBloc>(
      () => AsrsOutboundListBloc(service: i.get<AsrsOutboundService>()),
    );
    i.add<AsrsOutboundDetailBloc>(
      () => AsrsOutboundDetailBloc(service: i.get<AsrsOutboundService>()),
    );
    i.add<AsrsOutboundCollectBloc>(
      () => AsrsOutboundCollectBloc(service: i.get<AsrsOutboundService>()),
    );
    i.add<AsrsCommandBloc>(
      () => AsrsCommandBloc(service: i.get<AsrsOutboundService>()),
    );
  }

  @override
  void routes(RouteManager r) {
    r.child(
      '/',
      child: (_) => BlocProvider(
        create: (context) => Modular.get<AsrsOutboundListBloc>(),
        child: const AsrsOutboundTaskListPage(),
      ),
    );

    r.child(
      '/detail',
      child: (_) {
        final task = Modular.args.data as AsrsOutboundTask;
        return BlocProvider(
          create: (context) => Modular.get<AsrsOutboundDetailBloc>(),
          child: AsrsOutboundTaskDetailPage(task: task),
        );
      },
    );

    r.child(
      '/collect',
      child: (_) {
        final task = Modular.args.data as AsrsOutboundTask;
        return BlocProvider(
          create: (context) => Modular.get<AsrsOutboundCollectBloc>(),
          child: AsrsOutboundCollectionPage(task: task),
        );
      },
    );

    r.child(
      '/commands',
      child: (_) {
        final task = Modular.args.data as AsrsOutboundTask;
        return BlocProvider(
          create: (context) => Modular.get<AsrsCommandBloc>(),
          child: AsrsCommandPage(task: task),
        );
      },
    );
  }
}
