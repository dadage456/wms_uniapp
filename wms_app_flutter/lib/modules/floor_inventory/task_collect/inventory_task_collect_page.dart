import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/common_widgets/custom_app_bar.dart';
import 'package:wms_app/common_widgets/loading_dialog_manager.dart';
import 'package:wms_app/modules/floor_inventory/task_collect/bloc/inventory_collect_bloc.dart';
import 'package:wms_app/modules/floor_inventory/task_collect/bloc/inventory_collect_event.dart';
import 'package:wms_app/modules/floor_inventory/task_collect/bloc/inventory_collect_state.dart';
import 'package:wms_app/modules/floor_inventory/task_collect/models/inventory_collect_models.dart';
import 'package:wms_app/modules/floor_inventory/task_details/models/inventory_task_detail.dart';
import 'package:wms_app/modules/floor_inventory/task_list/models/inventory_task.dart';
import 'package:wms_app/services/scanner_service.dart';

class InventoryTaskCollectPage extends StatefulWidget {
  const InventoryTaskCollectPage({super.key, this.task});

  final InventoryTask? task;

  @override
  State<InventoryTaskCollectPage> createState() => _InventoryTaskCollectPageState();
}

class _InventoryTaskCollectPageState extends State<InventoryTaskCollectPage> {
  late final InventoryCollectBloc _bloc;
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocus = FocusNode();
  StreamSubscription<String>? _scanSubscription;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<InventoryCollectBloc>();
    final task = widget.task;
    if (task != null) {
      _bloc.add(InventoryCollectStarted(task));
    }

