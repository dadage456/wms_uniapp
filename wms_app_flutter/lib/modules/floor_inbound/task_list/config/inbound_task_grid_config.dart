import 'package:flutter/material.dart';
import 'package:wms_app/common_widgets/common_grid/common_data_grid.dart';

import '../models/inbound_task.dart';

typedef InboundTaskOperation = void Function(
    InboundTask task, InboundTaskOperationType type);

enum InboundTaskOperationType { collect, detail }

class InboundTaskGridConfig {
  static List<GridColumnConfig<InboundTask>> buildColumns(
    InboundTaskOperation onOperate, {
    bool includeCollect = true,
  }) {
    return [
      GridColumnConfig<InboundTask>(
        name: 'operation',
        headerText: '操作',
        width: includeCollect ? 180 : 120,
        valueGetter: (_) => '',
        cellBuilder: (task, __, ___) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (includeCollect)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _ActionButton(
                    label: '采集',
                    onPressed: () =>
                        onOperate(task, InboundTaskOperationType.collect),
                  ),
                ),
              _ActionButton(
                label: '明细',
                onPressed: () =>
                    onOperate(task, InboundTaskOperationType.detail),
              ),
            ],
          );
        },
      ),
      GridColumnConfig<InboundTask>(
        name: 'orderNo',
        headerText: '入库单号',
        width: 160,
        valueGetter: (task) => task.orderNo,
      ),
      GridColumnConfig<InboundTask>(
        name: 'sourceOrder',
        headerText: '来源单号',
        width: 160,
        valueGetter: (task) => task.sourceOrderNo,
      ),
      GridColumnConfig<InboundTask>(
        name: 'taskNo',
        headerText: '任务号',
        width: 160,
        valueGetter: (task) => task.inTaskNo,
      ),
      GridColumnConfig<InboundTask>(
        name: 'storeRoom',
        headerText: '库房',
        width: 120,
        valueGetter: (task) => task.storeRoomNo,
      ),
      GridColumnConfig<InboundTask>(
        name: 'workStation',
        headerText: '工位',
        width: 120,
        valueGetter: (task) => task.workStation,
      ),
      GridColumnConfig<InboundTask>(
        name: 'supplier',
        headerText: '供应商',
        width: 200,
        valueGetter: (task) => task.supplierName,
      ),
      GridColumnConfig<InboundTask>(
        name: 'voucher',
        headerText: '凭证号',
        width: 160,
        valueGetter: (task) => task.voucherNo,
      ),
      GridColumnConfig<InboundTask>(
        name: 'planQty',
        headerText: '计划数量',
        width: 120,
        valueGetter: (task) => task.planQty,
        formatter: (value, _) =>
            (value is num) ? value.toStringAsFixed(2) : value.toString(),
        textAlign: TextAlign.right,
      ),
      GridColumnConfig<InboundTask>(
        name: 'finishQty',
        headerText: '完成数量',
        width: 120,
        valueGetter: (task) => task.finishQty,
        formatter: (value, _) =>
            (value is num) ? value.toStringAsFixed(2) : value.toString(),
        textAlign: TextAlign.right,
      ),
      GridColumnConfig<InboundTask>(
        name: 'status',
        headerText: '状态',
        width: 120,
        valueGetter: (task) => task.status,
      ),
    ];
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: OutlinedButton(
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}
