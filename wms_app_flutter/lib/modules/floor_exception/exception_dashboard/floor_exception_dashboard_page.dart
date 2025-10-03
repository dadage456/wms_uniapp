import 'package:flutter/material.dart';
import 'package:wms_app/modules/floor_exception/exception_task_list/exception_task_list_page.dart';
import 'package:wms_app/modules/floor_exception/message_center/sap_exceptions/sap_exception_page.dart';
import 'package:wms_app/modules/floor_exception/message_center/task_messages/task_message_page.dart';

class FloorExceptionDashboardPage extends StatefulWidget {
  const FloorExceptionDashboardPage({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<FloorExceptionDashboardPage> createState() =>
      _FloorExceptionDashboardPageState();
}

class _FloorExceptionDashboardPageState
    extends State<FloorExceptionDashboardPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = [
    Tab(text: '异常任务'),
    Tab(text: '任务消息'),
    Tab(text: '接口异常'),
  ];

  @override
  void initState() {
    super.initState();
    final initialIndex = widget.initialTab.clamp(0, _tabs.length - 1);
    _tabController = TabController(length: _tabs.length, vsync: this, initialIndex: initialIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1976D2),
        title: const Text('异常处理中心'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs,
          indicatorColor: Colors.white,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ExceptionTaskListPage(),
          TaskMessagePage(),
          SapExceptionPage(),
        ],
      ),
    );
  }
}
