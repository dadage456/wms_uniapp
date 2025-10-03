import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/modules/asrs_inventory/models/asrs_inventory_models.dart';
import 'package:wms_app/modules/asrs_inventory/task_detail/bloc/asrs_inventory_detail_bloc.dart';
import 'package:wms_app/modules/asrs_inventory/task_detail/bloc/asrs_inventory_detail_event.dart';
import 'package:wms_app/modules/asrs_inventory/task_detail/bloc/asrs_inventory_detail_state.dart';

class AsrsInventoryTaskDetailPage extends StatefulWidget {
  const AsrsInventoryTaskDetailPage({super.key, required this.task});

  final AsrsInventoryTask task;

  @override
  State<AsrsInventoryTaskDetailPage> createState() =>
      _AsrsInventoryTaskDetailPageState();
}

class _AsrsInventoryTaskDetailPageState
    extends State<AsrsInventoryTaskDetailPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AsrsInventoryDetailBloc, AsrsInventoryDetailState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      builder: (context, state) {
        final task = state.task ?? widget.task;
        return Scaffold(
          appBar: AppBar(
            title: Text('盘点明细 - ${task.taskComment}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => context
                    .read<AsrsInventoryDetailBloc>()
                    .add(const AsrsInventoryDetailRefreshed()),
              ),
            ],
          ),
          body: Column(
            children: [
              _buildHeader(task),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '按物料/托盘/库位搜索',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => context
                          .read<AsrsInventoryDetailBloc>()
                          .add(AsrsInventoryDetailSearchChanged(
                              _searchController.text.trim())),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onSubmitted: (value) => context
                      .read<AsrsInventoryDetailBloc>()
                      .add(AsrsInventoryDetailSearchChanged(value.trim())),
                ),
              ),
              Expanded(
                child: _buildBody(state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(AsrsInventoryTask task) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Colors.blueGrey.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '任务号：${task.taskNo}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text('库房：${task.storeRoomNo} ${task.storeRoomName}'),
          if (task.createdDate != null && task.createdDate!.isNotEmpty)
            Text('创建时间：${task.createdDate}'),
        ],
      ),
    );
  }

  Widget _buildBody(AsrsInventoryDetailState state) {
    if (state.status == AsrsInventoryDetailStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.status == AsrsInventoryDetailStatus.failure) {
      return Center(child: Text(state.errorMessage ?? '加载失败'));
    }
    if (state.details.isEmpty) {
      return const Center(child: Text('暂无任务明细'));
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '任务明细 (${state.details.length})',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        ...state.details.map((e) => _DetailCard(detail: e)),
        if (state.trayItems.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              '托盘采集记录 (${state.trayItems.length})',
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ...state.trayItems.map((e) => _TrayRecordCard(item: e)),
      ],
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.detail});

  final AsrsInventoryTaskDetail detail;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  detail.materialCode,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text('计划：${detail.taskQty.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 4),
            Text(detail.materialName),
            const SizedBox(height: 4),
            Text('库位：${detail.storeSiteNo}    托盘：${detail.trayNo}'),
            if (detail.batchNo != null && detail.batchNo!.isNotEmpty)
              Text('批次：${detail.batchNo}'),
            if (detail.serialNo != null && detail.serialNo!.isNotEmpty)
              Text('序列：${detail.serialNo}'),
            Text('已采集：${detail.collectedQty.toStringAsFixed(2)}  库存：${detail.inventoryQty.toStringAsFixed(2)}'),
            if (detail.endAddress != null && detail.endAddress!.isNotEmpty)
              Text('拣选位置：${detail.endAddress}'),
          ],
        ),
      ),
    );
  }
}

class _TrayRecordCard extends StatelessWidget {
  const _TrayRecordCard({required this.item});

  final AsrsInventoryTrayItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('托盘：${item.trayNo}',
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text('物料：${item.materialCode} ${item.materialName}'),
            if (item.batchNo != null && item.batchNo!.isNotEmpty)
              Text('批次：${item.batchNo}'),
            if (item.serialNo != null && item.serialNo!.isNotEmpty)
              Text('序列：${item.serialNo}'),
            Text('数量：${item.quantity.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}
