import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:wms_app/common_widgets/common_grid/common_data_grid.dart';
import 'package:wms_app/common_widgets/common_grid/grid_bloc.dart';
import 'package:wms_app/common_widgets/common_grid/grid_event.dart';
import 'package:wms_app/common_widgets/common_grid/grid_state.dart';
import 'package:wms_app/common_widgets/loading_dialog_manager.dart';
import 'package:wms_app/modules/floor_exception/message_center/task_messages/bloc/task_message_bloc.dart';
import 'package:wms_app/modules/floor_exception/message_center/task_messages/bloc/task_message_event.dart';
import 'package:wms_app/modules/floor_exception/message_center/task_messages/bloc/task_message_state.dart';
import 'package:wms_app/modules/floor_exception/message_center/task_messages/config/task_message_grid_config.dart';
import 'package:wms_app/modules/floor_exception/message_center/task_messages/models/exception_task_message.dart';
import 'package:wms_app/modules/floor_exception/services/floor_exception_service.dart';
import 'package:wms_app/services/scanner_service.dart';
import 'package:wms_app/services/user_manager.dart';

class TaskMessagePage extends StatelessWidget {
  const TaskMessagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TaskMessageBloc>(
      create: (_) {
        final bloc = TaskMessageBloc(
          service: Modular.get<FloorExceptionService>(),
          userManager: Modular.get<UserManager>(),
        );
        bloc.gridBloc.add(LoadDataEvent<ExceptionTaskMessage>(1));
        return bloc;
      },
      child: const _TaskMessageView(),
    );
  }
}

class _TaskMessageView extends StatefulWidget {
  const _TaskMessageView();

  @override
  State<_TaskMessageView> createState() => _TaskMessageViewState();
}

class _TaskMessageViewState extends State<_TaskMessageView> {
  late final TaskMessageBloc _bloc;
  late final CommonDataGridBloc<ExceptionTaskMessage> _gridBloc;
  final TextEditingController _searchController = TextEditingController();
  StreamSubscription<String>? _scanSubscription;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<TaskMessageBloc>(context);
    _gridBloc = _bloc.gridBloc;

    _scanSubscription = ScannerService.instance.stream.listen((code) {
      if (!mounted) return;
      if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;
      final trimmed = code.trim();
      if (trimmed.isEmpty) return;
      _searchController.text = trimmed;
      _bloc.add(TaskMessageSearchSubmitted(trimmed));
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scanSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(child: _buildGrid()),
        BlocConsumer<TaskMessageBloc, TaskMessageState>(
          listener: (context, state) {
            if (state.successMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.successMessage!)));
              _bloc.add(const TaskMessageClearFeedback());
            }
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
              _bloc.add(const TaskMessageClearFeedback());
            }
          },
          builder: (context, state) {
            if (state.isProcessing) {
              return const LinearProgressIndicator(minHeight: 2);
            }
            return const SizedBox(height: 2);
          },
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '请扫描或输入消息标题/类型',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _bloc.add(const TaskMessageSearchSubmitted(''));
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onSubmitted: (value) =>
                  _bloc.add(TaskMessageSearchSubmitted(value.trim())),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => _bloc.add(
              TaskMessageSearchSubmitted(_searchController.text.trim()),
            ),
            child: const Text('查询'),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _bloc.add(const TaskMessageRefreshRequested()),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return BlocProvider.value(
      value: _gridBloc,
      child:
          BlocConsumer<
            CommonDataGridBloc<ExceptionTaskMessage>,
            CommonDataGridState<ExceptionTaskMessage>
          >(
            listener: (context, state) {
              if (state.status == GridStatus.loading) {
                LoadingDialogManager.instance.showLoadingDialog(context);
              } else {
                LoadingDialogManager.instance.hideLoadingDialog(context);
              }

              if (state.status == GridStatus.error &&
                  state.errorMessage != null) {
                LoadingDialogManager.instance.showErrorDialog(
                  context,
                  state.errorMessage!,
                );
              }
            },
            builder: (context, state) {
              return CommonDataGrid<ExceptionTaskMessage>(
                columns: TaskMessageGridConfig.buildColumns(_onOperate),
                datas: state.data,
                currentPage: state.currentPage,
                totalPages: state.totalPages,
                allowPager: true,
                onLoadData: (pageIndex) async {
                  _gridBloc.add(LoadDataEvent<ExceptionTaskMessage>(pageIndex));
                },
              );
            },
          ),
    );
  }

  void _onOperate(ExceptionTaskMessage message, TaskMessageOperationType type) {
    switch (type) {
      case TaskMessageOperationType.confirm:
        _bloc.add(TaskMessageConfirmRequested(message));
        break;
    }
  }
}
