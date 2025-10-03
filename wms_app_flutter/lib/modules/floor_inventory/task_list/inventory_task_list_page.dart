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
import 'package:wms_app/modules/floor_inventory/task_list/bloc/inventory_task_list_bloc.dart';
import 'package:wms_app/modules/floor_inventory/task_list/bloc/inventory_task_list_event.dart';
import 'package:wms_app/modules/floor_inventory/task_list/bloc/inventory_task_list_state.dart';
import 'package:wms_app/modules/floor_inventory/task_list/config/inventory_task_grid_config.dart';
import 'package:wms_app/modules/floor_inventory/task_list/models/inventory_task.dart';
import 'package:wms_app/services/scanner_service.dart';

class InventoryTaskListPage extends StatefulWidget {
  const InventoryTaskListPage({super.key});

  @override
  State<InventoryTaskListPage> createState() => _InventoryTaskListPageState();
}

class _InventoryTaskListPageState extends State<InventoryTaskListPage> {
  late final InventoryTaskListBloc _bloc;
  late final CommonDataGridBloc<InventoryTask> _gridBloc;
  final TextEditingController _searchController = TextEditingController();
  StreamSubscription<String>? _scanSubscription;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<InventoryTaskListBloc>(context);
    _gridBloc = _bloc.gridBloc;

    _scanSubscription = ScannerService.instance.stream.listen((code) {
      if (!mounted) return;
      if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;
      final trimmed = code.trim();
      if (trimmed.isEmpty) return;
      _searchController.text = trimmed;
      _bloc.add(InventoryTaskListSearchSubmitted(trimmed));
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scanSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '平库盘点',
        onBackPressed: () => Navigator.of(context).pop(),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () =>
                _bloc.add(const InventoryTaskListRefreshRequested()),
          ),
          IconButton(
            icon: const Icon(Icons.playlist_add, color: Colors.white),
            onPressed: () => Modular.to.pushNamed('/floor-count/receive'),
          ),
        ],
      ).appBar,
      body: BlocListener<InventoryTaskListBloc, InventoryTaskListState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.successMessage!)));
            _bloc.add(const InventoryTaskMessageCleared());
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            _bloc.add(const InventoryTaskMessageCleared());
          }
        },
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(child: _buildGrid()),
          ],
        ),
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
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '请扫描或输入盘库单号/任务号',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _bloc.add(const InventoryTaskListSearchSubmitted(''));
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onSubmitted: (value) =>
                  _bloc.add(InventoryTaskListSearchSubmitted(value.trim())),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => _bloc.add(
              InventoryTaskListSearchSubmitted(_searchController.text.trim()),
            ),
            child: const Text('查询'),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return BlocProvider.value(
      value: _gridBloc,
      child:
          BlocConsumer<
            CommonDataGridBloc<InventoryTask>,
            CommonDataGridState<InventoryTask>
          >(
            listener: (context, state) {
              if (state.status == GridStatus.loading) {
                LoadingDialogManager.instance.showLoadingDialog(context);
              } else {
                LoadingDialogManager.instance.hideLoadingDialog(context);
              }

              if (state.status == GridStatus.error &&
                  state.errorMessage != null) {
                LoadingDialogManager.instance.showErrorDialog(
                  context,
                  state.errorMessage!,
                );
              }
            },
            builder: (context, state) {
              return CommonDataGrid<InventoryTask>(
                columns: InventoryTaskGridConfig.buildColumns(_onOperate),
                datas: state.data,
                currentPage: state.currentPage,
                totalPages: state.totalPages,
                allowPager: true,
                onLoadData: (pageIndex) async {
                  _gridBloc.add(LoadDataEvent<InventoryTask>(pageIndex));
                },
              );
            },
          ),
    );
  }

  void _onOperate(InventoryTask task, InventoryTaskOperationType type) {
    switch (type) {
      case InventoryTaskOperationType.collect:
        Modular.to.pushNamed(
          '/floor-count/collect/${task.taskNo}',
          arguments: {'task': task},
        );
        break;
      case InventoryTaskOperationType.detail:
        Modular.to.pushNamed(
          '/floor-count/detail/${task.taskNo}',
          arguments: {'task': task},
        );
        break;
      case InventoryTaskOperationType.cancel:
        _confirmCancel(task);
        break;
      case InventoryTaskOperationType.receive:
        break;
    }
  }

  Future<void> _confirmCancel(InventoryTask task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('撤销确认'),
          content: Text(
            '确定撤销盘库任务 ${task.taskNo.isNotEmpty ? task.taskNo : task.taskComment} 吗？',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('确认'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      _bloc.add(InventoryTaskCancelRequested(task));
    }
  }
}
