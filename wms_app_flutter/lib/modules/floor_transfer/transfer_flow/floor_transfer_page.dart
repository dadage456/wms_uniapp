import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/common_widgets/custom_app_bar.dart';
import 'package:wms_app/common_widgets/loading_dialog_manager.dart';
import 'package:wms_app/modules/floor_transfer/models/transfer_models.dart';
import 'package:wms_app/modules/floor_transfer/transfer_flow/bloc/floor_transfer_bloc.dart';
import 'package:wms_app/modules/floor_transfer/transfer_flow/bloc/floor_transfer_event.dart';
import 'package:wms_app/modules/floor_transfer/transfer_flow/bloc/floor_transfer_state.dart';
import 'package:wms_app/services/scanner_service.dart';

class FloorTransferPage extends StatefulWidget {
  const FloorTransferPage({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<FloorTransferPage> createState() => _FloorTransferPageState();
}

class _FloorTransferPageState extends State<FloorTransferPage> {
  late final FloorTransferBloc _bloc;
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _queryController = TextEditingController();
  final FocusNode _inputFocus = FocusNode();
  StreamSubscription<String>? _scanSub;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<FloorTransferBloc>();
    _bloc.add(const FloorTransferInitialized());
    if (widget.initialTab != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _bloc.add(FloorTransferTabChanged(widget.initialTab));
      });
    }
    _scanSub = ScannerService.instance.stream.listen((code) {
      if (!mounted) return;
      if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;
      final value = code.trim();
      if (value.isEmpty) return;
      if (_bloc.state.currentTab == 1) {
        final step = _resolveInventoryStep(value);
        _queryController.text = value;
        _bloc.add(FloorTransferInventorySearchRequested(
          keyword: value,
          step: step,
        ));
      } else {
        _bloc.add(FloorTransferScanReceived(value));
      }
    });
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    _inputController.dispose();
    _queryController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _handleManualSubmit(FloorTransferState state) {
    final value = _inputController.text.trim();
    if (value.isEmpty) return;
    if (state.step == TransferStep.quantity) {
      _bloc.add(FloorTransferQuantitySubmitted(value));
    } else {
      _bloc.add(FloorTransferScanReceived(value));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '平库移库',
        onBackPressed: () => Navigator.of(context).pop(),
      ).appBar,
      body: BlocConsumer<FloorTransferBloc, FloorTransferState>(
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
            _bloc.add(const FloorTransferMessageCleared());
          }

          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
            _bloc.add(const FloorTransferMessageCleared());
          }

