import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:wms_app/common_widgets/common_grid/common_data_grid.dart';
import 'package:wms_app/common_widgets/common_grid/grid_bloc.dart';
import 'package:wms_app/common_widgets/common_grid/grid_event.dart';
import 'package:wms_app/common_widgets/common_grid/grid_state.dart';
import 'package:wms_app/common_widgets/custom_app_bar.dart';
import 'package:wms_app/common_widgets/loading_dialog_manager.dart';
import 'package:wms_app/modules/outbound/task_details/config/outbound_task_detail_grid_config.dart';
import 'package:wms_app/modules/outbound/task_details/models/outbound_task_item.dart';
import 'package:wms_app/modules/outbound/task_list/models/outbound_task.dart';

import 'bloc/receive_task_detail_bloc.dart';
import 'bloc/receive_task_detail_event.dart';
import 'widgets/receive_batch_action_bar.dart';

class ReceiveTaskDetailPage extends StatefulWidget {
  final OutboundTask task;

  const ReceiveTaskDetailPage({super.key, required this.task});

  @override
  State<ReceiveTaskDetailPage> createState() => _ReceiveTaskDetailPageState();
}

class _ReceiveTaskDetailPageState extends State<ReceiveTaskDetailPage> {
  late ReceiveTaskDetailBloc _bloc;
  late CommonDataGridBloc<OutboundTaskItem> _gridBloc;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<ReceiveTaskDetailBloc>(context);
    _bloc.initializeQuery(widget.task);
    _gridBloc = _bloc.gridBloc;
    _gridBloc.add(LoadDataEvent(1));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: CustomAppBar(
        title: '平库下架接收明细',
        onBackPressed: () => Modular.to.pop(),
      ).appBar,
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildTable()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: const BoxDecoration(color: Colors.white),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '请扫描或输入物料编码',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _searchController,
            builder: (_, value, __) => value.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _bloc.add(SearchReceiveTaskItemsEvent(''));
                    },
                  ),
          ),
        ),
        onSubmitted: (value) {
          _bloc.add(SearchReceiveTaskItemsEvent(value));
        },
      ),
    );
  }

  Widget _buildTable() {
    return BlocProvider.value(
      value: _gridBloc,
      child: BlocConsumer<CommonDataGridBloc<OutboundTaskItem>,
          CommonDataGridState<OutboundTaskItem>>(
        listener: (context, state) {
          if (state.status == GridStatus.loading) {
            LoadingDialogManager.instance.showLoadingDialog(context);
          } else {
            LoadingDialogManager.instance.hideLoadingDialog(context);
          }

          if (state.status == GridStatus.error) {
            LoadingDialogManager.instance.showErrorDialog(
              context,
              state.errorMessage ?? '加载失败',
            );
          } else if (state.status == GridStatus.success) {
            LoadingDialogManager.instance.showSnackSuccessMsg(
              context,
              '接收成功',
              duration: const Duration(milliseconds: 800),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: CommonDataGrid<OutboundTaskItem>(
                  columns: OutboundTaskDetailGridConfig.getColumns(),
                  datas: state.data,
                  currentPage: state.currentPage,
                  totalPages: state.totalPages,
                  allowPager: true,
                  allowSelect: true,
                  selectedRows: state.selectedRows,
                  onSelectionChanged: (rows) {
                    _gridBloc.add(ChangeSelectedRowsEvent(rows));
                  },
                  onLoadData: (pageIndex) async {
                    _gridBloc.add(LoadDataEvent(pageIndex));
                  },
                ),
              ),
              BlocBuilder<CommonDataGridBloc<OutboundTaskItem>,
                  CommonDataGridState<OutboundTaskItem>>(
                builder: (context, gridState) {
                  return ReceiveBatchActionBar(
                    selectedCount: gridState.selectedRows.length,
                    totalCount: gridState.data.length,
                    onClear: () {
                      _gridBloc.add(const ChangeSelectedRowsEvent([]));
                    },
                    onConfirm: () {
                      _bloc.add(
                        ReceiveSelectedItemsEvent(gridState.selectedRows),
                      );
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
