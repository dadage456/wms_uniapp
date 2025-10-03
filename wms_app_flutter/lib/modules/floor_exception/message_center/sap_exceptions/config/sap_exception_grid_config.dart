import 'package:flutter/material.dart';
import 'package:wms_app/common_widgets/common_grid/common_data_grid.dart';
import 'package:wms_app/modules/floor_exception/message_center/sap_exceptions/models/sap_exception.dart';

class SapExceptionGridConfig {
  static List<GridColumnConfig<SapExceptionRecord>> buildColumns() {
    return [
      GridColumnConfig<SapExceptionRecord>(
        name: 'orderNumber',
        headerText: '单据号',
        width: 180,
        valueGetter: (row) => row.orderNumber,
      ),
      GridColumnConfig<SapExceptionRecord>(
        name: 'sourceNumber',
        headerText: '源单号',
        width: 180,
        valueGetter: (row) => row.sourceNumber,
      ),
      GridColumnConfig<SapExceptionRecord>(
        name: 'orderType',
        headerText: '单据类型',
        width: 120,
        valueGetter: (row) => row.orderType,
      ),
      GridColumnConfig<SapExceptionRecord>(
        name: 'batchId',
        headerText: '发送批',
        width: 120,
        valueGetter: (row) => row.batchId,
      ),
      GridColumnConfig<SapExceptionRecord>(
        name: 'processDate',
        headerText: '处理时间',
        width: 200,
        valueGetter: (row) => row.processDate,
      ),
      GridColumnConfig<SapExceptionRecord>(
        name: 'sourceHeaderId',
        headerText: '单据ID',
        width: 120,
        valueGetter: (row) => row.sourceHeaderId,
      ),
      GridColumnConfig<SapExceptionRecord>(
        name: 'processStatus',
        headerText: '处理状态',
        width: 140,
        valueGetter: (row) => row.processStatus,
      ),
      GridColumnConfig<SapExceptionRecord>(
        name: 'processMessage',
        headerText: '错误信息',
        width: 360,
        valueGetter: (row) => row.processMessage,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
      GridColumnConfig<SapExceptionRecord>(
        name: 'reserveF1',
        headerText: '备注',
        width: 120,
        valueGetter: (row) => row.reserveF1,
      ),
      GridColumnConfig<SapExceptionRecord>(
        name: 'interfaceName',
        headerText: '回传类型',
        width: 160,
        valueGetter: (row) => row.interfaceName,
      ),
      GridColumnConfig<SapExceptionRecord>(
        name: 'jobId',
        headerText: '处理ID',
        width: 120,
        valueGetter: (row) => row.jobId,
      ),
      GridColumnConfig<SapExceptionRecord>(
        name: 'orderTypeName',
        headerText: '单据类型名',
        width: 200,
        valueGetter: (row) => row.orderTypeName,
      ),
    ];
  }
}
