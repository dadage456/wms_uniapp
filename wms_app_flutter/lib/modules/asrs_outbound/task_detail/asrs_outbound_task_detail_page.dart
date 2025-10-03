import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/modules/asrs_outbound/models/asrs_outbound_models.dart';
import 'package:wms_app/modules/asrs_outbound/task_detail/bloc/asrs_outbound_detail_bloc.dart';
import 'package:wms_app/modules/asrs_outbound/task_detail/bloc/asrs_outbound_detail_event.dart';
import 'package:wms_app/modules/asrs_outbound/task_detail/bloc/asrs_outbound_detail_state.dart';

class AsrsOutboundTaskDetailPage extends StatefulWidget {
  const AsrsOutboundTaskDetailPage({super.key, required this.task});

  final AsrsOutboundTask task;

  @override
  State<AsrsOutboundTaskDetailPage> createState() =>
      _AsrsOutboundTaskDetailPageState();
}

class _AsrsOutboundTaskDetailPageState
    extends State<AsrsOutboundTaskDetailPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    context
        .read<AsrsOutboundDetailBloc>()
        .add(AsrsOutboundDetailStarted(widget.task));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AsrsOutboundDetailBloc, AsrsOutboundDetailState>(
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
          title: Text('任务明细 - ${widget.task.taskNo}'),
          actions: [
            BlocBuilder<AsrsOutboundDetailBloc, AsrsOutboundDetailState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    context
                        .read<AsrsOutboundDetailBloc>()
                        .add(AsrsOutboundDetailStarted(widget.task,
                            keyword: _searchController.text.trim()));
                  },
                );
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '输入物料/库位进行过滤',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      context.read<AsrsOutboundDetailBloc>().add(
                            AsrsOutboundDetailSearchChanged(
                              _searchController.text.trim(),
                            ),
                          );
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onSubmitted: (value) {
                  context
                      .read<AsrsOutboundDetailBloc>()
                      .add(AsrsOutboundDetailSearchChanged(value.trim()));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  BlocBuilder<AsrsOutboundDetailBloc, AsrsOutboundDetailState>(
                    builder: (context, state) {
                      final selected = state.selectedIds.length;
                      final total = state.details.length;
                      return Text('已选择 $selected / $total');
                    },
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      context
                          .read<AsrsOutboundDetailBloc>()
                          .add(const AsrsOutboundDetailToggleAll(true));
                    },
                    icon: const Icon(Icons.select_all),
                    label: const Text('全选'),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      context
                          .read<AsrsOutboundDetailBloc>()
                          .add(const AsrsOutboundDetailToggleAll(false));
                    },
                    icon: const Icon(Icons.cancel_presentation_outlined),
                    label: const Text('取消全选'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<AsrsOutboundDetailBloc, AsrsOutboundDetailState>(
                builder: (context, state) {
                  if (state.status == AsrsOutboundDetailStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.status == AsrsOutboundDetailStatus.failure) {
                    return Center(
                      child: Text(state.errorMessage ?? '加载失败'),
                    );
                  }
                  if (state.details.isEmpty) {
                    return const Center(child: Text('暂无明细数据'));
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.only(bottom: 120),
                    itemBuilder: (context, index) {
                      final detail = state.details[index];
                      final selected = state.selectedIds.contains(detail.taskItemId);
                      return CheckboxListTile(
                        value: selected,
                        onChanged: (value) {
                          context.read<AsrsOutboundDetailBloc>().add(
                                AsrsOutboundDetailSelectionToggled(
                                  detail.taskItemId,
                                  value ?? false,
                                ),
                              );
                        },
                        title: Text('${detail.materialCode} ${detail.materialName}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('任务数量：${detail.taskQty}  提示数量：${detail.hintQty}'),
                            Text('库位：${detail.storeSiteNo}  托盘：${detail.palletNo}'),
                            Text('子库：${detail.subInventoryCode}  批次：${detail.batchNo}'),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemCount: state.details.length,
                  );
                },
              ),
            ),
            const _BottomActions(),
          ],
        ),
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AsrsOutboundDetailBloc, AsrsOutboundDetailState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, -2),
                blurRadius: 8,
                color: Colors.black.withValues(alpha: 0.08),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: state.isActionInProgress
                      ? null
                      : () {
                          context
                              .read<AsrsOutboundDetailBloc>()
                              .add(const AsrsOutboundDetailReceiveRequested(
                                cancel: false,
                              ));
                        },
                  icon: const Icon(Icons.how_to_reg_outlined),
                  label: const Text('接收任务'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: state.isActionInProgress
                      ? null
                      : () {
                          context
                              .read<AsrsOutboundDetailBloc>()
                              .add(const AsrsOutboundDetailReceiveRequested(
                                cancel: true,
                              ));
                        },
                  icon: const Icon(Icons.undo),
                  label: const Text('撤销接收'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
