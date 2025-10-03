import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/modules/asrs_inbound/models/asrs_inbound_models.dart';
import 'package:wms_app/modules/asrs_inbound/task_detail/bloc/asrs_inbound_detail_bloc.dart';
import 'package:wms_app/modules/asrs_inbound/task_detail/bloc/asrs_inbound_detail_event.dart';
import 'package:wms_app/modules/asrs_inbound/task_detail/bloc/asrs_inbound_detail_state.dart';

class AsrsInboundTaskDetailPage extends StatefulWidget {
  const AsrsInboundTaskDetailPage({super.key, required this.task});

  final AsrsInboundTask task;

  @override
  State<AsrsInboundTaskDetailPage> createState() => _AsrsInboundTaskDetailPageState();
}

class _AsrsInboundTaskDetailPageState extends State<AsrsInboundTaskDetailPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final TextEditingController _keywordController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _keywordController = TextEditingController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _keywordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AsrsInboundDetailBloc, AsrsInboundDetailState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text('任务 ${widget.task.taskNo}'),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: '任务明细'),
                Tab(text: '托盘信息'),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => context
                    .read<AsrsInboundDetailBloc>()
                    .add(const AsrsInboundDetailRefreshed()),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _keywordController,
                  decoration: InputDecoration(
                    labelText: '搜索物料/批次',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => context
                          .read<AsrsInboundDetailBloc>()
                          .add(AsrsInboundDetailSearchChanged(
                            _keywordController.text.trim(),
                          )),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onSubmitted: (value) => context
                      .read<AsrsInboundDetailBloc>()
                      .add(AsrsInboundDetailSearchChanged(value.trim())),
                ),
              ),
              Expanded(
                child: state.status == AsrsInboundDetailStatus.loading
                    ? const Center(child: CircularProgressIndicator())
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _DetailList(details: state.details),
                          _TrayList(infos: state.trayInfos),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DetailList extends StatelessWidget {
  const _DetailList({required this.details});

  final List<AsrsInboundTaskDetail> details;

  @override
  Widget build(BuildContext context) {
    if (details.isEmpty) {
      return const Center(child: Text('暂无明细')); 
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemBuilder: (context, index) {
        final detail = details[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${detail.materialCode}  ${detail.materialName}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    _chip('批次', detail.batchNo),
                    _chip('序列', detail.serialNo),
                    _chip('库位', detail.storeSiteNo),
                    _chip('托盘', detail.palletNo),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('计划数量：${detail.taskQty.toStringAsFixed(2)} ${detail.unit}'),
                    Text('已采集：${detail.collectedQty.toStringAsFixed(2)}'),
                  ],
                ),
                if (detail.isCompleted)
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Icon(Icons.check_circle, color: Colors.green),
                  ),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemCount: details.length,
    );
  }

  Widget _chip(String label, String value) {
    final display = value.isEmpty ? '-' : value;
    return Chip(label: Text('$label：$display'));
  }
}

class _TrayList extends StatelessWidget {
  const _TrayList({required this.infos});

  final List<AsrsInboundTrayInfo> infos;

  @override
  Widget build(BuildContext context) {
    if (infos.isEmpty) {
      return const Center(child: Text('暂无托盘信息'));
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemBuilder: (context, index) {
        final info = infos[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.inventory),
            title: Text('托盘：${info.trayNo}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('库位：${info.storeSiteNo}'),
                Text('数量：${info.quantity.toStringAsFixed(2)}'),
                Text('重量：${info.weight.toStringAsFixed(2)}    容量：${info.capacity.toStringAsFixed(2)}'),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemCount: infos.length,
    );
  }
}
