import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/common_widgets/common_grid/common_data_grid.dart';
import 'package:wms_app/common_widgets/common_grid/grid_bloc.dart';
import 'package:wms_app/common_widgets/common_grid/grid_event.dart';
import 'package:wms_app/common_widgets/common_grid/grid_state.dart';
import 'package:wms_app/common_widgets/custom_app_bar.dart';
import 'package:wms_app/common_widgets/loading_dialog_manager.dart';
import 'package:wms_app/modules/arrival/services/arrival_service.dart';
import 'package:wms_app/modules/arrival/task_details/config/arrival_task_detail_grid_config.dart';
import 'package:wms_app/modules/arrival/task_details/models/arrival_task_detail.dart';
import 'package:wms_app/modules/arrival/task_list/models/arrival_task.dart';

class ArrivalTaskDetailPage extends StatefulWidget {
  const ArrivalTaskDetailPage({
    super.key,
    required this.arrivalsBillId,
    required this.task,
    required this.service,
  });

  final String arrivalsBillId;
  final ArrivalTask task;
  final ArrivalService service;

  @override
  State<ArrivalTaskDetailPage> createState() => _ArrivalTaskDetailPageState();
}

class _ArrivalTaskDetailPageState extends State<ArrivalTaskDetailPage> {
  late final CommonDataGridBloc<ArrivalTaskDetail> _gridBloc;
  late ArrivalTaskDetailQuery _query;

  @override
  void initState() {
    super.initState();
    _query = ArrivalTaskDetailQuery(arrivalsBillId: widget.arrivalsBillId);
    _gridBloc = CommonDataGridBloc<ArrivalTaskDetail>(
      dataLoader: (pageIndex) async {
        final requestPage = pageIndex <= 0 ? 1 : pageIndex;
        _query = _query.copyWith(pageIndex: requestPage);
        final result = await widget.service.getArrivalDetails(_query);
        final totalPages = (result.total / _query.pageSize).ceil();
        return DataGridResponseData<ArrivalTaskDetail>(
          totalPages: totalPages <= 0 ? 1 : totalPages,
          data: result.rows,
        );
      },
    );
  }

  @override
  void dispose() {
    _gridBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '到货任务明细',
        onBackPressed: () => Navigator.of(context).pop(),
      ).appBar,
      body: Column(
        children: [
          _buildHeaderInfo(),
          Expanded(child: _buildGrid()),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '到货单号：${widget.task.arrivalsBillNo}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 16,
            runSpacing: 4,
            children: [
              Text('装箱单号：${widget.task.orderNo}'),
              Text('采购单号：${widget.task.poNumber}'),
              Text('供应商：${widget.task.supplierName}'),
              Text('到货日期：${widget.task.createDate}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return BlocProvider.value(
      value: _gridBloc,
      child: BlocConsumer<CommonDataGridBloc<ArrivalTaskDetail>,
          CommonDataGridState<ArrivalTaskDetail>>(
        listener: (context, state) {
          if (state.status == GridStatus.loading) {
            LoadingDialogManager.instance.showLoadingDialog(context);
          } else {
            LoadingDialogManager.instance.hideLoadingDialog(context);
          }
          if (state.status == GridStatus.error && state.errorMessage != null) {
            LoadingDialogManager.instance.showErrorDialog(
              context,
              state.errorMessage!,
            );
          }
        },
        builder: (context, state) {
          return CommonDataGrid<ArrivalTaskDetail>(
            columns: ArrivalTaskDetailGridConfig.buildColumns(),
            datas: state.data,
            currentPage: state.currentPage,
            totalPages: state.totalPages,
            allowPager: true,
            onLoadData: (pageIndex) async {
              _gridBloc.add(LoadDataEvent<ArrivalTaskDetail>(pageIndex));
            },
          );
        },
      ),
    );
  }
}
