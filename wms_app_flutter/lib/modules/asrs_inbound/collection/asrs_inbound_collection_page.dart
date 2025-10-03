import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/modules/asrs_inbound/collection/bloc/asrs_inbound_collect_bloc.dart';
import 'package:wms_app/modules/asrs_inbound/collection/bloc/asrs_inbound_collect_event.dart';
import 'package:wms_app/modules/asrs_inbound/collection/bloc/asrs_inbound_collect_state.dart';
import 'package:wms_app/modules/asrs_inbound/models/asrs_inbound_models.dart';

class AsrsInboundCollectionPage extends StatefulWidget {
  const AsrsInboundCollectionPage({super.key, required this.task});

  final AsrsInboundTask task;

  @override
  State<AsrsInboundCollectionPage> createState() => _AsrsInboundCollectionPageState();
}

class _AsrsInboundCollectionPageState extends State<AsrsInboundCollectionPage> {
  late final TextEditingController _trayController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _qtyController;

  @override
  void initState() {
    super.initState();
    _trayController = TextEditingController();
    _barcodeController = TextEditingController();
    _qtyController = TextEditingController();
  }

  @override
  void dispose() {
    _trayController.dispose();
    _barcodeController.dispose();
    _qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AsrsInboundCollectBloc, AsrsInboundCollectState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        } else if (state.successMessage != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.successMessage!)));
        }
        if (state.step == AsrsInboundCollectStep.barcode) {
          _barcodeController
            ..text = ''
            ..selection = TextSelection.collapsed(offset: 0);
        }
        if (state.step == AsrsInboundCollectStep.quantity && state.quantity > 0) {
          _qtyController.text = state.quantity.toString();
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text('立库入库采集 - ${widget.task.taskNo}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => context
                    .read<AsrsInboundCollectBloc>()
                    .add(AsrsInboundCollectInitialized(task: widget.task)),
              ),
            ],
          ),
          body: state.status == AsrsInboundCollectStatus.loading &&
                  state.records.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _trayInput(context, state),
                      const SizedBox(height: 16),
                      _barcodeInput(context, state),
                      const SizedBox(height: 16),
                      _quantityInput(context, state),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('加入待提交列表'),
                              onPressed: state.status ==
                                      AsrsInboundCollectStatus.submitting
                                  ? null
                                  : () => context
                                      .read<AsrsInboundCollectBloc>()
                                      .add(const AsrsInboundCollectRecordAdded()),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.cloud_upload),
                              label: const Text('提交'),
                              onPressed: state.canSubmit
                                  ? () => context
                                      .read<AsrsInboundCollectBloc>()
                                      .add(const AsrsInboundCollectSubmitted())
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '待提交记录 (${state.records.length})',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      _RecordTable(records: state.records),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _trayInput(BuildContext context, AsrsInboundCollectState state) {
    if (state.trayNo.isNotEmpty) {
      _trayController.text = state.trayNo;
    }
    return TextField(
      controller: _trayController,
      decoration: InputDecoration(
        labelText: '托盘号',
        suffixIcon: IconButton(
          icon: const Icon(Icons.verified),
          onPressed: () => context.read<AsrsInboundCollectBloc>().add(
                AsrsInboundCollectTrayChanged(_trayController.text.trim()),
              ),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      textInputAction: TextInputAction.done,
      onSubmitted: (value) => context.read<AsrsInboundCollectBloc>().add(
            AsrsInboundCollectTrayChanged(value.trim()),
          ),
    );
  }

  Widget _barcodeInput(BuildContext context, AsrsInboundCollectState state) {
    return TextField(
      controller: _barcodeController,
      decoration: InputDecoration(
        labelText: '物料条码',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        suffixIcon: IconButton(
          icon: const Icon(Icons.qr_code_scanner),
          onPressed: () => context.read<AsrsInboundCollectBloc>().add(
                AsrsInboundCollectBarcodeScanned(
                  _barcodeController.text.trim(),
                ),
              ),
        ),
      ),
      textInputAction: TextInputAction.done,
      onSubmitted: (value) => context.read<AsrsInboundCollectBloc>().add(
            AsrsInboundCollectBarcodeScanned(value.trim()),
          ),
    );
  }

  Widget _quantityInput(BuildContext context, AsrsInboundCollectState state) {
    return TextField(
      controller: _qtyController,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: '采集数量',
        helperText: state.currentDetail == null
            ? '请先扫码物料'
            : '任务剩余 ${(state.currentDetail!.taskQty - state.currentDetail!.collectedQty).clamp(0, state.currentDetail!.taskQty).toStringAsFixed(2)}',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onChanged: (value) {
        final qty = double.tryParse(value) ?? 0;
        context
            .read<AsrsInboundCollectBloc>()
            .add(AsrsInboundCollectQuantityChanged(qty));
      },
    );
  }
}

class _RecordTable extends StatelessWidget {
  const _RecordTable({required this.records});

  final List<AsrsInboundCollectionRecord> records;

  @override
  Widget build(BuildContext context) {
    if (records.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        alignment: Alignment.center,
        child: const Text('暂无记录'),
      );
    }

    return Column(
      children: records
          .map(
            (record) => Card(
              child: ListTile(
                leading: const Icon(Icons.inventory_2),
                title: Text('${record.materialCode}  ${record.materialName}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('批次：${record.batchNo}    序列：${record.serialNo}'),
                    Text('库位：${record.storeSiteNo}'),
                    Text('数量：${record.quantity} ${record.unit}'),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => context
                      .read<AsrsInboundCollectBloc>()
                      .add(AsrsInboundCollectRecordRemoved(record.id)),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