    _scanSubscription = ScannerService.instance.stream.listen((code) {
      if (!mounted) return;
      if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;
      final trimmed = code.trim();
      if (trimmed.isEmpty) return;
      _bloc.add(InventoryCollectScanReceived(trimmed));
    });
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _inputController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '平库盘点采集',
        onBackPressed: () => Navigator.of(context).pop(),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () =>
                _bloc.add(const InventoryCollectRefreshRequested()),
          ),
        ],
      ).appBar,
      body: BlocConsumer<InventoryCollectBloc, InventoryCollectState>(
        listener: (context, state) {
          if (state.isSubmitting) {
            LoadingDialogManager.instance.showLoadingDialog(context);
          } else {
            LoadingDialogManager.instance.hideLoadingDialog(context);
          }

          if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.successMessage!)),
            );
            _bloc.add(const InventoryCollectMessageCleared());
          }

          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
            _bloc.add(const InventoryCollectMessageCleared());
          }

          if (!state.requiresQuantity) {
            _inputController.clear();
          }

          if (state.requiresQuantity) {
            FocusScope.of(context).requestFocus(_inputFocus);
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              _buildSummaryCard(state.task ?? widget.task),
              _buildInputArea(state),
              _buildStatusChips(state),
              _buildTabSelector(state),
              Expanded(child: _buildTabView(state)),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildSummaryCard(InventoryTask? task) {
    if (task == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('盘库单号：${task.taskComment}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text('任务号：${task.taskNo}'),
              Text('库房：${task.storeRoomNo} ${task.storeRoomName}'),
              Text('盘库类型：${task.checkMethod}'),
              Text('创建时间：${task.createdDate}'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(InventoryCollectState state) {
    final isQuantityStep = state.requiresQuantity;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              focusNode: isQuantityStep ? _inputFocus : null,
              keyboardType: isQuantityStep
                  ? const TextInputType.numberWithOptions(decimal: true)
                  : TextInputType.text,
              decoration: InputDecoration(
                labelText: state.placeholder,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _inputController.clear(),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              textInputAction: TextInputAction.done,
              onChanged: isQuantityStep
                  ? (value) =>
                      _bloc.add(InventoryCollectManualQuantityChanged(value))
                  : null,
              onSubmitted: (value) {
                final trimmed = value.trim();
                if (trimmed.isEmpty) return;
                if (isQuantityStep) {
                  final qty = double.tryParse(trimmed);
                  if (qty == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('请输入正确的数量')),
                    );
                    return;
                  }
                  _bloc.add(InventoryCollectQuantitySubmitted(qty));
                } else {
                  _bloc.add(InventoryCollectScanReceived(trimmed));
                }
                _inputController.clear();
              },
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              final trimmed = _inputController.text.trim();
              if (trimmed.isEmpty) return;
              if (isQuantityStep) {
                final qty = double.tryParse(trimmed);
                if (qty == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请输入正确的数量')),
                  );
                  return;
                }
                _bloc.add(InventoryCollectQuantitySubmitted(qty));
              } else {
                _bloc.add(InventoryCollectScanReceived(trimmed));
              }
              _inputController.clear();
            },
            child: Text(isQuantityStep ? '确认' : '录入'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChips(InventoryCollectState state) {
    final chips = <Widget>[];
    if (state.currentStoreSite.isNotEmpty) {
      chips.add(_buildInfoChip('库位', state.currentStoreSite));
    }
    final material = state.currentMaterial;
    if (material != null) {
      chips
        ..add(_buildInfoChip('物料', material.matCode))
        ..add(_buildInfoChip('名称', material.matName));
      if (material.batchNo.isNotEmpty) {
        chips.add(_buildInfoChip('批次', material.batchNo));
      }
      if (material.sn.isNotEmpty && material.isSerialControl) {
        chips.add(_buildInfoChip('序列', material.sn));
      }
    }

    if (chips.isEmpty) {
      return const SizedBox(height: 8);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: chips,
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Chip(
      label: Text('$label：$value'),
      backgroundColor: Colors.blueGrey.shade50,
    );
  }

  Widget _buildTabSelector(InventoryCollectState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('任务列表'),
            selected: state.currentTab == 0,
            onSelected: (_) =>
                _bloc.add(const InventoryCollectTabChanged(0)),
          ),
          const SizedBox(width: 12),
          ChoiceChip(
            label: const Text('采集结果'),
            selected: state.currentTab == 1,
            onSelected: (_) =>
                _bloc.add(const InventoryCollectTabChanged(1)),
          ),
        ],
      ),
    );
  }

  Widget _buildTabView(InventoryCollectState state) {
    return IndexedStack(
      index: state.currentTab,
      children: [
        _buildTaskTable(state.taskItems),
        _buildCollectionList(state.collectRecords),
      ],
    );
  }

  Widget _buildTaskTable(List<InventoryTaskDetail> details) {
    if (details.isEmpty) {
      return const Center(child: Text('暂无任务明细'));
    }

    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('库位号')),
            DataColumn(label: Text('物料编码')),
            DataColumn(label: Text('物料名称')),
            DataColumn(label: Text('批次')),
            DataColumn(label: Text('序列号')),
            DataColumn(label: Text('计划数量')),
            DataColumn(label: Text('采集数量')),
            DataColumn(label: Text('盘库类型')),
          ],
          rows: details
              .map(
                (detail) => DataRow(
                  cells: [
                    DataCell(Text(detail.storeSite)),
                    DataCell(Text(detail.materialCode)),
                    DataCell(Text(detail.materialName)),
                    DataCell(Text(detail.batchNo)),
                    DataCell(Text(detail.serialNo)),
                    DataCell(Text(detail.planQty.toStringAsFixed(2))),
                    DataCell(Text(detail.collectedQty.toStringAsFixed(2))),
                    DataCell(Text(detail.checkMethod)),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildCollectionList(List<InventoryCollectionRecord> records) {
    if (records.isEmpty) {
      return const Center(child: Text('暂无采集记录'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final record = records[index];
        return Card(
          child: ListTile(
            title: Text('${record.storeSiteNo} · ${record.matCode}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.matName),
                Text('数量：${record.collectQty.toStringAsFixed(2)}'),
                if ((record.batchNo ?? '').isNotEmpty)
                  Text('批次：${record.batchNo}'),
                if ((record.sn ?? '').isNotEmpty)
                  Text('序列：${record.sn}'),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () =>
                  _bloc.add(InventoryCollectRecordRemoved(record)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: FilledButton.tonal(
                onPressed: () =>
                    _bloc.add(const InventoryCollectTabChanged(1)),
                child: const Text('采集结果'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () =>
                    _bloc.add(const InventoryCollectResetRequested()),
                child: const Text('重置'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: () =>
                    _bloc.add(const InventoryCollectSubmitRequested()),
                child: const Text('提交'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
