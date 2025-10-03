import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/modules/asrs_outbound/command_center/bloc/asrs_command_bloc.dart';
import 'package:wms_app/modules/asrs_outbound/command_center/bloc/asrs_command_event.dart';
import 'package:wms_app/modules/asrs_outbound/command_center/bloc/asrs_command_state.dart';
import 'package:wms_app/modules/asrs_outbound/models/asrs_outbound_models.dart';

class AsrsCommandPage extends StatefulWidget {
  const AsrsCommandPage({super.key, required this.task});

  final AsrsOutboundTask task;

  @override
  State<AsrsCommandPage> createState() => _AsrsCommandPageState();
}

class _AsrsCommandPageState extends State<AsrsCommandPage> {
  late final AsrsCommandBloc _bloc;
  final _trayController = TextEditingController();
  final _startController = TextEditingController();
  final _endController = TextEditingController();
  final _flagController = TextEditingController(text: '0');

  @override
  void initState() {
    super.initState();
    _bloc = context.read<AsrsCommandBloc>();
    _bloc.add(AsrsCommandInitialized(widget.task));
  }

  @override
  void dispose() {
    _trayController.dispose();
    _startController.dispose();
    _endController.dispose();
    _flagController.dispose();
    super.dispose();
  }

  void _syncControllers(AsrsCommandState state) {
    if (_trayController.text != state.trayNo) {
      _trayController.text = state.trayNo;
    }
    if (_startController.text != state.startAddress) {
      _startController.text = state.startAddress;
    }
    if (_endController.text != state.endAddress) {
      _endController.text = state.endAddress;
    }
    if (_flagController.text != state.singleFlag) {
      _flagController.text = state.singleFlag;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AsrsCommandBloc, AsrsCommandState>(
      listener: (context, state) {
        _syncControllers(state);
        if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.successMessage!)),
          );
          _bloc.add(const AsrsCommandMessageCleared());
        }
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
          _bloc.add(const AsrsCommandMessageCleared());
        }
      },
      builder: (context, state) {
        final loading = state.status == AsrsCommandStatus.loading;
        return Scaffold(
          appBar: AppBar(
            title: Text('WCS 指令 - ${widget.task.taskNo}'),
          ),
          body: loading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView(
                    children: [
                      _buildCommandTypeSelector(state),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: '托盘号',
                        controller: _trayController,
                        onChanged: (value) =>
                            _bloc.add(AsrsCommandTrayChanged(value.trim())),
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        label: '起始地址',
                        controller: _startController,
                        onChanged: (value) =>
                            _bloc.add(AsrsCommandStartChanged(value.trim())),
                      ),
                      _locationChips(
                        '可选出库口',
                        state.outLocations,
                        (addr) => _bloc.add(
                          AsrsCommandApplyLocation(addr, isStart: true),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        label: '目标地址',
                        controller: _endController,
                        onChanged: (value) =>
                            _bloc.add(AsrsCommandEndChanged(value.trim())),
                      ),
                      _locationChips(
                        '推荐入库位',
                        state.inLocations,
                        (addr) => _bloc.add(
                          AsrsCommandApplyLocation(addr, isStart: false),
                        ),
                      ),
                      if (state.palletSites.isNotEmpty)
                        _locationChips(
                          '托盘待命口',
                          state.palletSites,
                          (addr) => _bloc.add(
                            AsrsCommandApplyLocation(addr, isStart: true),
                          ),
                        ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        label: '单件标识 (0/1)',
                        controller: _flagController,
                        onChanged: (value) =>
                            _bloc.add(AsrsCommandSingleFlagChanged(value.trim())),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed: state.status == AsrsCommandStatus.submitting
                            ? null
                            : () =>
                                _bloc.add(const AsrsCommandSubmitRequested()),
                        icon: const Icon(Icons.send_outlined),
                        label: const Text('下发指令'),
                      ),
                      if (state.status == AsrsCommandStatus.submitting)
                        const Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: LinearProgressIndicator(),
                        ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildCommandTypeSelector(AsrsCommandState state) {
    return Row(
      children: [
        const Text('指令类型'),
        const SizedBox(width: 16),
        DropdownButton<AsrsCommandType>(
          value: state.type,
          items: const [
            DropdownMenuItem(
              value: AsrsCommandType.normal,
              child: Text('常规出库'),
            ),
            DropdownMenuItem(
              value: AsrsCommandType.inventory,
              child: Text('盘点出库'),
            ),
            DropdownMenuItem(
              value: AsrsCommandType.empty,
              child: Text('空托盘出库'),
            ),
          ],
          onChanged: (value) {
            if (value != null) {
              _bloc.add(AsrsCommandTypeChanged(value));
            }
          },
        ),
      ],
    );
  }

  Widget _locationChips(
    String title,
    List<AsrsLocation> locations,
    ValueChanged<String> onTap,
  ) {
    if (locations.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: locations
                .map(
                  (e) => ActionChip(
                    label: Text(e.address),
                    onPressed: () => onTap(e.address),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }
}
