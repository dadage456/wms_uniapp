# Flutter 重构 TODO（UniApp 模块迁移）

## 迁移目标概述
- 当前 Flutter 工程已经落地登录、首页、平库出库与平库入库模块，对应的依赖注入与路由模式可在 `app_module.dart` 与平库出库模块中复用。【F:wms_app_flutter/lib/app_module.dart†L1-L92】【F:wms_app_flutter/lib/modules/outbound/outbound_module.dart†L1-L112】
- 后续模块需参照 `api.md` 中的接口规范，并结合现有 UniApp 源码逐一对齐字段与业务流程，避免仅依赖接口文档与实际实现产生偏差。【F:wms_app_flutter/api.md†L1-L56】
- 扫码能力应统一复用 `ScannerService` 提供的广播流，避免在各页面重复绑定原生通道。【F:wms_app_flutter/lib/services/scanner_service.dart†L1-L52】

## 共性改造任务
1. **模块化接入**：每个业务模块需要新增独立的 `Module`、`Service`、`Bloc`、`Page` 目录结构，沿用平库出/入库的 BLoC + Flutter Modular 组合，确保可以从首页占位入口无缝跳转。
2. **接口封装**：根据 UniApp 页面引用的接口，整理请求/响应模型，封装到对应的 `services` 层，所有 POST 请求保持 `application/json;charset=UTF-8` 头部以兼容后端。【F:api/system/arriveSign.js†L37-L52】【F:api/system/goodsDown.js†L54-L82】
3. **数据模型**：分析 `response.data.rows`、`response.data.total` 等字段，建立 Dart 模型并提供 `fromJson`/`toJson`。注意部分接口会返回 `rows` 列表或直接返回数组，需要在 `ApiResponseHandler` 中做兼容（参考平库入库采集明细实现）。【F:wms_app_flutter/lib/modules/floor_inbound/services/floor_inbound_service.dart†L38-L97】
4. **扫码交互**：UniApp 页面普遍通过 `uni.$on('scancodedate')` 监听扫码结果，需要在 Flutter 中统一封装监听、节流与焦点控制逻辑。
5. **公共组件**：评估是否提取通用的表格、底部操作栏、弹窗等组件，减少平库/立库模块重复实现。

## 模块级待办事项

### 1. 到货接收（pages/arrive_sign）
- **现状梳理**：包含列表、明细、任务接收、采集明细 4 个页面，支持扫码查询、任务接收、撤销等操作。【F:pages/arrive_sign/index.nvue†L1-L120】【F:pages/arrive_sign/task_receive/index.nvue†L1-L120】
- **接口依赖**：`getArriveSignList`、`getArriveUnSignList`、`receArriveSign`、`cancleArriveSign`、`getArriveSignDetailList`、`CommitSignShelves`、`getPmMaterialInfoByQR`。【F:api/system/arriveSign.js†L5-L68】
- **迁移任务**：
  - 定义到货单、任务明细、采集提交的模型与表单状态。
  - 实现列表/接收/采集三个 Bloc，复用通用分页、扫码触发查询逻辑。
  - 开发接收/撤销弹窗确认组件，与平库出库列表的操作按钮交互保持一致。
  - 采集页面需支持托盘/货位输入与提交校验，复现 UniApp 中的校验与提示。
  - 将模块挂载到 `/arrival` 路由并替换当前占位模块。

### 2. 平库盘点（pages/Inventorytask）
- **现状梳理**：包含任务列表、任务接收、采集列表、采集中明细等页面，涉及任务列表与采集结果双表格切换。【F:pages/Inventorytask/task_collect/InventorytaskaskItem.nvue†L1-L120】
- **接口依赖**：`getInventoryTask`、`commitInventoryTask`、`getInventoryTaskItem`、`commitInventoryInfos`、`getOutTaskCollitemList`、`getStoreSiteByRoom`、`getMtlRepertoryByStoresiteNo` 等。【F:api/system/goodsDown.js†L190-L292】
- **迁移任务**：
  - ✅ 已完成：搭建 `FloorInventoryModule`，实现任务列表、接收列表与明细展示（含搜索、扫码触发、撤销/接收操作）。
  - ✅ 已完成：采集流程（扫码、双表格联动、批次校验、提交 `commitInventoryInfos`）。
  - ✅ 抽象盘点任务/任务明细模型，包含库位、物料、数量、盘点类型等字段。
  - ✅ 设计盘点列表 Bloc（任务领取）、采集 Bloc（含双表格与批量操作）、提交 Bloc（提交成功后刷新列表）。
  - ✅ 实现扫码流程（库位→物料→批次→数量），并处理 UniApp 中的批次、供应商、库位校验逻辑。
  - ✅ 平库盘点入口 `/floor-count` 替换占位模块，并在首页展示正确状态。

