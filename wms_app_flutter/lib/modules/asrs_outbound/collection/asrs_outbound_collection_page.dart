import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/modules/asrs_outbound/collection/bloc/asrs_outbound_collect_bloc.dart';
import 'package:wms_app/modules/asrs_outbound/collection/bloc/asrs_outbound_collect_event.dart';
import 'package:wms_app/modules/asrs_outbound/collection/bloc/asrs_outbound_collect_state.dart';
import 'package:wms_app/modules/asrs_outbound/models/asrs_outbound_models.dart';
import 'package:wms_app/services/scanner_service.dart';

class AsrsOutboundCollectionPage extends StatefulWidget {
  const AsrsOutboundCollectionPage({super.key, required this.task});

  final AsrsOutboundTask task;

  @override
  State<AsrsOutboundCollectionPage> createState() =>
      _AsrsOutboundCollectionPageState();
}

class _AsrsOutboundCollectionPageState
    extends State<AsrsOutboundCollectionPage> {
  late final AsrsOutboundCollectBloc _bloc;
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _quantityFocus = FocusNode();
  StreamSubscription<String>? _scanSubscription;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<AsrsOutboundCollectBloc>();
    _bloc.add(AsrsOutboundCollectStarted(widget.task));
    _scanSubscription = ScannerService.instance.stream.listen((code) {
      if (!mounted) return;
      if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;
      final value = code.trim();
      if (value.isEmpty) return;
      _bloc.add(AsrsOutboundCollectScanReceived(value));
    });
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _inputController.dispose();
    _quantityFocus.dispose();
    super.dispose();
  }

  void _handleManualSubmit(AsrsOutboundCollectState state) {
    final value = _inputController.text.trim();
    if (value.isEmpty) return;
    if (state.step == AsrsCollectStep.inputQuantity) {
      final quantity = double.tryParse(value);
      if (quantity == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('数量格式不正确')),
        );
        return;
      }
      _bloc.add(AsrsOutboundCollectQuantitySubmitted(quantity));
    } else {
      _bloc.add(AsrsOutboundCollectScanReceived(value));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AsrsOutboundCollectBloc, AsrsOutboundCollectState>(
      listener: (context, state) {
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.successMessage!)),
          );
          _bloc.add(const AsrsOutboundCollectMessageCleared());
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
          _bloc.add(const AsrsOutboundCollectMessageCleared());
        }
        if (state.focusQuantity) {
          FocusScope.of(context).requestFocus(_quantityFocus);
        } else if (_quantityFocus.hasFocus && state.step != AsrsCollectStep.inputQuantity) {
          _quantityFocus.unfocus();
        }
        if (state.clearScanField) {
          _inputController.clear();
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text('立库出库采集 - ${widget.task.taskNo}'),
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  _buildInputArea(state),
                  _buildStatusChips(state),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildDetailCard(state),
                        const SizedBox(height: 16),
                        _buildRecordCard(state),
                      ],
                    ),
                  ),
                  _buildBottomBar(state),
                ],
              ),
              if (state.status == AsrsOutboundCollectStatus.submitting ||
                  state.isLoadingMaterial)
                Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInputArea(AsrsOutboundCollectState state) {
    final isQuantity = state.step == AsrsCollectStep.inputQuantity;
    final label = _stepHint(state.step);
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
                labelText: label,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _handleManualSubmit(state),
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: () => _handleManualSubmit(state),
            child: const Text('录入'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChips(AsrsOutboundCollectState state) {
    final material = state.materialInfo;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          _statusChip('当前步骤', _stepLabel(state.step)),
          _statusChip('库位', state.storeSite.isEmpty ? '-' : state.storeSite),
          _statusChip('托盘', state.trayNo.isEmpty ? '-' : state.trayNo),
          _statusChip('物料', material?.materialCode ?? '-'),
          if (material?.materialName.isNotEmpty ?? false)
            _statusChip('物料名称', material!.materialName),
          if (material?.batchNo.isNotEmpty ?? false)
            _statusChip('批次', material!.batchNo),
          if (material?.serialNo.isNotEmpty ?? false)
            _statusChip('序列号', material!.serialNo),
          _statusChip('库存', state.inventoryQty.toStringAsFixed(2)),
          _statusChip('记录数', state.records.length.toString()),
        ],
      ),
    );
  }

  Widget _buildDetailCard(AsrsOutboundCollectState state) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '任务明细',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text('${state.details.length} 条'),
              ],
            ),
            const SizedBox(height: 12),
            if (state.details.isEmpty)
              const Text('暂无未完成的任务明细'),
            if (state.details.isNotEmpty)
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.details.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final detail = state.details[index];
                  final selected = state.selectedDetail?.taskItemId == detail.taskItemId;
                  return ListTile(
                    leading: Icon(
                      selected ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: selected ? const Color(0xFF465CFF) : Colors.grey,
                    ),
                    title: Text('${detail.materialCode}  ${detail.materialName}'),
                    subtitle: Text(
                      '库位:${detail.storeSiteNo} 托盘:${detail.palletNo} 数量:${detail.taskQty}',
                    ),
                    onTap: () {
                      _bloc.add(AsrsOutboundCollectDetailSelected(detail));
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordCard(AsrsOutboundCollectState state) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '采集记录',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text('${state.records.length} 条'),
              ],
            ),
            const SizedBox(height: 12),
            if (state.records.isEmpty)
              const Text('尚未采集任何记录'),
            if (state.records.isNotEmpty)
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.records.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final record = state.records[index];
                  return ListTile(
                    title: Text('${record.materialCode}  ${record.materialName}'),
                    subtitle: Text(
                      '库位:${record.storeSite} 托盘:${record.trayNo} 数量:${record.quantity}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () {
                        _bloc.add(AsrsOutboundCollectRecordRemoved(record.id));
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(AsrsOutboundCollectState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 8,
            color: Colors.black.withValues(alpha: 0.08),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: state.status == AsrsOutboundCollectStatus.submitting
                  ? null
                  : () => _bloc.add(const AsrsOutboundCollectSubmitRequested()),
              icon: const Icon(Icons.cloud_upload_outlined),
              label: const Text('提交采集'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: state.status == AsrsOutboundCollectStatus.submitting
                  ? null
                  : () => _bloc.add(const AsrsOutboundCollectResetRequested()),
              icon: const Icon(Icons.refresh),
              label: const Text('重置流程'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String label, String value) {
    return Chip(
      label: Text('$label：$value'),
      backgroundColor: const Color(0xFFEFF3FF),
    );
  }

  String _stepHint(AsrsCollectStep step) {
    switch (step) {
      case AsrsCollectStep.scanSite:
        return '请扫描库位条码';
      case AsrsCollectStep.scanTray:
        return '请扫描托盘条码';
      case AsrsCollectStep.scanMaterial:
        return '请扫描物料条码';
      case AsrsCollectStep.inputQuantity:
        return '请输入采集数量';
      case AsrsCollectStep.idle:
        return '采集完成，可继续扫描';
    }
  }

  String _stepLabel(AsrsCollectStep step) {
    switch (step) {
      case AsrsCollectStep.scanSite:
        return '扫描库位';
      case AsrsCollectStep.scanTray:
        return '扫描托盘';
      case AsrsCollectStep.scanMaterial:
        return '扫描物料';
      case AsrsCollectStep.inputQuantity:
        return '录入数量';
      case AsrsCollectStep.idle:
        return '完成';
    }
  }
}
