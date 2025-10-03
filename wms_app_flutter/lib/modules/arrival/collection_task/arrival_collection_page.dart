import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:wms_app/common_widgets/custom_app_bar.dart';
import 'package:wms_app/modules/arrival/collection_task/bloc/arrival_collection_bloc.dart';
import 'package:wms_app/modules/arrival/collection_task/bloc/arrival_collection_event.dart';
import 'package:wms_app/modules/arrival/collection_task/bloc/arrival_collection_state.dart';
import 'package:wms_app/modules/arrival/collection_task/models/arrival_collection_models.dart';
import 'package:wms_app/modules/arrival/task_list/models/arrival_task.dart';
import 'package:wms_app/services/scanner_service.dart';

class ArrivalCollectionPage extends StatefulWidget {
  const ArrivalCollectionPage({super.key, required this.task});

  final ArrivalTask task;

  @override
  State<ArrivalCollectionPage> createState() => _ArrivalCollectionPageState();
}

class _ArrivalCollectionPageState extends State<ArrivalCollectionPage> {
  late final ArrivalCollectionBloc _bloc;
  final TextEditingController _scanController = TextEditingController();
  final FocusNode _scanFocusNode = FocusNode();
  StreamSubscription<String>? _scanSubscription;
  bool _isPromptVisible = false;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<ArrivalCollectionBloc>(context);
    _bloc.add(InitializeArrivalCollection(task: widget.task));
    _scanSubscription = ScannerService.instance.stream.listen(_handleScan);
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _scanController.dispose();
    _scanFocusNode.dispose();
    super.dispose();
  }

  void _handleScan(String code) {
    if (!mounted) return;
    if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;
    final trimmed = code.trim();
    if (trimmed.isEmpty) return;
    _scanController.text = trimmed;
    _bloc.add(ArrivalCollectionScanReceived(trimmed));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '到货签收采集',
        onBackPressed: () => Modular.to.pop(),
      ).appBar,
      body: BlocConsumer<ArrivalCollectionBloc, ArrivalCollectionState>(
        listener: _onStateChanged,
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              _buildTaskHeader(widget.task),
              _buildScanInput(state),
              if (state.isSubmitting)
                const LinearProgressIndicator(minHeight: 2),
              _buildTabSelector(state),
              Expanded(
                child: IndexedStack(
                  index: state.currentTab,
                  children: [
                    _buildDetailList(state),
                    _buildRecordList(state),
                  ],
                ),
              ),
              _buildSubmitBar(state),
            ],
          );
        },
      ),
    );
  }

  void _onStateChanged(BuildContext context, ArrivalCollectionState state) {
    if (state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.errorMessage!)),
      );
      _bloc.add(const ArrivalCollectionMessagesCleared());
    }
    if (state.successMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.successMessage!)),
      );
      _bloc.add(const ArrivalCollectionMessagesCleared());
    }

    if (state.prompt != null && !_isPromptVisible) {
      _showQuantityDialog(state.prompt!);
    }
  }

  Widget _buildTaskHeader(ArrivalTask task) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '到货单号：${task.arrivalsBillNo}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: [
              Text('装箱单号：${task.orderNo}'),
              Text('采购单号：${task.poNumber}'),
              Text('供应商：${task.supplierName}'),
              Text('到货日期：${task.createDate}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScanInput(ArrivalCollectionState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: TextField(
        controller: _scanController,
        focusNode: _scanFocusNode,
        decoration: InputDecoration(
          labelText: '扫描/输入物料条码',
          hintText: state.placeholder,
          suffixIcon: IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              _scanController.clear();
              _scanFocusNode.requestFocus();
            },
          ),
          border: const OutlineInputBorder(),
        ),
        textInputAction: TextInputAction.done,
        onSubmitted: (value) {
          final trimmed = value.trim();
          if (trimmed.isEmpty) return;
          _bloc.add(ArrivalCollectionScanReceived(trimmed));
        },
      ),
    );
  }

  Widget _buildTabSelector(ArrivalCollectionState state) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          ChoiceChip(
            label: const Text('任务列表'),
            selected: state.currentTab == 0,
            onSelected: (_) =>
                _bloc.add(const ArrivalCollectionTabChanged(0)),
          ),
          const SizedBox(width: 12),
          ChoiceChip(
            label: Text('采集结果 (${state.records.length})'),
            selected: state.currentTab == 1,
            onSelected: (_) =>
                _bloc.add(const ArrivalCollectionTabChanged(1)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailList(ArrivalCollectionState state) {
    if (state.details.isEmpty) {
      return const Center(child: Text('暂无任务明细'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: state.details.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final detail = state.details[index];
        final remaining = (detail.planQty - detail.collectedQty).clamp(0, detail.planQty);
        return Card(
          elevation: 0,
          child: ListTile(
            title: Text(
              '${detail.materialCode}  ${detail.materialName}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('批次：${detail.batchNo.isEmpty ? '-' : detail.batchNo}'),
                  Text('序列：${detail.serialNo.isEmpty ? '-' : detail.serialNo}'),
                  Text('控制属性：${detail.controlMode.isEmpty ? '-' : detail.controlMode}'),
                  Text('库房/子库：${detail.storeRoom} / ${detail.subInventory}'),
                ],
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('任务：${detail.planQty.toStringAsFixed(2)}'),
                Text('已采：${detail.collectedQty.toStringAsFixed(2)}'),
                Text('剩余：${remaining.toStringAsFixed(2)}'),
              ],
            ),
            onTap: () => _bloc.add(ArrivalCollectionDetailSelected(detail)),
          ),
        );
      },
    );
  }

  Widget _buildRecordList(ArrivalCollectionState state) {
    if (state.records.isEmpty) {
      return const Center(child: Text('尚未采集任何明细'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: state.records.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final record = state.records[index];
        return Card(
          elevation: 0,
          child: ListTile(
            title: Text('${record.materialCode}  ${record.materialName}'),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('批次：${record.batchNo?.isNotEmpty == true ? record.batchNo : '-'}'),
                  Text('序列：${record.serialNo?.isNotEmpty == true ? record.serialNo : '-'}'),
                  Text('采集标记：${record.collectFlag == '0' ? '匹配' : '不匹配'}'),
                ],
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('数量：${record.quantity.toStringAsFixed(2)}'),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: '删除记录',
                  onPressed: () =>
                      _bloc.add(ArrivalCollectionRecordRemoved(record.id)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubmitBar(ArrivalCollectionState state) {
    final totalQuantity = state.records.fold<double>(
      0,
      (previousValue, element) => previousValue + element.quantity,
    );

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x11000000),
              offset: Offset(0, -2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '本次采集合计：${totalQuantity.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton.icon(
              onPressed: state.isSubmitting
                  ? null
                  : () => _bloc.add(const ArrivalCollectionSubmitRequested()),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('提交'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showQuantityDialog(ArrivalCollectionPrompt prompt) async {
    _isPromptVisible = true;
    final controller = TextEditingController(
      text: prompt.suggestedQty != null
          ? prompt.suggestedQty!.toStringAsFixed(2)
          : '',
    );

    final detail = prompt.detail;
    final remaining = prompt.remainingQty;

    final result = await showDialog<double>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('采集 ${detail.materialCode}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('物料：${detail.materialName}'),
              const SizedBox(height: 8),
              Text('剩余数量：${remaining.toStringAsFixed(2)}'),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: '采集数量',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = double.tryParse(controller.text.trim());
                if (value == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('请输入正确的数字')),
                  );
                  return;
                }
                Navigator.of(context).pop(value);
              },
              child: const Text('确认'),
            ),
          ],
        );
      },
    );

    _isPromptVisible = false;
    if (!mounted) return;

    if (result != null) {
      _bloc.add(ArrivalCollectionQuantitySubmitted(result));
    } else {
      _bloc.add(const ArrivalCollectionPromptDismissed());
    }
  }
}
