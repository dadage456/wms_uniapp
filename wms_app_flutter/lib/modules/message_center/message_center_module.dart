import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:wms_app/app_module.dart';
import 'package:wms_app/modules/message_center/detail/bloc/notice_detail_cubit.dart';
import 'package:wms_app/modules/message_center/detail/notice_detail_page.dart';
import 'package:wms_app/modules/message_center/list/bloc/message_list_bloc.dart';
import 'package:wms_app/modules/message_center/list/message_list_page.dart';
import 'package:wms_app/modules/message_center/services/message_center_service.dart';
import 'package:wms_app/services/dio_client.dart';
import 'package:wms_app/services/user_manager.dart';

class MessageCenterModule extends Module {
  @override
  List<Module> get imports => [AppModule()];

  @override
  void binds(Injector i) {
    i.addSingleton<MessageCenterService>(
      () => MessageCenterService(i.get<DioClient>().dio),
    );

    i.add<MessageListBloc>(
      () => MessageListBloc(
        service: i.get<MessageCenterService>(),
        userManager: i.get<UserManager>(),
      ),
    );
  }

  @override
  void routes(RouteManager r) {
    r.child(
      '/',
      child: (context) => BlocProvider(
        create: (context) => Modular.get<MessageListBloc>()
          ..add(const MessageListSubscriptionRequested()),
        child: const MessageListPage(),
      ),
    );

    r.child(
      '/detail',
      child: (context) {
        final args = Modular.args.data;
        String? noticeId;
        String? title;
        if (args is String) {
          noticeId = args;
        } else if (args is Map) {
          final map = args.cast<dynamic, dynamic>();
          noticeId = map['noticeId']?.toString();
          title = map['title']?.toString();
        }
        return BlocProvider(
          create: (context) => NoticeDetailCubit(
            service: Modular.get<MessageCenterService>(),
            userManager: Modular.get<UserManager>(),
          )..loadNotice(noticeId),
          child: NoticeDetailPage(noticeId: noticeId, initialTitle: title),
        );
      },
    );
  }
}
