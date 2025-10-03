import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/modules/asrs_inventory/command_center/bloc/asrs_inventory_command_bloc.dart';
import 'package:wms_app/modules/asrs_inventory/command_center/bloc/asrs_inventory_command_event.dart';
import 'package:wms_app/modules/asrs_inventory/command_center/bloc/asrs_inventory_command_state.dart';
import 'package:wms_app/modules/asrs_inventory/models/asrs_inventory_models.dart';

class AsrsInventoryCommandPage extends StatelessWidget {
  const AsrsInventoryCommandPage({super.key, required this.task});

  final AsrsInventoryTask task;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AsrsInventoryCommandBloc, AsrsInventoryCommandState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
          context
              .read<AsrsInventoryCommandBloc>()
              .add(const AsrsInventoryCommandMessagesCleared());
        } else if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.successMessage!)),
          );
          context
              .read<AsrsInventoryCommandBloc>()
              .add(const AsrsInventoryCommandMessagesCleared());
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text('WCS指令 - ${task.taskComment}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => context
                    .read<AsrsInventoryCommandBloc>()
                    .add(const AsrsInventoryCommandRefreshed()),
              ),
            ],
          ),
          body: state.status == AsrsInventoryCommandStatus.loading &&
                  state.history.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CommandForm(state: state),
                      const SizedBox(height: 16),
                      Expanded(child: _CommandHistory(history: state.history)),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

class _CommandForm extends StatelessWidget {
  const _CommandForm({required this.state});

  final AsrsInventoryCommandState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AsrsInventoryCommandBloc>();
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '指令信息',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<AsrsInventoryCommandType>(
                    value: state.commandType,
                    decoration: const InputDecoration(
                      labelText: '指令类型',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: AsrsInventoryCommandType.down,
                        child: Text('下架指令'),
                      ),
                      DropdownMenuItem(
                        value: AsrsInventoryCommandType.reset,
                        child: Text('重置指令'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        bloc.add(AsrsInventoryCommandTypeChanged(value));
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                if (state.commandType == AsrsInventoryCommandType.down)
                  Expanded(
                    child: SwitchListTile(
                      value: state.singleFlag,
                      title: const Text('单托盘模式'),
                      onChanged: (value) => bloc
                          .add(AsrsInventoryCommandSingleFlagChanged(value)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: state.trayNo,
                    decoration: const InputDecoration(
                      labelText: '托盘号',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) =>
                        bloc.add(AsrsInventoryCommandTrayChanged(value.trim())),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: state.startAddress,
                    decoration: const InputDecoration(
                      labelText: '起始地址',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) =>
                        bloc.add(AsrsInventoryCommandStartChanged(value.trim())),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: state.endAddress,
              decoration: const InputDecoration(
                labelText: '目标地址',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) =>
                  bloc.add(AsrsInventoryCommandEndChanged(value.trim())),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: state.status == AsrsInventoryCommandStatus.submitting
                    ? null
                    : () => bloc.add(const AsrsInventoryCommandSubmitted()),
                icon: state.status == AsrsInventoryCommandStatus.submitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: const Text('下发指令'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommandHistory extends StatelessWidget {
  const _CommandHistory({required this.history});

  final List<AsrsInventoryWcsCommand> history;

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Center(child: Text('暂无历史指令')); 
    }

    return ListView.separated(
      itemCount: history.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = history[index];
        return ListTile(
          leading: const Icon(Icons.history),
          title: Text('${item.trayNo}  ${item.commandType}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('起点：${item.startAddress}  终点：${item.endAddress}'),
              if (item.status != null && item.status!.isNotEmpty)
                Text('状态：${item.status}'),
              if (item.createdTime != null && item.createdTime!.isNotEmpty)
                Text('时间：${item.createdTime}'),
            ],
          ),
        );
      },
    );
  }
}
