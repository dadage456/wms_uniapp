import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/modules/asrs_inbound/command_center/bloc/asrs_inbound_command_bloc.dart';
import 'package:wms_app/modules/asrs_inbound/command_center/bloc/asrs_inbound_command_event.dart';
import 'package:wms_app/modules/asrs_inbound/command_center/bloc/asrs_inbound_command_state.dart';
import 'package:wms_app/modules/asrs_inbound/models/asrs_inbound_models.dart';

class AsrsInboundCommandPage extends StatefulWidget {
  const AsrsInboundCommandPage({super.key, required this.task});

  final AsrsInboundTask task;

  @override
  State<AsrsInboundCommandPage> createState() => _AsrsInboundCommandPageState();
}

class _AsrsInboundCommandPageState extends State<AsrsInboundCommandPage> {
  late final TextEditingController _trayController;
  late final TextEditingController _startController;
  late final TextEditingController _endController;

  @override
  void initState() {
    super.initState();
    _trayController = TextEditingController();
    _startController = TextEditingController();
    _endController = TextEditingController();
  }

  @override
  void dispose() {
    _trayController.dispose();
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AsrsInboundCommandBloc, AsrsInboundCommandState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        } else if (state.successMessage != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.successMessage!)));
        }
        _trayController.text = state.trayNo;
        _startController.text = state.startAddress;
        _endController.text = state.endAddress;
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text('立库入库指令 - ${widget.task.taskNo}'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => context
                    .read<AsrsInboundCommandBloc>()
                    .add(const AsrsInboundCommandRefreshed()),
              ),
            ],
          ),
          body: state.status == AsrsInboundCommandStatus.loading &&
                  state.history.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildForm(context, state),
                      const SizedBox(height: 24),
                      Text(
                        '指令历史',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Expanded(child: _HistoryList(history: state.history)),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildForm(BuildContext context, AsrsInboundCommandState state) {
    return Column(
      children: [
        TextField(
          controller: _trayController,
          decoration: InputDecoration(
            labelText: '托盘号',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onChanged: (value) => context
              .read<AsrsInboundCommandBloc>()
              .add(AsrsInboundCommandTrayChanged(value.trim())),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _startController,
          decoration: InputDecoration(
            labelText: '起始地址',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onChanged: (value) => context
              .read<AsrsInboundCommandBloc>()
              .add(AsrsInboundCommandStartChanged(value.trim())),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _endController,
          decoration: InputDecoration(
            labelText: '目标地址',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onChanged: (value) => context
              .read<AsrsInboundCommandBloc>()
              .add(AsrsInboundCommandEndChanged(value.trim())),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.send),
            label: const Text('下发指令'),
            onPressed: state.status == AsrsInboundCommandStatus.submitting
                ? null
                : () => context
                    .read<AsrsInboundCommandBloc>()
                    .add(const AsrsInboundCommandSubmitted()),
          ),
        ),
      ],
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.history});

  final List<AsrsInboundWcsCommand> history;

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Center(child: Text('暂无指令记录'));
    }

    return ListView.separated(
      itemBuilder: (context, index) {
        final command = history[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.history),
            title: Text('指令号：${command.commandNo}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('托盘：${command.trayNo}'),
                Text('起始：${command.startAddress}  →  目标：${command.endAddress}'),
                Text('状态：${command.status}'),
                Text('时间：${command.createdTime}'),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemCount: history.length,
    );
  }
}