### 3. 平库异常处理（pages/exceptTask & pages/exceptColl）
- **现状梳理**：异常上架处理页面支持根据托盘/库位选择异常任务、提交异常搁置；异常列表/任务消息/SAP 接口异常需展示列表并允许重处理或确认。【F:pages/exceptTask/exceptTask.nvue†L80-L128】【F:pages/exceptColl/pdacollExcept.nvue†L1-L80】
- **接口依赖**：`GetRoomMatControl`、`GetMatControl`、`getPalletSiteNo`、`CommitExceptShelves`、`selectPdaCollExceptList`、`selectTaskMessageList`、`selectSapInteExceptList`、`reprocessDconnect`、`messageConfim`。【F:api/system/goodsDown.js†L292-L340】【F:api/system/goodsUp.js†L170-L244】
- **迁移任务**：
  - ✅ 拆分“异常处理”与“消息中心”子模块，统一使用共享的表格组件和分页筛选（异常任务列表、任务消息、SAP 接口异常）。
  - ✅ 封装异常任务采集校验（库房、托盘、库位、物料控制模式），提交参数对齐 UniApp 逻辑并复用扫码流。
  - ✅ 异常与消息列表支持分页、再处理、确认等操作，结合 Bloc Side Effect 触发二次确认与提示。
  - ✅ 首页功能入口新增“异常处理”模块并接入 `/floor-exception` 路由，三类视图以 TabBar 聚合。

### 4. 平库移库 & 库存查询（pages/transfer, pages/queryrepertory）
- **现状梳理**：移库页面包含扫码驱动的多步骤（来源库位→目标库位→物料→批次→数量），并带有采集结果与库存查询双 Tab；库存查询独立页面支持条码查询与结果表格展示。【F:pages/transfer/transfer.nvue†L1-L160】【F:pages/queryrepertory/queryRepertory.nvue†L1-L60】
- **接口依赖**：`CommitTransfer`、`GetRepertoryByStoresiteNoTransfer`、`getStoreSiteByRoom`、`getLSMtlRepertoryByStoresiteNo`、`CommitUpShelves`、`getPmMaterialInfoByQR`、`GetRepertoryByBarCode`。【F:api/system/goodsUp.js†L120-L212】
- **迁移任务**：
  - ✅ 设计移库流程状态机，控制扫码顺序、数量累加、操作模式切换（移入/移出）。
  - ✅ 实现采集结果与库存查询的标签页切换组件，与底部操作栏（操作模式、删除、提交）交互保持一致。
  - ✅ 封装库存查询服务，可在移库与独立库存查询页面共享。
  - ✅ 完成 `/floor-transfer` 与 `/inventory-query` 路由替换及首页入口对接。

### 5. 物料入场（pages/mtlsenter）
- **现状梳理**：入场采集界面需要校验库房、库位、物料重量/容量，并调用多接口获取物料库存、托盘信息等。【F:pages/mtlsenter/mtlSenterTaskItem.nvue†L60-L120】
- **接口依赖**：`getIntaskitemList`、`getStoreSiteByRoom`、`getLSMtlRepertoryByStoresiteNo`、`CommitUpShelves`、`CommitMtlSender`、`getMtlQtyByMtlCode`、`getPmMaterialInfoByQR`。【F:api/system/goodsUp.js†L1-L156】
- **迁移任务**：
  - ✅ 提炼入场任务模型，支持扫码识别库位、物料并封装 `PullFeedingRecord`、`PullFeedingBarcodeContent` 数据结构。
  - ✅ 构建多步骤采集表单与校验流程，覆盖库位→物料→数量的扫码顺序、库存校验及最小包装/配送量提示。
  - ✅ 完成提交成功后的数据清理与反馈提示，接入 `commitMtlSender` 接口并在首页入口替换原占位模块。

### 6. 消息公告中心（pages/msg）
- **现状梳理**：消息列表展示最近通知，详情页显示公告内容。【F:pages/msg/msg.nvue†L1-L80】【F:pages/msg/msgdetail.nvue†L1-L60】
- **接口依赖**：`getMorNotice`、`getNoticeDetail`。【F:api/system/goodsUp.js†L212-L240】
- **迁移任务**：
  - ✅ 实现公告列表 Bloc，支持下拉刷新与未读计数。
  - ✅ 构建公告详情页，展示富文本内容并复用统一 AppBar 样式。
  - ✅ 在首页消息入口显示未读徽标，结合 UserManager 缓存阅读状态。

