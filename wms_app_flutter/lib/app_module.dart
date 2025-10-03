import 'package:flutter_modular/flutter_modular.dart';
import 'package:wms_app/modules/home/lauch_page/splash_page.dart';
import 'package:wms_app/modules/home/login/bloc/login_bloc.dart';
import 'package:wms_app/services/dio_client.dart';
import 'package:wms_app/services/user_manager.dart';
import 'package:wms_app/modules/home/home_page.dart';
import 'package:wms_app/modules/home/login/login_page.dart';
import 'package:wms_app/services/api_service.dart';
import 'modules/outbound/outbound_module.dart';
import 'modules/arrival/arrival_module.dart';
import 'modules/asrs_inbound/asrs_inbound_module.dart';
import 'modules/asrs_outbound/asrs_outbound_module.dart';
import 'modules/asrs_inventory/asrs_inventory_module.dart';
import 'modules/account/account_module.dart';
import 'modules/floor_exception/floor_exception_module.dart';
import 'modules/floor_inbound/floor_inbound_module.dart';
import 'modules/floor_inventory/floor_inventory_module.dart';
import 'modules/floor_transfer/floor_transfer_module.dart';
import 'modules/message_center/message_center_module.dart';
import 'modules/pull_feeding/pull_feeding_module.dart';

/// 应用主模块
class AppModule extends Module {
  @override
  void binds(Injector i) {
    // 注册核心服务
    i.addSingleton<DioClient>(() => DioClient());
    i.addSingleton<ApiService>(
      () => ApiService(i.get<DioClient>(), i.get<UserManager>()),
    );
    i.addSingleton<UserManager>(() => UserManager());

    i.add<LoginBloc>(
      () => LoginBloc(
        apiService: i.get<ApiService>(),
        userManager: i.get<UserManager>(),
      ),
    );
  }

  @override
  void routes(RouteManager r) {
    // 启动页面
    r.child('/', child: (context) => const SplashScreen());

    // 登录页面
    r.child('/login', child: (context) => const UserLoginPage());

    // 主页面
    r.child('/home', child: (context) => const WMSHomePage());

    // 出库模块
    r.module('/outbound', module: OutboundModule());

    // 其他业务模块
    r.module('/arrival', module: ArrivalModule());

    r.module('/floor-inbound', module: FloorInboundModule());

    r.module('/floor-exception', module: FloorExceptionModule());

    r.module('/pull-feeding', module: PullFeedingModule());

    r.module('/asrs-inbound', module: AsrsInboundModule());
    r.module('/asrs-outbound', module: AsrsOutboundModule());

    r.module('/message-center', module: MessageCenterModule());

    r.module('/floor-count', module: FloorInventoryModule());

    r.module('/floor-transfer', module: FloorTransferModule());

    r.module('/warehouse-count', module: AsrsInventoryModule());

    r.module('/inventory-query', module: FloorTransferModule());

    r.module('/account', module: AccountModule());
  }
}
