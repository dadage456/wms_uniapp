import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:wms_app/app_module.dart';
import 'package:wms_app/modules/floor_transfer/services/floor_transfer_service.dart';
import 'package:wms_app/modules/floor_transfer/transfer_flow/bloc/floor_transfer_bloc.dart';
import 'package:wms_app/modules/floor_transfer/transfer_flow/floor_transfer_page.dart';
import 'package:wms_app/services/dio_client.dart';

class FloorTransferModule extends Module {
  @override
  List<Module> get imports => [AppModule()];

  @override
  void binds(Injector i) {
    i.addSingleton<FloorTransferService>(
      () => FloorTransferService(i.get<DioClient>().dio),
    );

    i.add<FloorTransferBloc>(
      () => FloorTransferBloc(service: i.get<FloorTransferService>()),
    );
  }

  @override
  void routes(RouteManager r) {
    r.child(
      '/',
      child: (context) {
        final data = Modular.args.data;
        final initialTab = data is Map && data['initialTab'] is int
            ? data['initialTab'] as int
            : 0;
        return BlocProvider(
          create: (context) => Modular.get<FloorTransferBloc>(),
          child: FloorTransferPage(initialTab: initialTab),
        );
      },
    );
  }
}
