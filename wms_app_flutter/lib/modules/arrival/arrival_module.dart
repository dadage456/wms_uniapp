import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:wms_app/app_module.dart';
import 'package:wms_app/modules/arrival/collection_task/arrival_collection_page.dart';
import 'package:wms_app/modules/arrival/collection_task/bloc/arrival_collection_bloc.dart';
import 'package:wms_app/modules/arrival/services/arrival_service.dart';
import 'package:wms_app/modules/arrival/task_details/arrival_task_detail_page.dart';
import 'package:wms_app/modules/arrival/task_list/arrival_task_list_page.dart';
import 'package:wms_app/modules/arrival/task_list/bloc/arrival_task_list_bloc.dart';
import 'package:wms_app/modules/arrival/task_list/models/arrival_task.dart';
import 'package:wms_app/modules/arrival/task_receive/arrival_task_receive_page.dart';
import 'package:wms_app/modules/arrival/task_receive/bloc/arrival_task_receive_bloc.dart';
import 'package:wms_app/services/dio_client.dart';

class ArrivalModule extends Module {
  @override
  List<Module> get imports => [AppModule()];

  @override
  void binds(Injector i) {
    i.addSingleton<ArrivalService>(
      () => ArrivalService(i.get<DioClient>().dio),
    );

    i.add<ArrivalTaskListBloc>(
      () => ArrivalTaskListBloc(service: i.get<ArrivalService>()),
    );

    i.add<ArrivalTaskReceiveBloc>(
      () => ArrivalTaskReceiveBloc(service: i.get<ArrivalService>()),
    );

    i.add<ArrivalCollectionBloc>(
      () => ArrivalCollectionBloc(service: i.get<ArrivalService>()),
    );
  }

  @override
  void routes(RouteManager r) {
    r.child(
      '/',
      child: (context) => BlocProvider(
        create: (context) => Modular.get<ArrivalTaskListBloc>(),
        child: const ArrivalTaskListPage(),
      ),
    );

    r.child(
      '/list',
      child: (context) => BlocProvider(
        create: (context) => Modular.get<ArrivalTaskListBloc>(),
        child: const ArrivalTaskListPage(),
      ),
    );

    r.child(
      '/receive',
      child: (context) => BlocProvider(
        create: (context) => Modular.get<ArrivalTaskReceiveBloc>(),
        child: const ArrivalTaskReceivePage(),
      ),
    );

    r.child(
      '/detail/:arrivalsBillId',
      child: (context) {
        final args = Modular.args;
        final task = args.data?['task'] as ArrivalTask?;
        final arrivalsBillId = args.params['arrivalsBillId'] ?? '';
        if (task == null) {
          throw ArgumentError('缺少到货任务数据');
        }
        final service = Modular.get<ArrivalService>();
        return ArrivalTaskDetailPage(
          arrivalsBillId: arrivalsBillId,
          task: task,
          service: service,
        );
      },
    );

    r.child(
      '/collect/:arrivalsBillId',
      child: (context) {
        final args = Modular.args;
        final task = args.data?['task'] as ArrivalTask?;
        if (task == null) {
          throw ArgumentError('缺少到货任务数据');
        }
        return BlocProvider(
          create: (context) => Modular.get<ArrivalCollectionBloc>(),
          child: ArrivalCollectionPage(task: task),
        );
      },
    );
  }
}
