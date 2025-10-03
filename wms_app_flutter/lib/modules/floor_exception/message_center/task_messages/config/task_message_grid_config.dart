import 'package:flutter/material.dart';
import 'package:wms_app/common_widgets/common_grid/common_data_grid.dart';
import 'package:wms_app/modules/floor_exception/message_center/task_messages/models/exception_task_message.dart';

typedef TaskMessageOperation = void Function(
  ExceptionTaskMessage message,
  TaskMessageOperationType type,
);

enum TaskMessageOperationType { confirm }

class TaskMessageGridConfig {
  static List<GridColumnConfig<ExceptionTaskMessage>> buildColumns(
    TaskMessageOperation onOperate,
  ) {
    return [
      GridColumnConfig<ExceptionTaskMessage>(
        name: 'operation',
        headerText: '操作',
        width: 120,
        valueGetter: (_) => '',
        cellBuilder: (row, __, ___) => Center(
          child: SizedBox(
            height: 32,
            child: OutlinedButton(
              onPressed: () => onOperate(row, TaskMessageOperationType.confirm),
              child: const Text('确认'),
            ),
          ),
        ),
      ),
      GridColumnConfig<ExceptionTaskMessage>(
        name: 'messageType',
        headerText: '消息类型',
        width: 160,
        valueGetter: (row) => row.messageType,
      ),
      GridColumnConfig<ExceptionTaskMessage>(
        name: 'messageStatus',
        headerText: '状态',
        width: 120,
        valueGetter: (row) => row.messageStatus,
      ),
      GridColumnConfig<ExceptionTaskMessage>(
        name: 'messageTitle',
        headerText: '标题',
        width: 220,
        valueGetter: (row) => row.messageTitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      GridColumnConfig<ExceptionTaskMessage>(
        name: 'messageContent',
        headerText: '内容',
        width: 360,
        valueGetter: (row) => row.messageContent,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
      GridColumnConfig<ExceptionTaskMessage>(
        name: 'createTime',
        headerText: '下达时间',
        width: 180,
        valueGetter: (row) => row.createTime,
      ),
      GridColumnConfig<ExceptionTaskMessage>(
        name: 'receiveTime',
        headerText: '处理时间',
        width: 180,
        valueGetter: (row) => row.receiveTime,
      ),
    ];
  }
}
