import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:wms_app/app_module.dart';
import 'package:wms_app/modules/floor_inventory/services/floor_inventory_service.dart';
import 'package:wms_app/modules/floor_inventory/task_collect/bloc/inventory_collect_bloc.dart';
import 'package:wms_app/modules/floor_inventory/task_collect/inventory_task_collect_page.dart';
import 'package:wms_app/modules/floor_inventory/task_details/bloc/inventory_task_detail_bloc.dart';
import 'package:wms_app/modules/floor_inventory/task_details/inventory_task_detail_page.dart';
import 'package:wms_app/modules/floor_inventory/task_list/models/inventory_task.dart';
import 'package:wms_app/modules/floor_inventory/task_list/bloc/inventory_task_list_bloc.dart';
import 'package:wms_app/modules/floor_inventory/task_list/inventory_task_list_page.dart';
import 'package:wms_app/modules/floor_inventory/task_receive/bloc/inventory_task_receive_bloc.dart';
import 'package:wms_app/modules/floor_inventory/task_receive/inventory_task_receive_page.dart';
import 'package:wms_app/services/dio_client.dart';
import 'package:wms_app/services/user_manager.dart';

class FloorInventoryModule extends Module {
  @override
  List<Module> get imports => [AppModule()];

  @override
  void binds(Injector i) {
    i.addSingleton<FloorInventoryService>(
      () => FloorInventoryService(i.get<DioClient>().dio),
    );

    i.add<InventoryTaskListBloc>(
      () => InventoryTaskListBloc(
        service: i.get<FloorInventoryService>(),
        userManager: i.get<UserManager>(),
      ),
    );

    i.add<InventoryTaskReceiveBloc>(
      () => InventoryTaskReceiveBloc(
        service: i.get<FloorInventoryService>(),
        userManager: i.get<UserManager>(),
      ),
    );

    i.add<InventoryTaskDetailBloc>(
      () => InventoryTaskDetailBloc(
        service: i.get<FloorInventoryService>(),
      ),
    );

    i.add<InventoryCollectBloc>(
      () => InventoryCollectBloc(
        service: i.get<FloorInventoryService>(),
      ),
    );
  }

  @override
  void routes(RouteManager r) {
    r.child(
      '/',
      child: (context) => BlocProvider(
        create: (context) => Modular.get<InventoryTaskListBloc>(),
        child: const InventoryTaskListPage(),
      ),
    );

    r.child(
      '/list',
      child: (context) => BlocProvider(
        create: (context) => Modular.get<InventoryTaskListBloc>(),
        child: const InventoryTaskListPage(),
      ),
    );

    r.child(
      '/receive',
      child: (context) => BlocProvider(
        create: (context) => Modular.get<InventoryTaskReceiveBloc>(),
        child: const InventoryTaskReceivePage(),
      ),
    );

    r.child(
      '/detail/:taskNo',
      child: (context) {
        final args = Modular.args;
        final task = args.data?['task'] as InventoryTask?;
        return BlocProvider(
          create: (context) => Modular.get<InventoryTaskDetailBloc>(),
          child: InventoryTaskDetailPage(task: task),
        );
      },
    );

    r.child(
      '/collect/:taskNo',
      child: (context) {
        final args = Modular.args;
        final task = args.data?['task'] as InventoryTask?;
        return BlocProvider(
          create: (context) => Modular.get<InventoryCollectBloc>(),
          child: InventoryTaskCollectPage(task: task),
        );
      },
    );
  }
}
