import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/common_widgets/custom_app_bar.dart';
import 'package:wms_app/common_widgets/loading_dialog_manager.dart';
import 'package:wms_app/modules/floor_inbound/task_details/bloc/inbound_task_detail_bloc.dart';
import 'package:wms_app/modules/floor_inbound/task_details/bloc/inbound_task_detail_event.dart';
import 'package:wms_app/modules/floor_inbound/task_details/bloc/inbound_task_detail_state.dart';
import 'package:wms_app/modules/floor_inbound/task_details/models/inbound_task_item.dart';
import 'package:wms_app/modules/floor_inbound/task_list/models/inbound_task.dart';
import 'package:wms_app/services/scanner_service.dart';

class InboundTaskDetailPage extends StatefulWidget {
  const InboundTaskDetailPage({
    super.key,
    required this.task,
    required this.workStation,
    this.receiveMode = false,
  });

  final InboundTask task;
  final String workStation;
  final bool receiveMode;

  @override
  State<InboundTaskDetailPage> createState() => _InboundTaskDetailPageState();
}

class _InboundTaskDetailPageState extends State<InboundTaskDetailPage> {
  late final InboundTaskDetailBloc _bloc;
  final TextEditingController _searchController = TextEditingController();
  StreamSubscription<String>? _scanSubscription;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<InboundTaskDetailBloc>(context);
    _bloc.add(
      InitializeInboundTaskDetail(
        inTaskId: widget.task.inTaskId,
        workStation: widget.workStation,
      ),
    );

    _scanSubscription = ScannerService.instance.stream.listen(
      (code) {
        if (!mounted) return;
        if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;
        final trimmed = code.trim();
        if (trimmed.isEmpty) return;
        _searchController.text = trimmed;
        _bloc.add(SearchInboundTaskItems(trimmed, decode: true));
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
    _searchController.dispose();
    _scanSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: '明细-${widget.task.inTaskNo}').appBar,
      body: BlocConsumer<InboundTaskDetailBloc, InboundTaskDetailState>(
        listener: (context, state) {
          if (state.isLoading) {
            LoadingDialogManager.instance.showLoadingDialog(context);
          } else {
            LoadingDialogManager.instance.hideLoadingDialog(context);
          }
          if (state.errorMessage != null) {
            LoadingDialogManager.instance.showErrorDialog(context, state.errorMessage!);
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              _buildSearchBar(),
              _buildActionBar(state),
              Expanded(
                child: ListView.separated(
                  itemCount: state.items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    final checked = state.selectedIds.contains(item.itemId);
                    return CheckboxListTile(
                      value: checked,
                      onChanged: (_) =>
                          _bloc.add(ToggleInboundTaskItemSelection(item.itemId)),
                      title: Text('${item.matCode} - ${item.matName}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('库位: ${item.storeSiteNo}   批次: ${item.batchNo}'),
                          Text('计划: ${item.planQty}   已采集: ${item.collectedQty}   库存: ${item.inventoryQty}'),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
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
                hintText: '扫描或输入物料/库位',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _bloc.add(
                    SearchInboundTaskItems(
                      _searchController.text.trim(),
                      decode: true,
                    ),
                  ),
                ),
              ),
              onSubmitted: (value) =>
                  _bloc.add(SearchInboundTaskItems(value.trim(), decode: true)),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => _bloc.add(
              SearchInboundTaskItems(
                _searchController.text.trim(),
                decode: true,
              ),
            ),
            child: const Text('查询'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBar(InboundTaskDetailState state) {
    final allSelected = state.selectedIds.length == state.items.length && state.items.isNotEmpty;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[100],
      child: Row(
        children: [
          Checkbox(
            value: allSelected,
            onChanged: (value) =>
                _bloc.add(SelectAllInboundTaskItems(value ?? false)),
          ),
          const Text('全选'),
          const Spacer(),
          if (!widget.receiveMode) ...[
            ElevatedButton(
              onPressed: state.selectedIds.isEmpty
                  ? null
                  : () => _bloc.add(const CommitInboundTaskItems(cancel: true)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('撤销'),
            ),
            const SizedBox(width: 12),
          ],
          ElevatedButton(
            onPressed: state.selectedIds.isEmpty
                ? null
                : () => _bloc.add(const CommitInboundTaskItems(cancel: false)),
            child: const Text('接收'),
          ),
        ],
      ),
    );
  }
}
