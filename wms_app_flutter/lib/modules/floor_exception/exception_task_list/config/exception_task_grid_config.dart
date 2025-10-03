import 'package:flutter/material.dart';
import 'package:wms_app/common_widgets/common_grid/common_data_grid.dart';
import 'package:wms_app/modules/floor_exception/exception_task_list/models/exception_task.dart';

typedef ExceptionTaskOperation = void Function(
  ExceptionTaskRecord record,
  ExceptionTaskOperationType type,
);

enum ExceptionTaskOperationType { collect, reprocess }

class ExceptionTaskGridConfig {
  static List<GridColumnConfig<ExceptionTaskRecord>> buildColumns(
    ExceptionTaskOperation onOperate,
  ) {
    return [
      GridColumnConfig<ExceptionTaskRecord>(
        name: 'operation',
        headerText: '操作',
        width: 220,
        valueGetter: (_) => '',
        cellBuilder: (record, __, ___) => Wrap(
          spacing: 8,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: [
            _ActionButton(
              label: '采集',
              onPressed: record.toSummary().hasTaskBinding
                  ? () => onOperate(record, ExceptionTaskOperationType.collect)
                  : null,
            ),
            _ActionButton(
              label: '再处理',
              onPressed: () => onOperate(record, ExceptionTaskOperationType.reprocess),
            ),
          ],
        ),
      ),
      GridColumnConfig<ExceptionTaskRecord>(
        name: 'handleTime',
        headerText: '处理时间',
        width: 160,
        valueGetter: (record) => record.handleTime,
      ),
      GridColumnConfig<ExceptionTaskRecord>(
        name: 'operatorName',
        headerText: '采集人员',
        width: 140,
        valueGetter: (record) => record.operatorName,
      ),
      GridColumnConfig<ExceptionTaskRecord>(
        name: 'handleStatus',
        headerText: '处理状态',
        width: 140,
        valueGetter: (record) => record.handleStatus,
      ),
      GridColumnConfig<ExceptionTaskRecord>(
        name: 'proofNo',
        headerText: '凭证号',
        width: 160,
        valueGetter: (record) => record.proofNo,
      ),
      GridColumnConfig<ExceptionTaskRecord>(
        name: 'taskNo',
        headerText: '任务号',
        width: 160,
        valueGetter: (record) => record.taskNo,
      ),
      GridColumnConfig<ExceptionTaskRecord>(
        name: 'collectorType',
        headerText: '任务类型',
        width: 140,
        valueGetter: (record) => record.collectorType,
      ),
      GridColumnConfig<ExceptionTaskRecord>(
        name: 'businessKind',
        headerText: '采集类型',
        width: 140,
        valueGetter: (record) => record.businessKind,
      ),
      GridColumnConfig<ExceptionTaskRecord>(
        name: 'errorMessage',
        headerText: '错误信息',
        width: 320,
        valueGetter: (record) => record.errorMessage,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
      GridColumnConfig<ExceptionTaskRecord>(
        name: 'connectNo',
        headerText: '通讯批次',
        width: 160,
        valueGetter: (record) => record.connectNo,
      ),
      GridColumnConfig<ExceptionTaskRecord>(
        name: 'palletNo',
        headerText: '托盘号',
        width: 140,
        valueGetter: (record) => record.palletNo,
      ),
    ];
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, this.onPressed});

  final String label;
  final VoidCallback? onPressed;

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
