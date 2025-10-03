import 'package:flutter/material.dart';
import 'package:wms_app/common_widgets/common_grid/common_data_grid.dart';
import 'package:wms_app/modules/floor_inbound/task_details/models/inbound_task_item.dart';

class InboundTaskDetailGridConfig {
  static List<GridColumnConfig<InboundTaskItem>> buildColumns() {
    return [
      GridColumnConfig(
        headerText: '任务明细ID',
        name: 'itemId',
        width: 140,
        valueGetter: (item) => item.itemId,
      ),
      GridColumnConfig(
        headerText: '物料编码',
        name: 'matCode',
        width: 160,
        valueGetter: (item) => item.matCode,
      ),
      GridColumnConfig(
        headerText: '物料名称',
        name: 'matName',
        width: 220,
        valueGetter: (item) => item.matName,
      ),
      GridColumnConfig(
        headerText: '库位',
        name: 'storeSiteNo',
        width: 140,
        valueGetter: (item) => item.storeSiteNo,
      ),
      GridColumnConfig(
        headerText: '批次',
        name: 'batchNo',
        width: 140,
        valueGetter: (item) => item.batchNo,
      ),
      GridColumnConfig(
        headerText: '计划数量',
        name: 'planQty',
        width: 120,
        valueGetter: (item) => item.planQty.toStringAsFixed(2),
        cellBuilder: (item, columnName, cellValue) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.centerRight,
            child: Text(
              cellValue?.toString() ?? '0',
              style: const TextStyle(fontSize: 14),
            ),
          );
        },
      ),
      GridColumnConfig(
        headerText: '已采集数量',
        name: 'collectedQty',
        width: 120,
        valueGetter: (item) => item.collectedQty.toStringAsFixed(2),
        cellBuilder: (item, columnName, cellValue) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.centerRight,
            child: Text(
              cellValue?.toString() ?? '0',
              style: const TextStyle(fontSize: 14),
            ),
          );
        },
      ),
      GridColumnConfig(
        headerText: '库存数量',
        name: 'inventoryQty',
        width: 120,
        valueGetter: (item) => item.inventoryQty.toStringAsFixed(2),
        cellBuilder: (item, columnName, cellValue) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.centerRight,
            child: Text(
              cellValue?.toString() ?? '0',
              style: const TextStyle(fontSize: 14),
            ),
          );
        },
      ),
    ];
  }
}
