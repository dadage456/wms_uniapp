import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:wms_app/common_widgets/common_grid/common_data_grid.dart';
import 'package:wms_app/common_widgets/loading_dialog_manager.dart';
import 'package:wms_app/modules/floor_exception/exception_collection/bloc/floor_exception_collect_bloc.dart';
import 'package:wms_app/modules/floor_exception/exception_collection/bloc/floor_exception_collect_event.dart';
import 'package:wms_app/modules/floor_exception/exception_collection/bloc/floor_exception_collect_state.dart';
import 'package:wms_app/modules/floor_exception/exception_collection/models/floor_exception_collect_models.dart';
import 'package:wms_app/modules/floor_exception/exception_collection/models/floor_exception_collection_args.dart';
import 'package:wms_app/modules/floor_exception/exception_task_list/models/exception_task.dart';
import 'package:wms_app/services/scanner_service.dart';

class FloorExceptionCollectionPage extends StatefulWidget {
  const FloorExceptionCollectionPage({super.key, required this.args});

  final FloorExceptionCollectionArgs args;

  @override
  State<FloorExceptionCollectionPage> createState() =>
      _FloorExceptionCollectionPageState();
}

class _FloorExceptionCollectionPageState
    extends State<FloorExceptionCollectionPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late FloorExceptionCollectBloc _bloc;
  StreamSubscription<String>? _scanSubscription;

  static const List<FloorExceptionTypeOption> _exceptionOptions = [
    FloorExceptionTypeOption(value: '010', label: '小包装发料'),
    FloorExceptionTypeOption(value: '006', label: '整包装多料'),
    FloorExceptionTypeOption(value: '007', label: '整包装少料'),
    FloorExceptionTypeOption(value: '008', label: '混料'),
    FloorExceptionTypeOption(value: '009', label: '质量问题'),
  ];

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<FloorExceptionCollectBloc>(context);
    final summary = widget.args.taskSummary;
    _bloc.add(
      FloorExceptionInitializeEvent(
        taskSummary: summary,
        trayNo: summary?.trayNo ?? '',
        initialStoreSite: '',
      ),
    );

    _scanSubscription = ScannerService.instance.stream.listen(
      (code) {
        if (code.isEmpty || !mounted) return;
        final isCurrent = ModalRoute.of(context)?.isCurrent ?? false;
        if (!isCurrent) return;
        _bloc.add(FloorExceptionPerformScanEvent(code));
      },
      onError: (error) {
        if (!mounted) return;
        _showErrorDialog('扫码组件出错：$error');
      },
    );
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final summary = widget.args.taskSummary ?? const FloorExceptionTaskSummary();
    return WillPopScope(
      onWillPop: () async {
        final canLeave = await _confirmLeaveIfNeeded();
        return canLeave;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F6F6),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1976D2),
          centerTitle: true,
          elevation: 0,
          title: const Text(
            '异常采集',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () async {
              final canLeave = await _confirmLeaveIfNeeded();
              if (canLeave && mounted) {
                Modular.to.pop();
              }
            },
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(32),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                summary.taskNo.isNotEmpty
                    ? '任务号：${summary.taskNo}'
                    : '未绑定异常任务',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ),
        ),
        body: BlocConsumer<FloorExceptionCollectBloc, FloorExceptionCollectState>(
          listener: (context, state) {
            if (state.isLoading) {
              LoadingDialogManager.instance.showLoadingDialog(context);
            } else {
              LoadingDialogManager.instance.hideLoadingDialog(context);
            }

            if (state.error != null) {
              _showErrorDialog(state.error!);
              _bloc.add(const FloorExceptionClearErrorEvent());
            }

            if (state.successMessage != null) {
              LoadingDialogManager.instance.showSnackSuccessMsg(
                context,
                state.successMessage!,
                duration: const Duration(milliseconds: 800),
              );
              _bloc.add(const FloorExceptionClearMessageEvent());
              if (mounted) Modular.to.pop(true);
            }

            if (state.focus) {
              _focusNode.requestFocus();
            }

            _controller.clear();
          },
          builder: (context, state) {
            return Column(
              children: [
                _buildScanInput(state.placeholder),
                _buildInfoCard(state, summary),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: _buildDataGrid(state),
                  ),
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  Widget _buildScanInput(String placeholder) {
    return Container(
      height: 44,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: const BoxDecoration(color: Colors.white),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        textInputAction: TextInputAction.done,
        keyboardType: TextInputType.text,
        onSubmitted: (value) {
          _bloc.add(FloorExceptionPerformScanEvent(value));
        },
        decoration: InputDecoration(
          hintText: placeholder,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    FloorExceptionCollectState state,
    FloorExceptionTaskSummary summary,
  ) {
    final trayNo = state.trayNo.isEmpty ? (summary.trayNo.isEmpty ? '-' : summary.trayNo) : state.trayNo;
    final storeSite = state.storeSite.isEmpty ? '-' : state.storeSite;
    final matCode = state.matCode.isEmpty
        ? (state.barcodeContent?.matcode ?? '')
        : state.matCode;
    final batchNo = state.batchNo.isEmpty
        ? (state.barcodeContent?.batchno ?? '')
        : state.batchNo;
    final sn = state.sn.isEmpty ? (state.barcodeContent?.sn ?? '') : state.sn;
    final qty = state.collectQty == 0 ? '' : state.collectQty.toString();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
      ),
      child: Column(
        children: [
          _buildInfoRow('托盘号：', trayNo, '库位编码：', storeSite),
          _buildDottedDivider(),
          _buildInfoRow('物料：', matCode, '库房：', summary.storeRoom.isEmpty ? '-' : summary.storeRoom),
          _buildDottedDivider(),
          _buildInfoRow('批次：', batchNo, '序列：', sn),
          _buildDottedDivider(),
          _buildInfoRow('采集数量：', qty, '异常类型：', state.exceptionName),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String leftTitle, String leftValue, String rightTitle, String rightValue) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '$leftTitle$leftValue',
            style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
          ),
        ),
        Expanded(
          child: Text(
            '$rightTitle$rightValue',
            style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildDottedDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final dashWidth = 4.0;
          final dashHeight = 1.0;
          final dashCount = (constraints.maxWidth / (dashWidth * 2)).floor();
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              dashCount,
              (_) => SizedBox(
                width: dashWidth,
                height: dashHeight,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Colors.grey[400]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDataGrid(FloorExceptionCollectState state) {
    return CommonDataGrid<FloorExceptionCollectionItem>(
      columns: _buildColumns(),
      datas: state.items,
      allowPager: false,
      allowSelect: true,
      currentPage: 1,
      totalPages: 1,
      onLoadData: (_) async {},
      selectedRows: _selectedIndices(state.items, state.selectedIds),
      onSelectionChanged: (indices) {
        _handleSelectionChanged(indices, state.items);
      },
    );
  }

  List<GridColumnConfig<FloorExceptionCollectionItem>> _buildColumns() {
    return [
      GridColumnConfig<FloorExceptionCollectionItem>(
        name: 'matCode',
        headerText: '物料编码',
        valueGetter: (row) => row.matCode,
      ),
      GridColumnConfig<FloorExceptionCollectionItem>(
        name: 'storeSite',
        headerText: '库位',
        valueGetter: (row) => row.storeSite,
      ),
      GridColumnConfig<FloorExceptionCollectionItem>(
        name: 'exceptionName',
        headerText: '异常类型',
        valueGetter: (row) => row.exceptionName,
      ),
      GridColumnConfig<FloorExceptionCollectionItem>(
        name: 'qty',
        headerText: '采集数',
        valueGetter: (row) => row.qty,
      ),
      GridColumnConfig<FloorExceptionCollectionItem>(
        name: 'batchNo',
        headerText: '批号',
        valueGetter: (row) => row.batchNo,
      ),
      GridColumnConfig<FloorExceptionCollectionItem>(
        name: 'sn',
        headerText: '序列号',
        valueGetter: (row) => row.sn,
      ),
      GridColumnConfig<FloorExceptionCollectionItem>(
        name: 'storeRoom',
        headerText: '库房',
        valueGetter: (row) => row.storeRoom,
      ),
      GridColumnConfig<FloorExceptionCollectionItem>(
        name: 'proType',
        headerText: '类型',
        valueGetter: (row) => row.proType,
      ),
      GridColumnConfig<FloorExceptionCollectionItem>(
        name: 'taskId',
        headerText: '任务ID',
        valueGetter: (row) => row.taskId,
      ),
    ];
  }

  List<int> _selectedIndices(
    List<FloorExceptionCollectionItem> items,
    List<String> selectedIds,
  ) {
    final idSet = selectedIds.toSet();
    final indices = <int>[];
    for (var i = 0; i < items.length; i++) {
      if (idSet.contains(items[i].id)) {
        indices.add(i);
      }
    }
    return indices;
  }

  void _handleSelectionChanged(
    List<int> indices,
    List<FloorExceptionCollectionItem> items,
  ) {
    final ids = indices.map((index) => items[index].id).toList();
    _bloc.add(FloorExceptionSelectionChangedEvent(ids));
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: const BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _showExceptionTypeSelector,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1976D2),
                side: const BorderSide(color: Color(0xFF1976D2)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('异常类型'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: () =>
                  _bloc.add(const FloorExceptionDeleteSelectedEvent()),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFE55D52),
                side: const BorderSide(color: Color(0xFFE55D52)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('删除'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _handleCommit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('提交'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showExceptionTypeSelector() async {
    final currentType = _bloc.state.exceptionType;
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: _exceptionOptions.map((option) {
            final selected = option.value == currentType;
            return ListTile(
              title: Text(option.label),
              trailing: selected
                  ? const Icon(Icons.check, color: Color(0xFF1976D2))
                  : null,
              onTap: () {
                _bloc.add(
                  FloorExceptionTypeChangedEvent(
                    type: option.value,
                    name: option.label,
                  ),
                );
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _handleCommit() async {
    final state = _bloc.state;
    if (state.stocks.isEmpty) {
      _showErrorDialog('本次无采集明细，请确认！');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('提交确认'),
        content: const Text('请确认是否提交？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确认'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _bloc.add(const FloorExceptionCommitRequestedEvent());
    }
  }

  Future<bool> _confirmLeaveIfNeeded() async {
    if (_bloc.state.stocks.isEmpty) {
      return true;
    }

    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('提示'),
        content: const Text('当前采集记录尚未提交，确定退出采集吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确认'),
          ),
        ],
      ),
    );

    return shouldLeave ?? false;
  }

  void _showErrorDialog(String message) {
    LoadingDialogManager.instance.showErrorDialog(context, message);
  }
}
