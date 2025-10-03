import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:wms_app/app_module.dart';
import 'package:wms_app/modules/floor_exception/exception_collection/bloc/floor_exception_collect_bloc.dart';
import 'package:wms_app/modules/floor_exception/exception_collection/floor_exception_collection_page.dart';
import 'package:wms_app/modules/floor_exception/exception_collection/models/floor_exception_collection_args.dart';
import 'package:wms_app/modules/floor_exception/exception_dashboard/floor_exception_dashboard_page.dart';
import 'package:wms_app/modules/floor_exception/exception_task_list/bloc/exception_task_list_bloc.dart';
import 'package:wms_app/modules/floor_exception/services/floor_exception_service.dart';
import 'package:wms_app/services/dio_client.dart';
import 'package:wms_app/services/user_manager.dart';

class FloorExceptionModule extends Module {
  @override
  List<Module> get imports => [AppModule()];

  @override
  void binds(Injector i) {
    i.addSingleton<FloorExceptionService>(
      () => FloorExceptionService(i.get<DioClient>().dio),
    );

    i.add<ExceptionTaskListBloc>(
      () => ExceptionTaskListBloc(
        service: i.get<FloorExceptionService>(),
        userManager: i.get<UserManager>(),
      ),
    );

    i.add<FloorExceptionCollectBloc>(
      () => FloorExceptionCollectBloc(
        service: i.get<FloorExceptionService>(),
      ),
    );
  }

  @override
  void routes(RouteManager r) {
    r.child(
      '/',
      child: (context) {
        final args = Modular.args.data;
        int initialTab = 0;
        if (args is Map<String, dynamic>) {
          initialTab = args['initialTab'] is int ? args['initialTab'] as int : 0;
        } else if (args is int) {
          initialTab = args;
        }

        return BlocProvider(
          create: (context) => Modular.get<ExceptionTaskListBloc>(),
          child: FloorExceptionDashboardPage(initialTab: initialTab),
        );
      },
    );

    r.child(
      '/collect',
      child: (context) {
        final args = Modular.args.data;
        final collectionArgs =
            args is FloorExceptionCollectionArgs ? args : const FloorExceptionCollectionArgs();
        return BlocProvider(
          create: (context) => Modular.get<FloorExceptionCollectBloc>(),
          child: FloorExceptionCollectionPage(args: collectionArgs),
        );
      },
    );
  }
}
