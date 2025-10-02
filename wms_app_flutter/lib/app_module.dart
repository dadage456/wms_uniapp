import 'package:flutter_modular/flutter_modular.dart';
import 'package:wms_app/modules/home/lauch_page/splash_page.dart';
import 'package:wms_app/modules/home/login/bloc/login_bloc.dart';
import 'package:wms_app/services/dio_client.dart';
import 'package:wms_app/services/user_manager.dart';
import 'package:wms_app/modules/home/home_page.dart';
import 'package:wms_app/modules/home/login/login_page.dart';
import 'package:wms_app/services/api_service.dart';
import 'modules/outbound/outbound_module.dart';
import 'modules/feature_placeholder/feature_placeholder_bloc.dart';
import 'modules/feature_placeholder/feature_placeholder_module.dart';

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

    // 其他模块占位路由
    r.module(
      '/arrival',
      module: FeaturePlaceholderModule(
        info: const FeaturePlaceholderInfo(
          title: '到货接收',
          description: '到货接收功能正在按平库出库模块标准进行Flutter重构。',
          todoItems: [
            '梳理到货接收业务流程',
            '实现BLoC状态管理与列表查询',
            '对接api.md中到货接收相关接口',
          ],
        ),
      ),
    );

    r.module(
      '/palletizing',
      module: FeaturePlaceholderModule(
        info: const FeaturePlaceholderInfo(
          title: '立库组盘',
          description: '立库组盘模块重构预研中，稍后将基于统一组件实现。',
          todoItems: [
            '迁移现有UniApp页面逻辑',
            '抽象公共表格与扫码交互组件',
          ],
        ),
      ),
    );

    r.module(
      '/floor-inbound',
      module: FeaturePlaceholderModule(
        info: const FeaturePlaceholderInfo(
          title: '平库入库',
          description: '平库入库模块正在迁移至Flutter，敬请期待。',
          todoItems: [
            '梳理入库任务与采集接口',
            '复用出库模块的分页、筛选及扫码架构',
          ],
        ),
      ),
    );

    r.module(
      '/online-picking',
      module: FeaturePlaceholderModule(
        info: const FeaturePlaceholderInfo(
          title: '在线拣选',
          description: '在线拣选将采用统一的任务列表 + 明细 + 采集模式。',
        ),
      ),
    );

    r.module(
      '/pull-feeding',
      module: FeaturePlaceholderModule(
        info: const FeaturePlaceholderInfo(
          title: '拉式发料',
          description: '拉式发料模块重构排期中。',
        ),
      ),
    );

    r.module(
      '/floor-count',
      module: FeaturePlaceholderModule(
        info: const FeaturePlaceholderInfo(
          title: '平库盘点',
          description: '平库盘点功能即将迁移，后续将支持离线缓存与差异分析。',
        ),
      ),
    );

    r.module(
      '/floor-transfer',
      module: FeaturePlaceholderModule(
        info: const FeaturePlaceholderInfo(
          title: '平库移库',
          description: '平库移库流程将沿用BLoC + 通用表格方案。',
        ),
      ),
    );

    r.module(
      '/warehouse-count',
      module: FeaturePlaceholderModule(
        info: const FeaturePlaceholderInfo(
          title: '立库盘点',
          description: '立库盘点迁移预定在下一阶段实施。',
        ),
      ),
    );

    r.module(
      '/inventory-query',
      module: FeaturePlaceholderModule(
        info: const FeaturePlaceholderInfo(
          title: '库存查询',
          description: '库存查询模块将统一搜索、筛选与导出能力。',
        ),
      ),
    );
  }
}
