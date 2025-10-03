import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:wms_app/app_module.dart';
import 'package:wms_app/modules/asrs_inventory/collection/asrs_inventory_collection_page.dart';
import 'package:wms_app/modules/asrs_inventory/collection/bloc/asrs_inventory_collect_bloc.dart';
import 'package:wms_app/modules/asrs_inventory/command_center/asrs_inventory_command_page.dart';
import 'package:wms_app/modules/asrs_inventory/command_center/bloc/asrs_inventory_command_bloc.dart';
import 'package:wms_app/modules/asrs_inventory/command_center/bloc/asrs_inventory_command_event.dart';
import 'package:wms_app/modules/asrs_inventory/models/asrs_inventory_models.dart';
import 'package:wms_app/modules/asrs_inventory/services/asrs_inventory_service.dart';
import 'package:wms_app/modules/asrs_inventory/task_detail/asrs_inventory_task_detail_page.dart';
import 'package:wms_app/modules/asrs_inventory/task_detail/bloc/asrs_inventory_detail_bloc.dart';
import 'package:wms_app/modules/asrs_inventory/task_detail/bloc/asrs_inventory_detail_event.dart';
import 'package:wms_app/modules/asrs_inventory/task_list/asrs_inventory_task_list_page.dart';
import 'package:wms_app/modules/asrs_inventory/task_list/bloc/asrs_inventory_list_bloc.dart';
import 'package:wms_app/modules/asrs_inventory/task_list/bloc/asrs_inventory_list_event.dart';
import 'package:wms_app/services/dio_client.dart';

class AsrsInventoryModule extends Module {
  @override
  List<Module> get imports => [AppModule()];

  @override
  void binds(Injector i) {
    i.addSingleton<AsrsInventoryService>(
      () => AsrsInventoryService(i.get<DioClient>().dio),
    );

    i.add<AsrsInventoryListBloc>(
      () => AsrsInventoryListBloc(service: i.get<AsrsInventoryService>()),
    );
    i.add<AsrsInventoryDetailBloc>(
      () => AsrsInventoryDetailBloc(service: i.get<AsrsInventoryService>()),
    );
    i.add<AsrsInventoryCollectBloc>(
      () => AsrsInventoryCollectBloc(service: i.get<AsrsInventoryService>()),
    );
    i.add<AsrsInventoryCommandBloc>(
      () => AsrsInventoryCommandBloc(service: i.get<AsrsInventoryService>()),
    );
  }

  @override
  void routes(RouteManager r) {
    r.child(
      '/',
      child: (_) => BlocProvider(
        create: (_) => Modular.get<AsrsInventoryListBloc>()
          ..add(const AsrsInventoryListInitialized()),
        child: const AsrsInventoryTaskListPage(),
      ),
    );

    r.child(
      '/detail',
      child: (_) {
        final task = Modular.args.data as AsrsInventoryTask;
        return BlocProvider(
          create: (_) => Modular.get<AsrsInventoryDetailBloc>()
            ..add(AsrsInventoryDetailLoaded(task: task)),
          child: AsrsInventoryTaskDetailPage(task: task),
        );
      },
    );

    r.child(
      '/collect',
      child: (_) {
        final task = Modular.args.data as AsrsInventoryTask;
        return BlocProvider(
          create: (_) => Modular.get<AsrsInventoryCollectBloc>(),
          child: AsrsInventoryCollectionPage(task: task),
        );
      },
    );

    r.child(
      '/commands',
      child: (_) {
        final task = Modular.args.data as AsrsInventoryTask;
        return BlocProvider(
          create: (_) => Modular.get<AsrsInventoryCommandBloc>()
            ..add(AsrsInventoryCommandStarted(task: task)),
          child: AsrsInventoryCommandPage(task: task),
        );
      },
    );
  }
}
