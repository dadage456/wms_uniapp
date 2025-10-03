import 'package:flutter/material.dart';
import 'package:wms_app/common_widgets/common_grid/common_data_grid.dart';
import 'package:wms_app/modules/floor_inventory/task_list/models/inventory_task.dart';

typedef InventoryTaskOperation = void Function(
  InventoryTask task,
  InventoryTaskOperationType type,
);

enum InventoryTaskOperationType { collect, detail, cancel, receive }

class InventoryTaskGridConfig {
  static List<GridColumnConfig<InventoryTask>> buildColumns(
    InventoryTaskOperation onOperate,
  ) {
    return [
      GridColumnConfig<InventoryTask>(
        name: 'operation',
        headerText: '操作',
        width: 220,
        valueGetter: (_) => '',
        cellBuilder: (task, __, ___) => Wrap(
          spacing: 8,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: [
            _ActionButton(
              label: '采集',
              onPressed: () => onOperate(task, InventoryTaskOperationType.collect),
            ),
            _ActionButton(
              label: '明细',
              onPressed: () => onOperate(task, InventoryTaskOperationType.detail),
            ),
            _ActionButton(
              label: '撤销',
              onPressed: () => onOperate(task, InventoryTaskOperationType.cancel),
            ),
          ],
        ),
      ),
      GridColumnConfig<InventoryTask>(
        name: 'taskComment',
        headerText: '盘库单号',
        width: 160,
        valueGetter: (task) => task.taskComment,
      ),
      GridColumnConfig<InventoryTask>(
        name: 'taskNo',
        headerText: '任务号',
        width: 160,
        valueGetter: (task) => task.taskNo,
      ),
      GridColumnConfig<InventoryTask>(
        name: 'checkMethod',
        headerText: '盘库类型',
        width: 120,
        valueGetter: (task) => task.checkMethod,
      ),
      GridColumnConfig<InventoryTask>(
        name: 'storeRoomNo',
        headerText: '库房号',
        width: 100,
        valueGetter: (task) => task.storeRoomNo,
      ),
      GridColumnConfig<InventoryTask>(
        name: 'storeRoomName',
        headerText: '库房名称',
        width: 220,
        valueGetter: (task) => task.storeRoomName,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      GridColumnConfig<InventoryTask>(
        name: 'createdDate',
        headerText: '创建时间',
        width: 160,
        valueGetter: (task) => task.createdDate,
      ),
    ];
  }

  static List<GridColumnConfig<InventoryTask>> buildReceiveColumns(
    InventoryTaskOperation onOperate,
  ) {
    return [
      GridColumnConfig<InventoryTask>(
        name: 'operation',
        headerText: '操作',
        width: 200,
        valueGetter: (_) => '',
        cellBuilder: (task, __, ___) => Wrap(
          spacing: 8,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: [
            _ActionButton(
              label: '接收',
              onPressed: () => onOperate(task, InventoryTaskOperationType.receive),
            ),
            _ActionButton(
              label: '明细',
              onPressed: () => onOperate(task, InventoryTaskOperationType.detail),
            ),
          ],
        ),
      ),
      ...buildColumns(onOperate)
          .where((column) => column.name != 'operation')
          .toList(),
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
