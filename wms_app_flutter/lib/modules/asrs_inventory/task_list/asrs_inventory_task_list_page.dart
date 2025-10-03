import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:wms_app/modules/asrs_inventory/models/asrs_inventory_models.dart';
import 'package:wms_app/modules/asrs_inventory/task_list/bloc/asrs_inventory_list_bloc.dart';
import 'package:wms_app/modules/asrs_inventory/task_list/bloc/asrs_inventory_list_event.dart';
import 'package:wms_app/modules/asrs_inventory/task_list/bloc/asrs_inventory_list_state.dart';

class AsrsInventoryTaskListPage extends StatefulWidget {
  const AsrsInventoryTaskListPage({super.key});

  @override
  State<AsrsInventoryTaskListPage> createState() =>
      _AsrsInventoryTaskListPageState();
}

class _AsrsInventoryTaskListPageState
    extends State<AsrsInventoryTaskListPage> {
  late final TextEditingController _keywordController;

  @override
  void initState() {
    super.initState();
    _keywordController = TextEditingController();
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AsrsInventoryListBloc, AsrsInventoryListState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage ||
          previous.successMessage != current.successMessage,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        } else if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.successMessage!)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('立库盘点任务'),
          actions: [
            BlocBuilder<AsrsInventoryListBloc, AsrsInventoryListState>(
              buildWhen: (previous, current) =>
                  previous.onlyProcessing != current.onlyProcessing,
              builder: (context, state) {
                return Row(
                  children: [
                    const Text('仅显示进行中'),
                    Switch(
                      value: state.onlyProcessing,
                      onChanged: (value) => context
                          .read<AsrsInventoryListBloc>()
                          .add(AsrsInventoryListToggleProcessing(value)),
                    ),
                  ],
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => context
                  .read<AsrsInventoryListBloc>()
                  .add(const AsrsInventoryListRefreshed()),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _keywordController,
                decoration: InputDecoration(
                  hintText: '请输入盘点单号/库房/任务号搜索',
                  suffixIcon: _buildSuffixIcon(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onSubmitted: (value) => context
                    .read<AsrsInventoryListBloc>()
                    .add(AsrsInventoryListKeywordChanged(value.trim())),
              ),
            ),
            Expanded(
              child: BlocBuilder<AsrsInventoryListBloc, AsrsInventoryListState>(
                builder: (context, state) {
                  if (state.status == AsrsInventoryListStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.status == AsrsInventoryListStatus.failure) {
                    return Center(
                      child: Text(state.errorMessage ?? '加载失败'),
                    );
                  }
                  if (state.tasks.isEmpty) {
                    return const Center(child: Text('暂无待处理任务'));
                  }

                  return RefreshIndicator(
                    onRefresh: () async => context
                        .read<AsrsInventoryListBloc>()
                        .add(const AsrsInventoryListRefreshed()),
                    child: ListView.separated(
                      padding: const EdgeInsets.only(bottom: 24),
                      itemBuilder: (context, index) {
                        final task = state.tasks[index];
                        return _TaskCard(task: task);
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemCount: state.tasks.length,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuffixIcon(BuildContext context) {
    return BlocBuilder<AsrsInventoryListBloc, AsrsInventoryListState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        if (state.status == AsrsInventoryListStatus.loading) {
          return const Padding(
            padding: EdgeInsets.all(12),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        return IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => context.read<AsrsInventoryListBloc>().add(
                AsrsInventoryListKeywordChanged(
                  _keywordController.text.trim(),
                ),
              ),
        );
      },
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task});

  final AsrsInventoryTask task;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  task.taskComment,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Chip(
                  label: Text(task.isFinished ? '已完成' : '进行中'),
                  backgroundColor:
                      task.isFinished ? Colors.green.shade100 : Colors.blue.shade100,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('任务号：${task.taskNo}'),
            Text('库房：${task.storeRoomNo} ${task.storeRoomName}'),
            if (task.createdDate != null && task.createdDate!.isNotEmpty)
              Text('创建时间：${task.createdDate}'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Modular.to.pushNamed(
                    '/warehouse-count/detail',
                    arguments: task,
                  ),
                  child: const Text('查看明细'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => Modular.to.pushNamed(
                    '/warehouse-count/commands',
                    arguments: task,
                  ),
                  child: const Text('指令中心'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => Modular.to.pushNamed(
                    '/warehouse-count/collect',
                    arguments: task,
                  ),
                  child: const Text('开始采集'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
