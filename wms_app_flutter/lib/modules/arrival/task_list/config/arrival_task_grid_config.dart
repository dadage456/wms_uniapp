import 'package:flutter/material.dart';
import 'package:wms_app/common_widgets/common_grid/common_data_grid.dart';
import 'package:wms_app/modules/arrival/task_list/models/arrival_task.dart';

typedef ArrivalTaskOperation = void Function(
  ArrivalTask task,
  ArrivalTaskOperationType type,
);

enum ArrivalTaskOperationType { collect, detail, cancel, receive }

class ArrivalTaskGridConfig {
  static List<GridColumnConfig<ArrivalTask>> buildReceivedColumns(
    ArrivalTaskOperation onOperate,
  ) {
    return [
      GridColumnConfig<ArrivalTask>(
        name: 'operation',
        headerText: '操作',
        width: 240,
        valueGetter: (_) => '',
        cellBuilder: (task, __, ___) => Wrap(
          spacing: 8,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: [
            _ActionButton(
              label: '采集',
              onPressed: () => onOperate(task, ArrivalTaskOperationType.collect),
            ),
            _ActionButton(
              label: '明细',
              onPressed: () => onOperate(task, ArrivalTaskOperationType.detail),
            ),
            _ActionButton(
              label: '撤销',
              onPressed: () => onOperate(task, ArrivalTaskOperationType.cancel),
            ),
          ],
        ),
      ),
      ..._buildCommonColumns(),
    ];
  }

  static List<GridColumnConfig<ArrivalTask>> buildReceiveColumns(
    ArrivalTaskOperation onOperate,
  ) {
    return [
      GridColumnConfig<ArrivalTask>(
        name: 'operation',
        headerText: '操作',
        width: 180,
        valueGetter: (_) => '',
        cellBuilder: (task, __, ___) => Wrap(
          spacing: 8,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: [
            _ActionButton(
              label: '接收',
              onPressed: () => onOperate(task, ArrivalTaskOperationType.receive),
            ),
            _ActionButton(
              label: '明细',
              onPressed: () => onOperate(task, ArrivalTaskOperationType.detail),
            ),
          ],
        ),
      ),
      ..._buildCommonColumns(),
    ];
  }

  static List<GridColumnConfig<ArrivalTask>> _buildCommonColumns() {
    return [
      GridColumnConfig<ArrivalTask>(
        name: 'orderNo',
        headerText: '装箱单号',
        width: 160,
        valueGetter: (task) => task.orderNo,
      ),
      GridColumnConfig<ArrivalTask>(
        name: 'poNumber',
        headerText: '采购单号',
        width: 140,
        valueGetter: (task) => task.poNumber,
      ),
      GridColumnConfig<ArrivalTask>(
        name: 'createdate',
        headerText: '到货日期',
        width: 140,
        valueGetter: (task) => task.createDate,
      ),
      GridColumnConfig<ArrivalTask>(
        name: 'arrivalsBillNo',
        headerText: '到货单号',
        width: 160,
        valueGetter: (task) => task.arrivalsBillNo,
      ),
      GridColumnConfig<ArrivalTask>(
        name: 'factory',
        headerText: '工厂',
        width: 100,
        valueGetter: (task) => task.factory,
      ),
      GridColumnConfig<ArrivalTask>(
        name: 'supplier',
        headerText: '供应商',
        width: 220,
        valueGetter: (task) => task.supplierName,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      GridColumnConfig<ArrivalTask>(
        name: 'planQty',
        headerText: '任务数量',
        width: 110,
        valueGetter: (task) => task.planQty,
        formatter: (value, _) =>
            value is num ? value.toStringAsFixed(2) : value.toString(),
        textAlign: TextAlign.right,
      ),
      GridColumnConfig<ArrivalTask>(
        name: 'goodQty',
        headerText: '采集数量',
        width: 110,
        valueGetter: (task) => task.collectedQty,
        formatter: (value, _) =>
            value is num ? value.toStringAsFixed(2) : value.toString(),
        textAlign: TextAlign.right,
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
      child: OutlinedButton(onPressed: onPressed, child: Text(label)),
    );
  }
}