### 7. 立库出库（pages/aswhdown）
- **现状梳理**：包含任务列表、接收、采集、WMS→WCS 指令、托盘采集等多个页面，操作复杂度高。【F:pages/aswhdown/aswhDown.nvue†L1-L120】【F:pages/aswhdown/task_collect/aswhDownTaskItem.nvue†L150-L220】
- **接口依赖**：`getOutaskList`、`getOutTaskitemList`、`getOutTaskCollitemList`、`CommitRCOutTaskItem`、`CommitASWHDownShelves`、`CommitDownWmsToWcs`、`commitInvDownWmsToWcs`、`CommitEmptyTrayWmsToWcs`、`CommitASWHPalletNoDownShelves`、`getPmMaterialInfoByQR` 等。【F:api/system/goodsDown.js†L1-L188】【F:api/system/goodsDown.js†L292-L340】
- **迁移任务**：
  - ✅ 规划立库出库模块的服务层，区分常规出库、盘库出库、托盘出库等不同提交流程。
  - ✅ 设计任务/明细/采集/托盘指令 Bloc，梳理状态机与错误处理（例如 WCS 指令失败的回滚）。
  - ✅ 抽象托盘与货位数据模型，并实现快速扫码定位功能。
  - ✅ 将模块接入新路由 `/asrs-outbound`，替换原 FeaturePlaceholder 并更新首页入口。
  - ✅ 首页“在线拣选”功能卡片直接打开 Flutter 立库出库模块。

### 8. 立库入库（pages/aswhup）
- **现状梳理**：支持任务列表、接收、采集、托盘校验、WMS→WCS 指令查询等流程。【F:pages/aswhup/aswhUp.nvue†L1-L80】【F:pages/aswhup/task_collect/aswhUpTaskItem.nvue†L110-L200】
- **接口依赖**：`getIntaskList`、`getIntaskitemList`、`CommitUpShelves`、`CommitUpWmsToWcs`、`CheckBindingTray`、`CheckBindingTrayByTaskId`、`getPalletItemByTaskID`、`getWmsToWcsByTaskID`、`CommitTrayUpShelves` 等。【F:api/system/aswhUp.js†L1-L160】
- **迁移任务**：
  - ✅ 构建立库入库任务模型，覆盖托盘、库位、重量/容量、WCS 指令等字段。
  - ✅ 设计托盘绑定、库位校验、指令查询等子流程 Bloc，并与扫码服务联动。
  - ✅ 根据不同采集页面的差异（普通、托盘、WMS→WCS）拆分 UI 组件，提取复用逻辑。
  - ✅ 首页“立库组盘”入口指向 Flutter 立库入库模块，替换原占位实现。

### 9. 立库盘点（pages/aswhInventorytask）
- **现状梳理**：与平库盘点类似，但多出托盘、WCS 指令处理、盘点类型切换等需求。【F:pages/aswhInventorytask/aswhInventoryTask.nvue†L1-L80】【F:pages/aswhInventorytask/task_collect/aswhInventorytaskaskItem.nvue†L140-L220】
- **接口依赖**：`getInventoryTask`、`commitInventoryTask`、`getInventoryTaskItem`、`CommitInvDownWmsToWcs`、`CommitInvResetWmsToWcs`、`getPalletItemByTaskID` 等。【F:api/system/goodsDown.js†L190-L292】【F:api/system/goodsDown.js†L292-L340】
- **迁移任务**：
  - ✅ 复用平库盘点的基础架构，扩展托盘/WCS 相关模型与指令提交流程。
  - ✅ 完成托盘维度的采集页面与 WMS→WCS 指令查询页面。
  - 🔄 评估盘点任务领取与角色控制逻辑（当前沿用通用用户上下文，待与后端权限完成联调后补充）。

### 10. 个人设置与账户相关补充
- ✅ 新增 `AccountModule`，承载个人中心、资料编辑与修改密码页面，并从首页右上角入口跳转。
- ✅ 封装 `/system/user/profile` 与 `/system/user/profile/updatePwd` 接口，支持资料更新后刷新 `UserManager`，并在修改密码成功后同步本地登录凭据。

## 集成与测试计划
1. **阶段性集成**：按照“到货接收 → 平库盘点 → 立库模块 → 异常/移库/查询 → 消息公告”的顺序逐步替换首页占位入口，每个阶段完成后编写集成测试或手动测试用例清单。
2. **接口联调**：每个模块上线前，与后端确认参数字段和异常码，必要时在服务层增加错误码解释。
3. **扫码/硬件测试**：在真机环境验证扫码顺序与性能，确保多个页面并发监听时不会丢码。
4. **回归测试**：完成所有模块迁移后，执行端到端回归，包括任务领取、采集、提交、异常处理等关键路径。
