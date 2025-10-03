import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:wms_app/common_widgets/common_grid/common_data_grid.dart';
import 'package:wms_app/common_widgets/common_grid/grid_bloc.dart';
import 'package:wms_app/common_widgets/common_grid/grid_event.dart';
import 'package:wms_app/common_widgets/common_grid/grid_state.dart';
import 'package:wms_app/common_widgets/custom_app_bar.dart';
import 'package:wms_app/common_widgets/loading_dialog_manager.dart';
import 'package:wms_app/modules/floor_inbound/task_list/bloc/inbound_task_bloc.dart';
import 'package:wms_app/modules/floor_inbound/task_list/bloc/inbound_task_event.dart';
import 'package:wms_app/modules/floor_inbound/task_list/config/inbound_task_grid_config.dart';
import 'package:wms_app/modules/floor_inbound/task_list/models/inbound_task.dart';
import 'package:wms_app/services/scanner_service.dart';

class InboundReceiveTaskPage extends StatefulWidget {
  const InboundReceiveTaskPage({super.key});

  @override
  State<InboundReceiveTaskPage> createState() => _InboundReceiveTaskPageState();
}

class _InboundReceiveTaskPageState extends State<InboundReceiveTaskPage> {
  late final InboundTaskBloc _bloc;
  late final CommonDataGridBloc<InboundTask> _gridBloc;
  StreamSubscription<String>? _scanSubscription;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<InboundTaskBloc>(context);
    _gridBloc = _bloc.gridBloc;
    final role = _bloc.currentQuery.roleOrUserId;
    _bloc.add(SetInboundTaskUserScopeEvent(userId: 'ALL', roleOrUserId: role));
    _bloc.add(const FilterInboundTasksEvent('1'));

    _scanSubscription = ScannerService.instance.stream.listen(
      (code) {
        if (!mounted) return;
        if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;
        final trimmed = code.trim();
        if (trimmed.isEmpty) return;
        _bloc.add(SearchInboundTasksEvent(trimmed));
      },
      onError: (error, __) {
        if (!mounted) return;
        LoadingDialogManager.instance.showErrorDialog(
          context,
          '扫码异常：$error',
        );
      },
    );
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: '待接收任务').appBar,
      body: BlocProvider.value(
        value: _gridBloc,
        child: BlocConsumer<CommonDataGridBloc<InboundTask>, CommonDataGridState<InboundTask>>(
          listener: (context, state) {
            if (state.status == GridStatus.loading) {
              LoadingDialogManager.instance.showLoadingDialog(context);
            } else {
              LoadingDialogManager.instance.hideLoadingDialog(context);
            }
            if (state.status == GridStatus.error) {
              LoadingDialogManager.instance.showErrorDialog(
                context,
                state.errorMessage ?? '加载接收任务失败',
              );
            }
          },
          builder: (context, state) {
            return CommonDataGrid<InboundTask>(
              columns: InboundTaskGridConfig.buildColumns(
                _onOperate,
                includeCollect: false,
              ),
              data: state.data ?? const [],
              currentPage: state.currentPage,
              totalPages: state.totalPages,
              onLoadData: (index) async => _gridBloc.add(LoadDataEvent(index)),
            );
          },
        ),
      ),
    );
  }

  void _onOperate(InboundTask task, InboundTaskOperationType type) {
    if (type == InboundTaskOperationType.detail) {
      Modular.to.pushNamed(
        '/floor-inbound/detail/${task.inTaskId}',
        arguments: {
          'task': task,
          'workStation': task.workStation,
          'receiveMode': true,
        },
      );
    }
  }
}
