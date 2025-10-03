import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/common_widgets/custom_app_bar.dart';
import 'package:wms_app/modules/floor_inventory/task_details/bloc/inventory_task_detail_bloc.dart';
import 'package:wms_app/modules/floor_inventory/task_details/bloc/inventory_task_detail_event.dart';
import 'package:wms_app/modules/floor_inventory/task_details/bloc/inventory_task_detail_state.dart';
import 'package:wms_app/modules/floor_inventory/task_details/models/inventory_task_detail.dart';
import 'package:wms_app/modules/floor_inventory/task_list/models/inventory_task.dart';

class InventoryTaskDetailPage extends StatefulWidget {
  const InventoryTaskDetailPage({super.key, this.task});

  final InventoryTask? task;

  @override
  State<InventoryTaskDetailPage> createState() => _InventoryTaskDetailPageState();
}

class _InventoryTaskDetailPageState extends State<InventoryTaskDetailPage> {
  late final InventoryTaskDetailBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<InventoryTaskDetailBloc>();
    final task = widget.task;
    if (task != null) {
      _bloc.add(
        InventoryTaskDetailLoaded(
          taskComment: task.taskComment,
          taskNo: task.taskNo,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    return Scaffold(
      appBar: CustomAppBar(
        title: '盘点任务明细',
        onBackPressed: () => Navigator.of(context).pop(),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _bloc.add(const InventoryTaskDetailRefreshed()),
          ),
        ],
      ).appBar,
      body: BlocBuilder<InventoryTaskDetailBloc, InventoryTaskDetailState>(
        builder: (context, state) {
          if (state.status == InventoryTaskDetailStatus.loading ||
              state.status == InventoryTaskDetailStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.status == InventoryTaskDetailStatus.failure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                    const SizedBox(height: 12),
                    Text(
                      state.errorMessage ?? '加载失败',
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _bloc.add(const InventoryTaskDetailRefreshed()),
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),
            );
          }

          final details = state.details;
          return Column(
            children: [
              if (task != null) _buildTaskSummary(task, details),
              Expanded(
                child: details.isEmpty
                    ? const Center(child: Text('暂无任务明细'))
                    : Scrollbar(
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
                              DataColumn(label: Text('任务数量')),
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
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTaskSummary(InventoryTask task, List<InventoryTaskDetail> details) {
    final totalPlan = details.fold<double>(0, (value, element) => value + element.planQty);
    final totalCollected =
        details.fold<double>(0, (value, element) => value + element.collectedQty);

    return Padding(
      padding: const EdgeInsets.all(16),
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
              const SizedBox(height: 8),
              Text('任务数量合计：${totalPlan.toStringAsFixed(2)}'),
              Text('已采集数量合计：${totalCollected.toStringAsFixed(2)}'),
            ],
          ),
        ),
      ),
    );
  }
}
