import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:wms_app/app_module.dart';
import 'package:wms_app/modules/floor_inbound/collection_task/bloc/inbound_collection_bloc.dart';
import 'package:wms_app/modules/floor_inbound/collection_task/inbound_collection_page.dart';
import 'package:wms_app/modules/floor_inbound/services/floor_inbound_service.dart';
import 'package:wms_app/modules/floor_inbound/task_details/bloc/inbound_task_detail_bloc.dart';
import 'package:wms_app/modules/floor_inbound/task_details/inbound_task_detail_page.dart';
import 'package:wms_app/modules/floor_inbound/task_list/bloc/inbound_task_bloc.dart';
import 'package:wms_app/modules/floor_inbound/task_list/inbound_task_list_page.dart';
import 'package:wms_app/modules/floor_inbound/task_list/models/inbound_task.dart';
import 'package:wms_app/modules/floor_inbound/task_receive/receive_task_page.dart';
import 'package:wms_app/services/dio_client.dart';
import 'package:wms_app/services/user_manager.dart';

class FloorInboundModule extends Module {
  @override
  List<Module> get imports => [AppModule()];

  @override
  void binds(Injector i) {
    i.addSingleton<FloorInboundService>(() => FloorInboundService(i.get<DioClient>().dio));

    i.add<InboundTaskBloc>(
      () => InboundTaskBloc(
        service: i.get<FloorInboundService>(),
        userManager: i.get<UserManager>(),
      ),
    );

    i.add<InboundTaskDetailBloc>(
      () => InboundTaskDetailBloc(i.get<FloorInboundService>()),
    );

    i.add<InboundCollectionBloc>(
      () => InboundCollectionBloc(i.get<FloorInboundService>()),
    );
  }

  @override
  void routes(RouteManager r) {
    r.child(
      '/',
      child: (context) => BlocProvider(
        create: (_) => Modular.get<InboundTaskBloc>(),
        child: const InboundTaskListPage(),
      ),
    );

    r.child(
      '/list',
      child: (context) => BlocProvider(
        create: (_) => Modular.get<InboundTaskBloc>(),
        child: const InboundTaskListPage(),
      ),
    );

    r.child(
      '/detail/:inTaskId',
      child: (context) {
        final args = Modular.args;
        final task = args.data['task'] as InboundTask;
        final workStation = args.data['workStation'] as String? ?? task.workStation;
        final receiveMode = args.data['receiveMode'] as bool? ?? false;
        return BlocProvider(
          create: (_) => Modular.get<InboundTaskDetailBloc>(),
          child: InboundTaskDetailPage(
            task: task,
            workStation: workStation,
            receiveMode: receiveMode,
          ),
        );
      },
    );

    r.child(
      '/collect/:inTaskNo',
      child: (context) {
        final args = Modular.args;
        final task = args.data['task'] as InboundTask;
        final userId = Modular.get<UserManager>().userInfo?.userId ?? 0;
        return BlocProvider(
          create: (_) => Modular.get<InboundCollectionBloc>(),
          child: InboundCollectionPage(task: task, userId: userId),
        );
      },
    );

    r.child(
      '/receive',
      child: (context) => BlocProvider(
        create: (_) => Modular.get<InboundTaskBloc>(),
        child: const InboundReceiveTaskPage(),
      ),
    );
  }
}
