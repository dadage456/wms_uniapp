import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:wms_app/modules/asrs_inbound/models/asrs_inbound_models.dart';
import 'package:wms_app/modules/asrs_inbound/task_list/bloc/asrs_inbound_list_bloc.dart';
import 'package:wms_app/modules/asrs_inbound/task_list/bloc/asrs_inbound_list_event.dart';
import 'package:wms_app/modules/asrs_inbound/task_list/bloc/asrs_inbound_list_state.dart';

class AsrsInboundTaskListPage extends StatefulWidget {
  const AsrsInboundTaskListPage({super.key});

  @override
  State<AsrsInboundTaskListPage> createState() =>
      _AsrsInboundTaskListPageState();
}

class _AsrsInboundTaskListPageState extends State<AsrsInboundTaskListPage> {
  late final TextEditingController _keywordController;
  late final AsrsInboundListBloc _bloc;

  @override
  void initState() {
    super.initState();
    _keywordController = TextEditingController();
    _bloc = BlocProvider.of<AsrsInboundListBloc>(context);
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AsrsInboundListBloc, AsrsInboundListState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage ||
          previous.successMessage != current.successMessage,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        } else if (state.successMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.successMessage!)));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('立库入库任务'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                _bloc.add(const AsrsInboundListRefreshed());
              },
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
                  hintText: '请输入任务号/单号搜索',
                  suffixIcon: _buildSuffixIcon(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onSubmitted: (value) =>
                    _bloc.add(AsrsInboundListKeywordChanged(value.trim())),
              ),
            ),
            Expanded(
              child: BlocBuilder<AsrsInboundListBloc, AsrsInboundListState>(
                builder: (context, state) {
                  if (state.status == AsrsInboundListStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.status == AsrsInboundListStatus.failure) {
                    return Center(child: Text(state.errorMessage ?? '加载失败'));
                  }
                  if (state.tasks.isEmpty) {
                    return const Center(child: Text('暂无待处理任务'));
                  }

                  return RefreshIndicator(
                    onRefresh: () async =>
                        _bloc.add(const AsrsInboundListRefreshed()),
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
    return BlocBuilder<AsrsInboundListBloc, AsrsInboundListState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        if (state.status == AsrsInboundListStatus.loading) {
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
          onPressed: () => _bloc.add(
            AsrsInboundListKeywordChanged(_keywordController.text.trim()),
          ),
        );
      },
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task});

  final AsrsInboundTask task;

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
                Expanded(
                  child: Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Chip(label: Text(task.status.isEmpty ? '待处理' : task.status)),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                _infoChip('工位', task.workstation),
                _infoChip('库房', task.storeRoomName),
                _infoChip('项目', task.projectNum),
                _infoChip('托盘', task.trayQty.toStringAsFixed(0)),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ActionButton(
                  icon: Icons.list_alt,
                  label: '任务明细',
                  onTap: () =>
                      Modular.to.pushNamed('./detail', arguments: task),
                ),
                _ActionButton(
                  icon: Icons.qr_code_scanner,
                  label: '采集上架',
                  onTap: () =>
                      Modular.to.pushNamed('./collect', arguments: task),
                ),
                _ActionButton(
                  icon: Icons.play_circle,
                  label: 'WCS指令',
                  onTap: () =>
                      Modular.to.pushNamed('./commands', arguments: task),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(String label, String value) {
    final display = value.isEmpty ? '-' : value;
    return Chip(
      backgroundColor: Colors.blueGrey.shade50,
      label: Text('$label：$display'),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
