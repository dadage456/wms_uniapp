import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:wms_app/app_module.dart';
import 'package:wms_app/modules/asrs_inbound/collection/asrs_inbound_collection_page.dart';
import 'package:wms_app/modules/asrs_inbound/collection/bloc/asrs_inbound_collect_bloc.dart';
import 'package:wms_app/modules/asrs_inbound/collection/bloc/asrs_inbound_collect_event.dart';
import 'package:wms_app/modules/asrs_inbound/command_center/asrs_inbound_command_page.dart';
import 'package:wms_app/modules/asrs_inbound/command_center/bloc/asrs_inbound_command_bloc.dart';
import 'package:wms_app/modules/asrs_inbound/command_center/bloc/asrs_inbound_command_event.dart';
import 'package:wms_app/modules/asrs_inbound/models/asrs_inbound_models.dart';
import 'package:wms_app/modules/asrs_inbound/services/asrs_inbound_service.dart';
import 'package:wms_app/modules/asrs_inbound/task_detail/asrs_inbound_task_detail_page.dart';
import 'package:wms_app/modules/asrs_inbound/task_detail/bloc/asrs_inbound_detail_bloc.dart';
import 'package:wms_app/modules/asrs_inbound/task_detail/bloc/asrs_inbound_detail_event.dart';
import 'package:wms_app/modules/asrs_inbound/task_list/asrs_inbound_task_list_page.dart';
import 'package:wms_app/modules/asrs_inbound/task_list/bloc/asrs_inbound_list_bloc.dart';
import 'package:wms_app/modules/asrs_inbound/task_list/bloc/asrs_inbound_list_event.dart';
import 'package:wms_app/services/dio_client.dart';

class AsrsInboundModule extends Module {
  @override
  List<Module> get imports => [AppModule()];

  @override
  void binds(Injector i) {
    i.addSingleton<AsrsInboundService>(
      () => AsrsInboundService(i.get<DioClient>().dio),
    );

    i.add<AsrsInboundListBloc>(
      () => AsrsInboundListBloc(service: i.get<AsrsInboundService>()),
    );
    i.add<AsrsInboundDetailBloc>(
      () => AsrsInboundDetailBloc(service: i.get<AsrsInboundService>()),
    );
    i.add<AsrsInboundCollectBloc>(
      () => AsrsInboundCollectBloc(service: i.get<AsrsInboundService>()),
    );
    i.add<AsrsInboundCommandBloc>(
      () => AsrsInboundCommandBloc(service: i.get<AsrsInboundService>()),
    );
  }

  @override
  void routes(RouteManager r) {
    r.child(
      '/',
      child: (_) => BlocProvider(
        create: (_) => Modular.get<AsrsInboundListBloc>()
          ..add(const AsrsInboundListInitialized()),
        child: const AsrsInboundTaskListPage(),
      ),
    );

    r.child(
      '/detail',
      child: (_) {
        final task = Modular.args.data as AsrsInboundTask;
        return BlocProvider(
          create: (_) => Modular.get<AsrsInboundDetailBloc>()
            ..add(AsrsInboundDetailLoaded(task: task)),
          child: AsrsInboundTaskDetailPage(task: task),
        );
      },
    );

    r.child(
      '/collect',
      child: (_) {
        final task = Modular.args.data as AsrsInboundTask;
        return BlocProvider(
          create: (_) => Modular.get<AsrsInboundCollectBloc>()
            ..add(AsrsInboundCollectInitialized(task: task)),
          child: AsrsInboundCollectionPage(task: task),
        );
      },
    );

    r.child(
      '/commands',
      child: (_) {
        final task = Modular.args.data as AsrsInboundTask;
        return BlocProvider(
          create: (_) => Modular.get<AsrsInboundCommandBloc>()
            ..add(AsrsInboundCommandStarted(task: task)),
          child: AsrsInboundCommandPage(task: task),
        );
      },
    );
  }
}
