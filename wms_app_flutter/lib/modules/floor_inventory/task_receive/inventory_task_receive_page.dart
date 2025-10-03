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
import 'package:wms_app/modules/floor_inventory/task_list/config/inventory_task_grid_config.dart';
import 'package:wms_app/modules/floor_inventory/task_list/models/inventory_task.dart';
import 'package:wms_app/modules/floor_inventory/task_receive/bloc/inventory_task_receive_bloc.dart';
import 'package:wms_app/modules/floor_inventory/task_receive/bloc/inventory_task_receive_event.dart';
import 'package:wms_app/modules/floor_inventory/task_receive/bloc/inventory_task_receive_state.dart';
import 'package:wms_app/services/scanner_service.dart';

class InventoryTaskReceivePage extends StatefulWidget {
  const InventoryTaskReceivePage({super.key});

  @override
  State<InventoryTaskReceivePage> createState() =>
      _InventoryTaskReceivePageState();
}

class _InventoryTaskReceivePageState extends State<InventoryTaskReceivePage> {
  late final InventoryTaskReceiveBloc _bloc;
  late final CommonDataGridBloc<InventoryTask> _gridBloc;
  final TextEditingController _searchController = TextEditingController();
  StreamSubscription<String>? _scanSubscription;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<InventoryTaskReceiveBloc>(context);
    _gridBloc = _bloc.gridBloc;

    _scanSubscription = ScannerService.instance.stream.listen((code) {
      if (!mounted) return;
      if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;
      final trimmed = code.trim();
      if (trimmed.isEmpty) return;
      _searchController.text = trimmed;
      _bloc.add(InventoryTaskReceiveSearchSubmitted(trimmed));
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
        title: '平库盘点接收',
        onBackPressed: () => Navigator.of(context).pop(),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () =>
                _bloc.add(const InventoryTaskReceiveRefreshRequested()),
          ),
        ],
      ).appBar,
      body: BlocListener<InventoryTaskReceiveBloc, InventoryTaskReceiveState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.successMessage!)));
            _bloc.add(const InventoryTaskReceiveMessageCleared());
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            _bloc.add(const InventoryTaskReceiveMessageCleared());
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
                    _bloc.add(const InventoryTaskReceiveSearchSubmitted(''));
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onSubmitted: (value) =>
                  _bloc.add(InventoryTaskReceiveSearchSubmitted(value.trim())),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => _bloc.add(
              InventoryTaskReceiveSearchSubmitted(
                _searchController.text.trim(),
              ),
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
                columns: InventoryTaskGridConfig.buildReceiveColumns(
                  _onOperate,
                ),
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
      case InventoryTaskOperationType.receive:
        _confirmReceive(task);
        break;
      case InventoryTaskOperationType.detail:
        Modular.to.pushNamed(
          '/floor-count/detail/${task.taskNo}',
          arguments: {'task': task},
        );
        break;
      case InventoryTaskOperationType.collect:
      case InventoryTaskOperationType.cancel:
        break;
    }
  }

  Future<void> _confirmReceive(InventoryTask task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('接收确认'),
          content: Text(
            '确定接收盘库任务 ${task.taskNo.isNotEmpty ? task.taskNo : task.taskComment} 吗？',
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
      _bloc.add(InventoryTaskReceiveConfirmed(task));
    }
  }
}
