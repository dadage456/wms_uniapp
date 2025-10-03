
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:wms_app/app_module.dart';
import 'package:wms_app/modules/account/models/account_profile.dart';
import 'package:wms_app/modules/account/password/cubit/change_password_cubit.dart';
import 'package:wms_app/modules/account/password/view/change_password_page.dart';
import 'package:wms_app/modules/account/profile/cubit/account_profile_cubit.dart';
import 'package:wms_app/modules/account/profile/cubit/account_profile_edit_cubit.dart';
import 'package:wms_app/modules/account/profile/view/account_center_page.dart';
import 'package:wms_app/modules/account/profile/view/account_profile_edit_page.dart';
import 'package:wms_app/modules/account/services/account_service.dart';
import 'package:wms_app/services/api_service.dart';
import 'package:wms_app/services/dio_client.dart';
import 'package:wms_app/services/user_manager.dart';

class AccountModule extends Module {
  @override
  List<Module> get imports => [AppModule()];

  @override
  void binds(Injector i) {
    i.addSingleton<AccountService>(
      () => AccountService(
        dio: i.get<DioClient>().dio,
        apiService: i.get<ApiService>(),
        userManager: i.get<UserManager>(),
      ),
    );

    i.add<AccountProfileCubit>(
      () => AccountProfileCubit(service: i.get<AccountService>()),
    );

    i.add<ChangePasswordCubit>(
      () => ChangePasswordCubit(service: i.get<AccountService>()),
    );
  }

  @override
  void routes(RouteManager r) {
    r.child(
      '/',
      child: (context) => BlocProvider(
        create: (_) => Modular.get<AccountProfileCubit>()..loadProfile(),
        child: const AccountCenterPage(),
      ),
    );

    r.child(
      '/edit',
      child: (context) {
        final args = Modular.args;
        final profile = args.data as AccountProfile?;
        if (profile == null) {
          return BlocProvider(
            create: (_) => Modular.get<AccountProfileCubit>()..loadProfile(),
            child: const AccountCenterPage(),
          );
        }
        return BlocProvider(
          create: (_) => AccountProfileEditCubit(
            service: Modular.get<AccountService>(),
            profile: profile,
          ),
          child: const AccountProfileEditPage(),
        );
      },
    );

    r.child(
      '/change-password',
      child: (context) => BlocProvider(
        create: (_) => Modular.get<ChangePasswordCubit>(),
        child: const ChangePasswordPage(),
      ),
    );
  }
}
