import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/common_widgets/custom_app_bar.dart';
import 'package:wms_app/common_widgets/loading_dialog_manager.dart';
import 'package:wms_app/modules/floor_inbound/collection_task/bloc/inbound_collection_bloc.dart';
import 'package:wms_app/modules/floor_inbound/collection_task/bloc/inbound_collection_event.dart';
import 'package:wms_app/modules/floor_inbound/collection_task/bloc/inbound_collection_state.dart';
import 'package:wms_app/modules/floor_inbound/collection_task/models/inbound_collection_models.dart';
import 'package:wms_app/modules/floor_inbound/task_list/models/inbound_task.dart';
import 'package:wms_app/services/scanner_service.dart';

class InboundCollectionPage extends StatefulWidget {
  const InboundCollectionPage({super.key, required this.task, required this.userId});

  final InboundTask task;
  final int userId;

  @override
  State<InboundCollectionPage> createState() => _InboundCollectionPageState();
}

class _InboundCollectionPageState extends State<InboundCollectionPage> {
  late final InboundCollectionBloc _bloc;
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _scanController = TextEditingController();
  StreamSubscription<String>? _scanSubscription;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<InboundCollectionBloc>(context);
    _bloc.add(InitializeInboundCollection(task: widget.task, userId: widget.userId));

    _scanSubscription = ScannerService.instance.stream.listen(
      (code) {
        if (!mounted) return;
        if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;
        final trimmed = code.trim();
        if (trimmed.isEmpty) return;
        _bloc.add(InboundScanPerformed(trimmed));
      },
      onError: (error, __) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('扫码异常：$error')),
        );
      },
    );
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _scanController.dispose();
    _scanSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: '上架采集-${widget.task.inTaskNo}').appBar,
      body: BlocConsumer<InboundCollectionBloc, InboundCollectionState>(
        listener: (context, state) {
          if (state.isLoading) {
            LoadingDialogManager.instance.showLoadingDialog(context);
          } else {
            LoadingDialogManager.instance.hideLoadingDialog(context);
          }
          if (state.errorMessage != null) {
            LoadingDialogManager.instance.showErrorDialog(context, state.errorMessage!);
          }
          if (state.infoMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.infoMessage!)),
            );
          }
        },
        builder: (context, state) {
          final ctx = state.context;
          return Column(
            children: [
              _buildScanPanel(),
              _buildStepIndicator(ctx),
              if (ctx != null) _buildCurrentTarget(ctx),
              _buildQuantityInput(ctx),
              const Divider(height: 1),
              Expanded(child: _buildRecordList(ctx)),
              _buildSubmitBar(ctx),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStepIndicator(InboundCollectionContext? ctx) {
    final current = ctx?.currentStep ?? InboundScanStep.site;
    String description;
    switch (current) {
      case InboundScanStep.site:
        description = '请先扫描库位条码';
        break;
      case InboundScanStep.material:
        description = '库位已识别，请扫描物料条码';
        break;
      case InboundScanStep.hazardProduction:
        description = '危化品物料，需要录入生产日期（YYYY-MM-DD）';
        break;
      case InboundScanStep.hazardExpiry:
        description = '危化品物料，需要录入有效期天数';
        break;
      case InboundScanStep.quantity:
        description = '物料已识别，请录入数量';
        break;
    }
    final stepOrder = {
      InboundScanStep.site: 1,
      InboundScanStep.material: 2,
      InboundScanStep.hazardProduction: 3,
      InboundScanStep.hazardExpiry: 4,
      InboundScanStep.quantity: 5,
    }[current]!;
    final totalSteps = (ctx?.materialInfo?.isHazard ?? false) ? 5 : 3;
    return ListTile(
      title: Text(description, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('步骤：$stepOrder/$totalSteps'),
    );
  }

  Widget _buildScanPanel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _scanController,
              decoration: const InputDecoration(
                hintText: '扫描或输入条码后回车',
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _bloc.add(InboundScanPerformed(value));
                  _scanController.clear();
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              final text = _scanController.text.trim();
              if (text.isNotEmpty) {
                _bloc.add(InboundScanPerformed(text));
                _scanController.clear();
              }
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTarget(InboundCollectionContext ctx) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('当前库位: ${ctx.currentSite ?? '-'}'),
          Text('当前物料: ${ctx.currentTaskItem?.matCode ?? '-'} ${ctx.currentTaskItem?.matName ?? ''}'),
          Text('计划数量: ${ctx.currentTaskItem?.planQty ?? 0} 已采集: ${ctx.currentTaskItem?.collectedQty ?? 0}'),
          Text('库位可用库存: ${ctx.availableQty.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  Widget _buildQuantityInput(InboundCollectionContext? ctx) {
    final showInput = ctx?.currentStep == InboundScanStep.quantity;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: showInput
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _qtyController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: '输入数量'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      final qty = double.tryParse(_qtyController.text.trim());
                      if (qty != null && qty > 0) {
                        _bloc.add(InboundManualQuantityConfirmed(qty));
                        _qtyController.clear();
                      }
                    },
                    child: const Text('确认'),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildRecordList(InboundCollectionContext? ctx) {
    final records = ctx?.cache.records ?? const <InboundCollectionRecord>[];
    if (records.isEmpty) {
      return const Center(child: Text('暂无采集记录'));
    }
    return ListView.separated(
      itemCount: records.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final record = records[index];
        return ListTile(
          title: Text('${record.matCode} - ${record.matName}'),
          subtitle: Text('库位:${record.storeSiteNo} 批次:${record.batchNo} 数量:${record.quantity}'),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () => _bloc.add(InboundRemoveRecord(index)),
          ),
        );
      },
    );
  }

  Widget _buildSubmitBar(InboundCollectionContext? ctx) {
    final hasRecords = (ctx?.cache.records ?? const []).isNotEmpty;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.cloud_upload),
          label: const Text('提交上架结果'),
          onPressed: hasRecords ? () => _bloc.add(const SubmitInboundCollection()) : null,
        ),
      ),
    );
  }
}
