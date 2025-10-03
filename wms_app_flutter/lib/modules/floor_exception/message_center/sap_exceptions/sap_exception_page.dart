import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:wms_app/common_widgets/common_grid/common_data_grid.dart';
import 'package:wms_app/common_widgets/common_grid/grid_bloc.dart';
import 'package:wms_app/common_widgets/common_grid/grid_event.dart';
import 'package:wms_app/common_widgets/common_grid/grid_state.dart';
import 'package:wms_app/common_widgets/loading_dialog_manager.dart';
import 'package:wms_app/modules/floor_exception/message_center/sap_exceptions/bloc/sap_exception_bloc.dart';
import 'package:wms_app/modules/floor_exception/message_center/sap_exceptions/bloc/sap_exception_event.dart';
import 'package:wms_app/modules/floor_exception/message_center/sap_exceptions/bloc/sap_exception_state.dart';
import 'package:wms_app/modules/floor_exception/message_center/sap_exceptions/config/sap_exception_grid_config.dart';
import 'package:wms_app/modules/floor_exception/message_center/sap_exceptions/models/sap_exception.dart';
import 'package:wms_app/modules/floor_exception/services/floor_exception_service.dart';
import 'package:wms_app/services/scanner_service.dart';
import 'package:wms_app/services/user_manager.dart';

class SapExceptionPage extends StatelessWidget {
  const SapExceptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SapExceptionBloc>(
      create: (_) {
        final bloc = SapExceptionBloc(
          service: Modular.get<FloorExceptionService>(),
          userManager: Modular.get<UserManager>(),
        );
        bloc.gridBloc.add(LoadDataEvent<SapExceptionRecord>(1));
        return bloc;
      },
      child: const _SapExceptionView(),
    );
  }
}

class _SapExceptionView extends StatefulWidget {
  const _SapExceptionView();

  @override
  State<_SapExceptionView> createState() => _SapExceptionViewState();
}

class _SapExceptionViewState extends State<_SapExceptionView> {
  late final SapExceptionBloc _bloc;
  late final CommonDataGridBloc<SapExceptionRecord> _gridBloc;
  final TextEditingController _searchController = TextEditingController();
  StreamSubscription<String>? _scanSubscription;

  @override
  void initState() {
    super.initState();
    _bloc = BlocProvider.of<SapExceptionBloc>(context);
    _gridBloc = _bloc.gridBloc;

    _scanSubscription = ScannerService.instance.stream.listen((code) {
      if (!mounted) return;
      if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;
      final trimmed = code.trim();
      if (trimmed.isEmpty) return;
      _searchController.text = trimmed;
      _bloc.add(SapExceptionSearchSubmitted(trimmed));
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
        BlocListener<SapExceptionBloc, SapExceptionState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
              _bloc.add(const SapExceptionClearError());
            }
          },
          child: const SizedBox(height: 2),
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
                hintText: '请扫描或输入单据号/源单号',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _bloc.add(const SapExceptionSearchSubmitted(''));
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onSubmitted: (value) =>
                  _bloc.add(SapExceptionSearchSubmitted(value.trim())),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => _bloc.add(
              SapExceptionSearchSubmitted(_searchController.text.trim()),
            ),
            child: const Text('查询'),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _bloc.add(const SapExceptionRefreshRequested()),
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
            CommonDataGridBloc<SapExceptionRecord>,
            CommonDataGridState<SapExceptionRecord>
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
              return CommonDataGrid<SapExceptionRecord>(
                columns: SapExceptionGridConfig.buildColumns(),
                datas: state.data,
                currentPage: state.currentPage,
                totalPages: state.totalPages,
                allowPager: true,
                onLoadData: (pageIndex) async {
                  _gridBloc.add(LoadDataEvent<SapExceptionRecord>(pageIndex));
                },
              );
            },
          ),
    );
  }
}
