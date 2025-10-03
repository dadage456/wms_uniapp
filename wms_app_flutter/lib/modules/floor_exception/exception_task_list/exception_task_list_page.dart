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
import 'package:wms_app/modules/floor_exception/exception_collection/models/floor_exception_collection_args.dart';
import 'package:wms_app/modules/floor_exception/exception_task_list/bloc/exception_task_list_bloc.dart';
import 'package:wms_app/modules/floor_exception/exception_task_list/bloc/exception_task_list_event.dart';
import 'package:wms_app/modules/floor_exception/exception_task_list/bloc/exception_task_list_state.dart';
import 'package:wms_app/modules/floor_exception/exception_task_list/config/exception_task_grid_config.dart';
import 'package:wms_app/modules/floor_exception/exception_task_list/models/exception_task.dart';
import 'package:wms_app/services/scanner_service.dart';

class ExceptionTaskListPage extends StatefulWidget {
  const ExceptionTaskListPage({super.key});

  @override
  State<ExceptionTaskListPage> createState() => _ExceptionTaskListPageState();
}

class _ExceptionTaskListPageState extends State<ExceptionTaskListPage> {
  late final ExceptionTaskListBloc _bloc;
  late final CommonDataGridBloc<ExceptionTaskRecord> _gridBloc;
  final TextEditingController _searchController = TextEditingController();
  StreamSubscription<String>? _scanSubscription;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<ExceptionTaskListBloc>(context);
    _gridBloc = _bloc.gridBloc;
    _gridBloc.add(const LoadDataEvent<ExceptionTaskRecord>(1));

    _scanSubscription = ScannerService.instance.stream.listen((code) {
      if (!mounted) return;
      if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;
      final trimmed = code.trim();
      if (trimmed.isEmpty) return;
      _searchController.text = trimmed;
      _bloc.add(ExceptionTaskListSearchSubmitted(trimmed));
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
        title: '异常任务',
        onBackPressed: () => Navigator.of(context).pop(),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () =>
                _bloc.add(const ExceptionTaskListRefreshRequested()),
          ),
        ],
      ).appBar,
      body: BlocListener<ExceptionTaskListBloc, ExceptionTaskListState>(
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.successMessage!)));
            _bloc.add(const ExceptionTaskListMessageCleared());
          }
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
            _bloc.add(const ExceptionTaskListMessageCleared());
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
                hintText: '请扫描或输入异常任务号/托盘号',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _bloc.add(const ExceptionTaskListSearchSubmitted(''));
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onSubmitted: (value) =>
                  _bloc.add(ExceptionTaskListSearchSubmitted(value.trim())),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => _bloc.add(
              ExceptionTaskListSearchSubmitted(_searchController.text.trim()),
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
            CommonDataGridBloc<ExceptionTaskRecord>,
            CommonDataGridState<ExceptionTaskRecord>
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
              return CommonDataGrid<ExceptionTaskRecord>(
                columns: ExceptionTaskGridConfig.buildColumns(_onOperate),
                datas: state.data,
                currentPage: state.currentPage,
                totalPages: state.totalPages,
                allowPager: true,
                onLoadData: (pageIndex) async {
                  _gridBloc.add(LoadDataEvent<ExceptionTaskRecord>(pageIndex));
                },
              );
            },
          ),
    );
  }

  void _onOperate(ExceptionTaskRecord record, ExceptionTaskOperationType type) {
    switch (type) {
      case ExceptionTaskOperationType.collect:
        Modular.to.pushNamed(
          '/floor-exception/collect',
          arguments: FloorExceptionCollectionArgs(
            taskSummary: record.toSummary(),
          ),
        );
        break;
      case ExceptionTaskOperationType.reprocess:
        _bloc.add(ExceptionTaskListReprocessRequested(record));
        break;
    }
  }
}
