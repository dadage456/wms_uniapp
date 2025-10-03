import 'package:flutter/material.dart';
import 'package:wms_app/common_widgets/common_grid/common_data_grid.dart';
import 'package:wms_app/modules/arrival/task_details/models/arrival_task_detail.dart';

class ArrivalTaskDetailGridConfig {
  static List<GridColumnConfig<ArrivalTaskDetail>> buildColumns() {
    return [
      GridColumnConfig<ArrivalTaskDetail>(
        name: 'matcode',
        headerText: '物料编码',
        width: 140,
        valueGetter: (item) => item.materialCode,
      ),
      GridColumnConfig<ArrivalTaskDetail>(
        name: 'matname',
        headerText: '物料名称',
        width: 180,
        valueGetter: (item) => item.materialName,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      GridColumnConfig<ArrivalTaskDetail>(
        name: 'qty',
        headerText: '任务数量',
        width: 110,
        valueGetter: (item) => item.planQty,
        formatter: (value, _) =>
            value is num ? value.toStringAsFixed(2) : value.toString(),
        textAlign: TextAlign.right,
      ),
      GridColumnConfig<ArrivalTaskDetail>(
        name: 'goodqty',
        headerText: '采集数量',
        width: 110,
        valueGetter: (item) => item.collectedQty,
        formatter: (value, _) =>
            value is num ? value.toStringAsFixed(2) : value.toString(),
        textAlign: TextAlign.right,
      ),
      GridColumnConfig<ArrivalTaskDetail>(
        name: 'batchno',
        headerText: '批次',
        width: 160,
        valueGetter: (item) => item.batchNo,
      ),
      GridColumnConfig<ArrivalTaskDetail>(
        name: 'sn',
        headerText: '序列',
        width: 200,
        valueGetter: (item) => item.serialNo,
      ),
      GridColumnConfig<ArrivalTaskDetail>(
        name: 'controlMode',
        headerText: '控制属性',
        width: 120,
        valueGetter: (item) => item.controlMode,
      ),
      GridColumnConfig<ArrivalTaskDetail>(
        name: 'storeroom',
        headerText: '库房',
        width: 120,
        valueGetter: (item) => item.storeRoom,
      ),
      GridColumnConfig<ArrivalTaskDetail>(
        name: 'subinventory',
        headerText: '子库',
        width: 120,
        valueGetter: (item) => item.subInventory,
      ),
      GridColumnConfig<ArrivalTaskDetail>(
        name: 'posnr',
        headerText: 'SAP行号',
        width: 120,
        valueGetter: (item) => item.sapLineNo,
      ),
      GridColumnConfig<ArrivalTaskDetail>(
        name: 'orderno',
        headerText: '装箱单号',
        width: 150,
        valueGetter: (item) => item.orderNo,
      ),
      GridColumnConfig<ArrivalTaskDetail>(
        name: 'arrivalsBillno',
        headerText: '到货单号',
        width: 150,
        valueGetter: (item) => item.arrivalsBillNo,
      ),
      GridColumnConfig<ArrivalTaskDetail>(
        name: 'supplier',
        headerText: '供应商',
        width: 220,
        valueGetter: (item) => item.supplierName,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    ];
  }
}
