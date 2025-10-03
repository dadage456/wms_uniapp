import 'package:wms_app/common_widgets/common_grid/common_data_grid.dart';
import 'package:wms_app/modules/floor_inbound/task_details/models/inbound_task_item.dart';

class InboundTaskDetailGridConfig {
  static List<GridColumnConfig<InboundTaskItem>> buildColumns() {
    return [
      GridColumnConfig(
        title: '任务明细ID',
        width: 140,
        valueGetter: (item) => item.itemId,
      ),
      GridColumnConfig(
        title: '物料编码',
        width: 160,
        valueGetter: (item) => item.matCode,
      ),
      GridColumnConfig(
        title: '物料名称',
        width: 220,
        valueGetter: (item) => item.matName,
      ),
      GridColumnConfig(
        title: '库位',
        width: 140,
        valueGetter: (item) => item.storeSiteNo,
      ),
      GridColumnConfig(
        title: '批次',
        width: 140,
        valueGetter: (item) => item.batchNo,
      ),
      GridColumnConfig(
        title: '计划数量',
        width: 120,
        valueGetter: (item) => item.planQty.toStringAsFixed(2),
        alignment: GridColumnAlignment.right,
      ),
      GridColumnConfig(
        title: '已采集数量',
        width: 120,
        valueGetter: (item) => item.collectedQty.toStringAsFixed(2),
        alignment: GridColumnAlignment.right,
      ),
      GridColumnConfig(
        title: '库存数量',
        width: 120,
        valueGetter: (item) => item.inventoryQty.toStringAsFixed(2),
        alignment: GridColumnAlignment.right,
      ),
    ];
  }
}