          if (state.focusInput) {
            FocusScope.of(context).requestFocus(_inputFocus);
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              _buildModeToggle(state),
              _buildInputArea(state),
              _buildStatusSummary(state),
              _buildTabSelector(state),
              Expanded(child: _buildTabContent(state)),
              _buildBottomBar(state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildModeToggle(FloorTransferState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          const Text('操作模式：', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          ChoiceChip(
            label: const Text('移出'),
            selected: state.mode == TransferMode.moveOut,
            onSelected: (value) {
              if (value) {
                _bloc.add(const FloorTransferModeChanged(TransferMode.moveOut));
              }
            },
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('移入'),
            selected: state.mode == TransferMode.moveIn,
            onSelected: (value) {
              if (value) {
                _bloc.add(const FloorTransferModeChanged(TransferMode.moveIn));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(FloorTransferState state) {
    final isQuantity = state.step == TransferStep.quantity;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
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

  Widget _buildStatusSummary(FloorTransferState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          _statusChip('库房', state.storeRoom.isEmpty ? '-' : state.storeRoom),
          _statusChip('来源库位', state.sourceSite.isEmpty ? '-' : state.sourceSite),
          _statusChip('目标库位', state.targetSite.isEmpty ? '-' : state.targetSite),
          _statusChip('物料', state.materialCode.isEmpty ? '-' : state.materialCode),
          _statusChip('批次', state.batchNo.isEmpty ? '-' : state.batchNo),
          _statusChip('序列', state.serialNo.isEmpty ? '-' : state.serialNo),
          _statusChip('子库', state.erpStoreRoom.isEmpty ? '-' : state.erpStoreRoom),
          _statusChip('项目号', state.projectNum.isEmpty ? '-' : state.projectNum),
          _statusChip('数量', state.quantity <= 0 ? '-' : state.quantity.toString()),
        ],
      ),
    );
  }

  Widget _statusChip(String label, String value) {
    return Chip(
      label: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
      backgroundColor: Colors.grey.shade200,
    );
  }

  Widget _buildTabSelector(FloorTransferState state) {
    final tabs = ['采集列表', '库存查询'];
    final children = <Widget>[];
    for (var i = 0; i < tabs.length; i++) {
      final isSelected = state.currentTab == i;
      children.add(
        Expanded(
          child: GestureDetector(
            onTap: () => _bloc.add(FloorTransferTabChanged(i)),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1976D2) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF1976D2)),
              ),
              child: Center(
                child: Text(
                  tabs[i],
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF1976D2),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      if (i < tabs.length - 1) {
        children.add(const SizedBox(width: 12));
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(children: children),
    );
  }

  Widget _buildTabContent(FloorTransferState state) {
    if (state.currentTab == 1) {
      return _buildInventoryQueryTab(state);
    }
    return _buildCollectionTab(state);
  }

  Widget _buildCollectionTab(FloorTransferState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _buildSourceInventoryList(state),
          const SizedBox(height: 12),
          Expanded(
            child: state.records.isEmpty
                ? const Center(child: Text('暂无采集记录'))
                : _buildRecordList(state),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceInventoryList(FloorTransferState state) {
    if (state.sourceStocks.isEmpty) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 180,
      child: Card(
        elevation: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                '来源库存',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: state.sourceStocks.length,
                itemBuilder: (context, index) {
                  final stock = state.sourceStocks[index];
                  return ListTile(
                    dense: true,
                    title: Text('${stock.materialCode}  批次:${stock.batchNo}'),
                    subtitle: Text(
                      '子库:${stock.erpStoreRoom} 项目:${stock.projectNum} 库位:${stock.storeSiteNo} 库存:${stock.availableQty}',
                    ),
                    onTap: () => _bloc.add(FloorTransferStockSelected(stock)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordList(FloorTransferState state) {
    return ListView.separated(
      itemCount: state.records.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final record = state.records[index];
        final selected = state.selectedRecordIds.contains(record.id);
        return CheckboxListTile(
          value: selected,
          onChanged: (value) {
            final ids = List<String>.from(state.selectedRecordIds);
            if (value == true) {
              ids.add(record.id);
            } else {
              ids.remove(record.id);
            }
            _bloc.add(FloorTransferSelectionChanged(ids));
          },
          title: Text('${record.materialCode}  数量:${record.quantity}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('来源:${record.sourceSite}  目标:${record.targetSite}'),
              Text('批次:${record.batchNo} 序列:${record.serialNo.isEmpty ? '-' : record.serialNo}'),
              Text('子库:${record.erpStoreRoom}  项目:${record.projectNum}'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInventoryQueryTab(FloorTransferState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _queryController,
                  decoration: const InputDecoration(
                    labelText: '扫描或输入条码/库位/托盘',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (value) {
                    final trimmed = value.trim();
                    if (trimmed.isEmpty) return;
                    final step = _resolveInventoryStep(trimmed);
                    _bloc.add(FloorTransferInventorySearchRequested(
                      keyword: trimmed,
                      step: step,
                    ));
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  final value = _queryController.text.trim();
                  if (value.isEmpty) return;
                  final step = _resolveInventoryStep(value);
                  _bloc.add(FloorTransferInventorySearchRequested(
                    keyword: value,
                    step: step,
                  ));
                },
                child: const Text('查询'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (state.isInventoryQueryLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state.inventoryQueryResults.isEmpty)
            const Expanded(child: Center(child: Text('暂无库存数据')))
          else
            Expanded(
              child: ListView.separated(
                itemCount: state.inventoryQueryResults.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final stock = state.inventoryQueryResults[index];
                  return ListTile(
                    title: Text('${stock.materialCode}  库存:${stock.availableQty}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('库位:${stock.storeSiteNo}  子库:${stock.erpStoreRoom}'),
                        Text('批次:${stock.batchNo} 序列:${stock.serialNo.isEmpty ? '-' : stock.serialNo}'),
                        Text('库房:${stock.storeRoomName} (${stock.storeRoomNo})'),
                      ],
                    ),
                  );
                },
              ),
            ),
          if (state.inventoryQueryTotalPages > 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: state.inventoryQueryPage > 1
                        ? () => _bloc.add(
                              FloorTransferInventoryPageChanged(state.inventoryQueryPage - 1),
                            )
                        : null,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Text('${state.inventoryQueryPage}/${state.inventoryQueryTotalPages}'),
                  IconButton(
                    onPressed: state.inventoryQueryPage < state.inventoryQueryTotalPages
                        ? () => _bloc.add(
                              FloorTransferInventoryPageChanged(state.inventoryQueryPage + 1),
                            )
                        : null,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _resolveInventoryStep(String input) {
    if (input.contains('MC')) {
      return 'M';
    }
    if (input.contains(r'$TP$')) {
      return 'T';
    }
    if (input.contains(r'$KW$')) {
      return 'S';
    }
    return 'M';
  }

  Widget _buildBottomBar(FloorTransferState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
        color: Colors.white,
      ),
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed: state.selectedRecordIds.isEmpty
                ? null
                : () => _bloc.add(const FloorTransferDeleteSelected()),
            icon: const Icon(Icons.delete_outline),
            label: const Text('删除'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: state.records.isEmpty || state.isSubmitting
                  ? null
                  : () => _bloc.add(const FloorTransferSubmitRequested()),
              icon: const Icon(Icons.cloud_upload_outlined),
              label: const Text('提交'),
            ),
          ),
        ],
      ),
    );
  }
}
