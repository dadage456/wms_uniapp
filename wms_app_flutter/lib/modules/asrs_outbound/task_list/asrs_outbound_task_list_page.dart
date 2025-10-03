import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:wms_app/modules/asrs_outbound/models/asrs_outbound_models.dart';
import 'package:wms_app/modules/asrs_outbound/task_list/bloc/asrs_outbound_list_bloc.dart';
import 'package:wms_app/modules/asrs_outbound/task_list/bloc/asrs_outbound_list_event.dart';
import 'package:wms_app/modules/asrs_outbound/task_list/bloc/asrs_outbound_list_state.dart';

class AsrsOutboundTaskListPage extends StatefulWidget {
  const AsrsOutboundTaskListPage({super.key});

  @override
  State<AsrsOutboundTaskListPage> createState() => _AsrsOutboundTaskListPageState();
}

class _AsrsOutboundTaskListPageState extends State<AsrsOutboundTaskListPage> {
  late final TextEditingController _keywordController;

  @override
  void initState() {
    super.initState();
    _keywordController = TextEditingController();
    context
        .read<AsrsOutboundListBloc>()
        .add(const AsrsOutboundListInitialized());
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AsrsOutboundListBloc, AsrsOutboundListState>(
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
          title: const Text('立库出库任务'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context
                    .read<AsrsOutboundListBloc>()
                    .add(const AsrsOutboundListRefreshed());
              },
            ),
          ],
        ),
        body: Column(
          children: [
            BlocBuilder<AsrsOutboundListBloc, AsrsOutboundListState>(
              buildWhen: (previous, current) =>
                  previous.status != current.status ||
                  previous.keyword != current.keyword,
              builder: (context, state) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: TextField(
                    controller: _keywordController,
                    decoration: InputDecoration(
                      hintText: '请输入任务号/单号搜索',
                      suffixIcon: _buildSuffixIcon(state),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onSubmitted: (value) {
                      context
                          .read<AsrsOutboundListBloc>()
                          .add(AsrsOutboundListKeywordChanged(value.trim()));
                    },
                  ),
                );
              },
            ),
            Expanded(
              child: BlocBuilder<AsrsOutboundListBloc, AsrsOutboundListState>(
                builder: (context, state) {
                  if (state.status == AsrsOutboundListStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.status == AsrsOutboundListStatus.failure) {
                    return Center(
                      child: Text(state.errorMessage ?? '加载失败'),
                    );
                  }
                  if (state.tasks.isEmpty) {
                    return const Center(child: Text('暂无待处理任务'));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemBuilder: (context, index) {
                      final task = state.tasks[index];
                      return _TaskCard(
                        task: task,
                        onViewDetail: () => Modular.to.pushNamed(
                          './detail',
                          arguments: task,
                        ),
                        onCollect: () => Modular.to.pushNamed(
                          './collect',
                          arguments: task,
                        ),
                        onCommand: () => Modular.to.pushNamed(
                          './commands',
                          arguments: task,
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemCount: state.tasks.length,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildSuffixIcon(AsrsOutboundListState state) {
    if (state.status == AsrsOutboundListStatus.loading) {
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
      onPressed: () {
        context.read<AsrsOutboundListBloc>().add(
              AsrsOutboundListKeywordChanged(
                _keywordController.text.trim(),
              ),
            );
      },
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.onViewDetail,
    required this.onCollect,
    required this.onCommand,
  });

  final AsrsOutboundTask task;
  final VoidCallback onViewDetail;
  final VoidCallback onCollect;
  final VoidCallback onCommand;

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
                  task.taskComment.isNotEmpty ? task.taskComment : task.taskNo,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    task.status.isEmpty ? '采集中' : task.status,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF465CFF),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                _InfoChip(label: '任务号', value: task.taskNo),
                _InfoChip(label: '出库单号', value: task.orderNo),
                _InfoChip(label: '来源单号', value: task.sourceOrderNo),
                _InfoChip(label: '库房', value: task.storeRoomNo),
                if (task.storeRoomName.isNotEmpty)
                  _InfoChip(label: '库房名称', value: task.storeRoomName),
                if (task.workstation.isNotEmpty)
                  _InfoChip(label: '工位', value: task.workstation),
                if (task.scheduleGroupName.isNotEmpty)
                  _InfoChip(label: '班组', value: task.scheduleGroupName),
                if (task.wipSupplementFlag.isNotEmpty)
                  _InfoChip(label: '补单', value: task.wipSupplementFlag),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onViewDetail,
                  icon: const Icon(Icons.list_alt_outlined),
                  label: const Text('任务明细'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onCollect,
                  icon: const Icon(Icons.qr_code_scanner_outlined),
                  label: const Text('执行采集'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onCommand,
                  icon: const Icon(Icons.settings_input_component_outlined),
                  label: const Text('WCS指令'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Chip(
      backgroundColor: const Color(0xFFF3F4F6),
      label: Text('$label：$value'),
    );
  }
}
