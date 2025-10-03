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

class InboundTaskListPage extends StatefulWidget {
  const InboundTaskListPage({super.key});

  @override
  State<InboundTaskListPage> createState() => _InboundTaskListPageState();
}

class _InboundTaskListPageState extends State<InboundTaskListPage> {
  late final InboundTaskBloc _bloc;
  late final CommonDataGridBloc<InboundTask> _gridBloc;
  final TextEditingController _scanController = TextEditingController();
  StreamSubscription<String>? _scanSubscription;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<InboundTaskBloc>(context);
    _gridBloc = _bloc.gridBloc;

    _scanSubscription = ScannerService.instance.stream.listen(
      (code) {
        if (!mounted) return;
        if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;
        final trimmed = code.trim();
        if (trimmed.isEmpty) return;
        _scanController.text = trimmed;
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
    _scanController.dispose();
    _scanSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '平库上架任务',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _bloc.add(const RefreshInboundTasksEvent()),
          ),
          IconButton(
            icon: const Icon(Icons.checklist_rtl, color: Colors.white),
            onPressed: () => Modular.to.pushNamed('/floor-inbound/receive'),
          ),
        ],
      ).appBar,
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildGrid()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _scanController,
              decoration: InputDecoration(
                hintText: '请扫描入库单号或任务号',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _scanController.clear();
                    _bloc.add(const SearchInboundTasksEvent(''));
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onSubmitted: (value) =>
                  _bloc.add(SearchInboundTasksEvent(value.trim())),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => _bloc.add(SearchInboundTasksEvent(_scanController.text.trim())),
            child: const Text('查询'),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return BlocProvider.value(
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
              state.errorMessage ?? '加载任务列表失败',
            );
          }
        },
        builder: (context, state) {
          return CommonDataGrid<InboundTask>(
            columns: InboundTaskGridConfig.buildColumns(_onOperate),
            data: state.data ?? const [],
            selectedRows: state.selectedRows,
            currentPage: state.currentPage,
            totalPages: state.totalPages,
            onLoadData: (pageIndex) async {
              _gridBloc.add(LoadDataEvent(pageIndex));
            },
          );
        },
      ),
    );
  }

  void _onOperate(InboundTask task, InboundTaskOperationType type) {
    if (type == InboundTaskOperationType.collect) {
      Modular.to.pushNamed(
        '/floor-inbound/collect/${task.inTaskNo}',
        arguments: {'task': task},
      );
    } else {
      Modular.to.pushNamed(
        '/floor-inbound/detail/${task.inTaskId}',
        arguments: {
          'task': task,
          'workStation': task.workStation,
        },
      );
    }
  }
}
