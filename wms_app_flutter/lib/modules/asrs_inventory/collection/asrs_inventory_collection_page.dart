import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/modules/asrs_inventory/collection/bloc/asrs_inventory_collect_bloc.dart';
import 'package:wms_app/modules/asrs_inventory/collection/bloc/asrs_inventory_collect_event.dart';
import 'package:wms_app/modules/asrs_inventory/collection/bloc/asrs_inventory_collect_state.dart';
import 'package:wms_app/modules/asrs_inventory/models/asrs_inventory_models.dart';
import 'package:wms_app/services/scanner_service.dart';

class AsrsInventoryCollectionPage extends StatefulWidget {
  const AsrsInventoryCollectionPage({super.key, required this.task});

  final AsrsInventoryTask task;

  @override
  State<AsrsInventoryCollectionPage> createState() =>
      _AsrsInventoryCollectionPageState();
}

class _AsrsInventoryCollectionPageState
    extends State<AsrsInventoryCollectionPage> {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _quantityFocus = FocusNode();
  StreamSubscription<String>? _scanSubscription;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<AsrsInventoryCollectBloc>();
    bloc.add(AsrsInventoryCollectInitialized(task: widget.task));
    _scanSubscription = ScannerService.instance.stream.listen((code) {
      if (!mounted) return;
      if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;
      final value = code.trim();
      if (value.isEmpty) return;
      bloc.add(AsrsInventoryCollectScanReceived(value));
    });
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _inputController.dispose();
    _quantityFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('立库盘点采集 - ${widget.task.taskComment}'),
      ),
      body: BlocConsumer<AsrsInventoryCollectBloc, AsrsInventoryCollectState>(
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
            context
                .read<AsrsInventoryCollectBloc>()
                .add(const AsrsInventoryCollectMessagesCleared());
          } else if (state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.successMessage!)),
            );
            _inputController.clear();
            context
                .read<AsrsInventoryCollectBloc>()
                .add(const AsrsInventoryCollectMessagesCleared());
          }

          if (state.step == AsrsInventoryCollectStep.quantity) {
            FocusScope.of(context).requestFocus(_quantityFocus);
            _inputController.text = state.quantity > 0
                ? state.quantity.toStringAsFixed(2)
                : '';
          }
        },
        builder: (context, state) {
          if (state.status == AsrsInventoryCollectStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == AsrsInventoryCollectStatus.failure) {
            return Center(child: Text(state.errorMessage ?? '加载失败'));
          }

          return Column(
            children: [
              _buildSearchBar(context, state),
              if (state.selectedDetail != null)
                _SelectedDetailCard(
                  detail: state.selectedDetail!,
                  quantityFocus: _quantityFocus,
                  onQuantityChanged: (value) {
                    final parsed = double.tryParse(value) ?? 0;
                    context
                        .read<AsrsInventoryCollectBloc>()
                        .add(AsrsInventoryCollectQuantityChanged(parsed));
                  },
                ),
              Expanded(child: _buildDetailList(context, state)),
              const Divider(height: 1),
              _buildRecordSection(state),
              _buildSubmitBar(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
    AsrsInventoryCollectState state,
  ) {
    final bloc = context.read<AsrsInventoryCollectBloc>();
    final isQuantity = state.step == AsrsInventoryCollectStep.quantity;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              focusNode: isQuantity ? _quantityFocus : null,
              keyboardType: isQuantity
                  ? const TextInputType.numberWithOptions(decimal: true)
                  : TextInputType.text,
              decoration: InputDecoration(
                labelText: isQuantity ? '请输入采集数量' : '请输入/扫描物料、托盘或库位',
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                final trimmed = value.trim();
                if (trimmed.isEmpty) return;
                if (isQuantity) {
                  final quantity = double.tryParse(trimmed) ?? 0;
                  bloc.add(AsrsInventoryCollectQuantityChanged(quantity));
                  bloc.add(const AsrsInventoryCollectRecordAdded());
                } else {
                  bloc.add(AsrsInventoryCollectSearchChanged(trimmed));
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              final value = _inputController.text.trim();
              if (value.isEmpty) return;
              if (isQuantity) {
                final quantity = double.tryParse(value) ?? 0;
                bloc.add(AsrsInventoryCollectQuantityChanged(quantity));
                bloc.add(const AsrsInventoryCollectRecordAdded());
              } else {
                bloc.add(AsrsInventoryCollectSearchChanged(value));
              }
            },
            child: Text(isQuantity ? '添加' : '查询'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailList(
    BuildContext context,
    AsrsInventoryCollectState state,
  ) {
    final details = state.filteredDetails.isEmpty
        ? state.details
        : state.filteredDetails;

    if (details.isEmpty) {
      return const Center(child: Text('暂无任务明细'));
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: details.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final detail = details[index];
        final isSelected = state.selectedDetail?.taskItemId == detail.taskItemId;
        return ListTile(
          selected: isSelected,
          title: Text('${detail.materialCode}  ${detail.materialName}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('库位：${detail.storeSiteNo}  托盘：${detail.trayNo}'),
              Text('计划：${detail.taskQty.toStringAsFixed(2)}  已采集：${detail.collectedQty.toStringAsFixed(2)}  库存：${detail.inventoryQty.toStringAsFixed(2)}'),
              if (detail.batchNo != null && detail.batchNo!.isNotEmpty)
                Text('批次：${detail.batchNo}'),
            ],
          ),
          trailing: Text(
            '剩余 ${detail.remainingQty.toStringAsFixed(2)}',
            style: TextStyle(
              color: detail.remainingQty <= 0 ? Colors.green : Colors.orange,
              fontWeight: FontWeight.w600,
            ),
          ),
          onTap: () => context
              .read<AsrsInventoryCollectBloc>()
              .add(AsrsInventoryCollectDetailSelected(detail)),
        );
      },
    );
  }

  Widget _buildRecordSection(AsrsInventoryCollectState state) {
    if (state.records.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: Colors.blueGrey.shade50,
        child: const Text('尚未添加采集记录'),
      );
    }

    final total = state.records.fold<double>(0, (sum, e) => sum + e.quantity);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      color: Colors.blueGrey.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '已采集记录（共 ${state.records.length} 条，合计 ${total.toStringAsFixed(2)}）',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...state.records.map(
            (record) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text('${record.materialCode}  ${record.materialName}'),
                subtitle: Text('库位：${record.storeSiteNo}  数量：${record.quantity.toStringAsFixed(2)}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => context
                      .read<AsrsInventoryCollectBloc>()
                      .add(AsrsInventoryCollectRecordRemoved(record.id)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitBar(
    BuildContext context,
    AsrsInventoryCollectState state,
  ) {
    final bloc = context.read<AsrsInventoryCollectBloc>();
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: state.selectedDetail != null
                    ? () {
                        bloc.add(const AsrsInventoryCollectRecordAdded());
                      }
                    : null,
                child: const Text('添加记录'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: state.records.isEmpty ||
                        state.status == AsrsInventoryCollectStatus.submitting
                    ? null
                    : () => bloc.add(const AsrsInventoryCollectSubmitted()),
                child: state.status == AsrsInventoryCollectStatus.submitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('提交采集结果'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedDetailCard extends StatelessWidget {
  const _SelectedDetailCard({
    required this.detail,
    required this.quantityFocus,
    required this.onQuantityChanged,
  });

  final AsrsInventoryTaskDetail detail;
  final FocusNode quantityFocus;
  final ValueChanged<String> onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.blue.shade50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '当前明细：${detail.materialCode} ${detail.materialName}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text('库位：${detail.storeSiteNo}    托盘：${detail.trayNo}'),
          Text('计划：${detail.taskQty.toStringAsFixed(2)}  已采集：${detail.collectedQty.toStringAsFixed(2)}'),
          if (detail.batchNo != null && detail.batchNo!.isNotEmpty)
            Text('批次：${detail.batchNo}'),
          const SizedBox(height: 8),
          TextField(
            focusNode: quantityFocus,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: '采集数量 (剩余 ${detail.remainingQty.toStringAsFixed(2)})',
              border: const OutlineInputBorder(),
            ),
            onChanged: onQuantityChanged,
          ),
        ],
      ),
    );
  }
}
