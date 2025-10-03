import 'package:flutter/material.dart';
import 'package:wms_app/common_widgets/custom_app_bar.dart';
import 'package:wms_app/modules/arrival/task_list/models/arrival_task.dart';

/// TODO: 采集功能将在后续迭代中补充完整
class ArrivalCollectionPage extends StatelessWidget {
  const ArrivalCollectionPage({super.key, required this.task});

  final ArrivalTask task;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '到货签收采集',
        onBackPressed: () => Navigator.of(context).pop(),
      ).appBar,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '到货单号：${task.arrivalsBillNo}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text('装箱单号：${task.orderNo}'),
            Text('采购单号：${task.poNumber}'),
            Text('供应商：${task.supplierName}'),
            const SizedBox(height: 24),
            const Card(
              elevation: 0,
              color: Color(0xFFF6F6F6),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  '采集流程将参考 UniApp 逻辑拆分为扫码、采集结果与提交三个步骤。'
                  ' 当前页面作为占位，后续将补充扫码监听、采集结果表格、提交接口对接等能力。',
                  style: TextStyle(fontSize: 14, height: 1.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
