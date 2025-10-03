import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/common_widgets/custom_app_bar.dart';
import 'package:wms_app/common_widgets/loading_dialog_manager.dart';
import 'package:wms_app/modules/pull_feeding/bloc/pull_feeding_bloc.dart';
import 'package:wms_app/modules/pull_feeding/bloc/pull_feeding_event.dart';
import 'package:wms_app/modules/pull_feeding/bloc/pull_feeding_state.dart';
import 'package:wms_app/modules/pull_feeding/models/pull_feeding_models.dart';
import 'package:wms_app/services/scanner_service.dart';

class PullFeedingPage extends StatefulWidget {
  const PullFeedingPage({super.key});

  @override
  State<PullFeedingPage> createState() => _PullFeedingPageState();
}

class _PullFeedingPageState extends State<PullFeedingPage> {
  late final PullFeedingBloc _bloc;
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocus = FocusNode();
  StreamSubscription<String>? _scanSubscription;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<PullFeedingBloc>();
    _bloc.add(const PullFeedingInitialized());
    _scanSubscription = ScannerService.instance.stream.listen((code) {
      if (!mounted) return;
      if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;
      final value = code.trim();
      if (value.isEmpty) return;
      _bloc.add(PullFeedingScanReceived(value));
    });
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _inputController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _handleManualSubmit(PullFeedingState state) {
    final value = _inputController.text.trim();
    if (value.isEmpty) return;
    if (state.requiresQuantity) {
      _bloc.add(PullFeedingQuantitySubmitted(value));
    } else {
      _bloc.add(PullFeedingScanReceived(value));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '拉式发料',
        onBackPressed: () => Navigator.of(context).pop(),
      ).appBar,
      body: BlocConsumer<PullFeedingBloc, PullFeedingState>(
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
            _inputController.clear();
            _bloc.add(const PullFeedingMessageCleared());
          }

          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
            _bloc.add(const PullFeedingMessageCleared());
          }

          if (state.focusInput) {
            FocusScope.of(context).requestFocus(_inputFocus);
          } else if (_inputFocus.hasFocus) {
            _inputFocus.unfocus();
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              _buildInputArea(state),
              _buildStatusSummary(state),
              const Divider(height: 1),
              Expanded(child: _buildRecordList(state)),
              _buildBottomBar(state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInputArea(PullFeedingState state) {
    final isQuantity = state.step == PullFeedingStep.quantity;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              focusNode: isQuantity ? _inputFocus : null,
              keyboardType: isQuantity
                  ? const TextInputType.numberWithOptions(decimal: true)
                  : TextInputType.text,
              decoration: InputDecoration(
                labelText: state.placeholder.isEmpty ? '请采集' : state.placeholder,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _handleManualSubmit(state),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => _handleManualSubmit(state),
            child: const Text('录入'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSummary(PullFeedingState state) {
    final barcode = state.barcodeContent;
    final totalCollected = state.records.fold<double>(0, (sum, e) => sum + e.quantity);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          _statusChip('库位', state.storeSite.isEmpty ? '-' : state.storeSite),
          _statusChip('物料', barcode?.materialCode ?? '-'),
          if (barcode?.materialName != null && barcode!.materialName!.isNotEmpty)
            _statusChip('物料名称', barcode.materialName!),
          _statusChip('库存', _formatNumber(state.inventoryQty)),
          _statusChip('最小包装数', _formatNumber(state.quantityRule.minPackageQty)),
          _statusChip('配送量', _formatNumber(state.quantityRule.defaultDeliveryQty)),
          _statusChip('已采集合计', _formatNumber(totalCollected)),
        ],
      ),
    );
  }

  Widget _statusChip(String label, String value) {
    return Chip(
      label: Text('$label：$value'),
      backgroundColor: const Color(0xFFE8F3FF),
    );
  }

  Widget _buildRecordList(PullFeedingState state) {
    if (state.records.isEmpty) {
      return const Center(
        child: Text('暂无采集记录'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemBuilder: (context, index) {
        final record = state.records[index];
        final selected = state.selectedRecordIds.contains(record.id);
        return Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              final updated = Set<String>.from(state.selectedRecordIds);
              if (selected) {
                updated.remove(record.id);
              } else {
                updated.add(record.id);
              }
              _bloc.add(PullFeedingSelectionChanged(updated.toList()));
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Checkbox(
                    value: selected,
                    onChanged: (value) {
                      final updated = Set<String>.from(state.selectedRecordIds);
                      if (value == true) {
                        updated.add(record.id);
                      } else {
                        updated.remove(record.id);
                      }
                      _bloc.add(PullFeedingSelectionChanged(updated.toList()));
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '库位：${record.storeSite}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        Text('物料：${record.materialCode}'),
                        if ((record.materialName ?? '').isNotEmpty)
                          Text('物料名称：${record.materialName}'),
                      ],
                    ),
                  ),
                  Text(
                    _formatNumber(record.quantity),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemCount: state.records.length,
    );
  }

  Widget _buildBottomBar(PullFeedingState state) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: state.records.isEmpty
                    ? null
                    : () => _bloc.add(const PullFeedingDeleteSelected()),
                child: const Text('删除'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: state.isSubmitting
                    ? null
                    : () => _bloc.add(const PullFeedingSubmitRequested()),
                child: const Text('提交'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(num value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2);
  }
}
