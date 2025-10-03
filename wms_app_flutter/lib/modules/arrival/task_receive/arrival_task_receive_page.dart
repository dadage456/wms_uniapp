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
import 'package:wms_app/modules/arrival/task_list/config/arrival_task_grid_config.dart';
import 'package:wms_app/modules/arrival/task_list/models/arrival_task.dart';
import 'package:wms_app/modules/arrival/task_receive/bloc/arrival_task_receive_bloc.dart';
import 'package:wms_app/modules/arrival/task_receive/bloc/arrival_task_receive_event.dart';
import 'package:wms_app/modules/arrival/task_receive/bloc/arrival_task_receive_state.dart';
import 'package:wms_app/services/scanner_service.dart';

class ArrivalTaskReceivePage extends StatefulWidget {
  const ArrivalTaskReceivePage({super.key});

  @override
  State<ArrivalTaskReceivePage> createState() => _ArrivalTaskReceivePageState();
}

class _ArrivalTaskReceivePageState extends State<ArrivalTaskReceivePage> {
  late final ArrivalTaskReceiveBloc _bloc;
  late final CommonDataGridBloc<ArrivalTask> _gridBloc;
  final TextEditingController _searchController = TextEditingController();
  StreamSubscription<String>? _scanSubscription;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<ArrivalTaskReceiveBloc>(context);
    _gridBloc = _bloc.gridBloc;
    _scanSubscription = ScannerService.instance.stream.listen((code) {
      if (!mounted) return;
      if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;
      final trimmed = code.trim();
      if (trimmed.isEmpty) return;
      _searchController.text = trimmed;
      _bloc.add(ArrivalTaskReceiveSearchSubmitted(trimmed));
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
        title: '接收到货任务',
        onBackPressed: () => Navigator.of(context).pop(),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () =>
                _bloc.add(const ArrivalTaskReceiveRefreshRequested()),
          ),
        ],
      ).appBar,
      body: BlocListener<ArrivalTaskReceiveBloc, ArrivalTaskReceiveState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.successMessage!)),
            );
            _bloc.add(const ArrivalTaskReceiveMessageCleared());
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
            _bloc.add(const ArrivalTaskReceiveMessageCleared());
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
                hintText: '请扫描或输入到货单号/装箱单号',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _bloc.add(const ArrivalTaskReceiveSearchSubmitted(''));
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onSubmitted: (value) =>
                  _bloc.add(ArrivalTaskReceiveSearchSubmitted(value.trim())),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => _bloc.add(
              ArrivalTaskReceiveSearchSubmitted(_searchController.text.trim()),
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
      child: BlocConsumer<CommonDataGridBloc<ArrivalTask>,
          CommonDataGridState<ArrivalTask>>(
        listener: (context, state) {
          if (state.status == GridStatus.loading) {
            LoadingDialogManager.instance.showLoadingDialog(context);
          } else {
            LoadingDialogManager.instance.hideLoadingDialog(context);
          }

          if (state.status == GridStatus.error && state.errorMessage != null) {
            LoadingDialogManager.instance.showErrorDialog(
              context,
              state.errorMessage!,
            );
          }
        },
        builder: (context, state) {
          return CommonDataGrid<ArrivalTask>(
            columns: ArrivalTaskGridConfig.buildReceiveColumns(_onOperate),
            datas: state.data,
            currentPage: state.currentPage,
            totalPages: state.totalPages,
            allowPager: true,
            onLoadData: (pageIndex) async {
              _gridBloc.add(LoadDataEvent<ArrivalTask>(pageIndex));
            },
          );
        },
      ),
    );
  }

  void _onOperate(ArrivalTask task, ArrivalTaskOperationType type) {
    switch (type) {
      case ArrivalTaskOperationType.receive:
        _confirmReceive(task);
        break;
      case ArrivalTaskOperationType.detail:
        Modular.to.pushNamed(
          '/arrival/detail/${task.arrivalsBillId}',
          arguments: {'task': task},
        );
        break;
      case ArrivalTaskOperationType.collect:
      case ArrivalTaskOperationType.cancel:
        break;
    }
  }

  Future<void> _confirmReceive(ArrivalTask task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('接收确认'),
          content: Text('确定接收到货单 ${task.arrivalsBillNo} 吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('确认'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      _bloc.add(ArrivalTaskReceiveConfirmed(task.arrivalsBillId));
    }
  }
}
