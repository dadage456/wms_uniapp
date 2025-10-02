import 'package:flutter/material.dart';
import '../../../../common_widgets/common_grid/common_data_grid.dart';
import '../../task_list/models/outbound_task.dart';

typedef ReceiveTaskOperation = void Function(OutboundTask task);

class ReceiveTaskGridConfig {
  static List<GridColumnConfig<OutboundTask>> columns(
    ReceiveTaskOperation? onDetail,
  ) {
    return [
      GridColumnConfig<OutboundTask>(
        name: 'actions',
        headerText: '操作',
        width: 140,
        valueGetter: (task) => '',
        cellBuilder: (task, _, __) {
          return SizedBox(
            height: 32,
            child: OutlinedButton(
              onPressed: () => onDetail?.call(task),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF1E88E5)),
                foregroundColor: const Color(0xFF1E88E5),
              ),
              child: const Text('明细'),
            ),
          );
        },
      ),
      GridColumnConfig<OutboundTask>(
        name: 'storeRoomNo',
        headerText: '库房号',
        width: 110,
        valueGetter: (task) => task.storeRoomNo,
      ),
      GridColumnConfig<OutboundTask>(
        name: 'orderNo',
        headerText: '出库单号',
        width: 180,
        valueGetter: (task) => task.orderNo,
      ),
      GridColumnConfig<OutboundTask>(
        name: 'poNumber',
        headerText: '来源单号',
        width: 180,
        valueGetter: (task) => task.poNumber,
      ),
      GridColumnConfig<OutboundTask>(
        name: 'workStation',
        headerText: '工位',
        width: 120,
        valueGetter: (task) => task.workStation,
      ),
      GridColumnConfig<OutboundTask>(
        name: 'outTaskNo',
        headerText: '任务号',
        width: 150,
        valueGetter: (task) => task.outTaskNo,
      ),
      GridColumnConfig<OutboundTask>(
        name: 'wipSupplementFlag',
        headerText: '紧急补单',
        width: 100,
        valueGetter: (task) => task.wipSupplementFlag,
      ),
      GridColumnConfig<OutboundTask>(
        name: 'scheduleGroupName',
        headerText: '班组',
        width: 160,
        valueGetter: (task) => task.scheduleGroupName ?? '',
      ),
      GridColumnConfig<OutboundTask>(
        name: 'taskComment',
        headerText: '凭证号',
        width: 160,
        valueGetter: (task) => task.taskComment,
      ),
    ];
  }
}
