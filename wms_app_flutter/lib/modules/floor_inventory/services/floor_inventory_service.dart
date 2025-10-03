import 'package:dio/dio.dart';
import 'package:wms_app/modules/floor_inventory/task_collect/models/inventory_collect_models.dart';
import 'package:wms_app/modules/floor_inventory/task_details/models/inventory_task_detail.dart';
import 'package:wms_app/modules/floor_inventory/task_list/models/inventory_task.dart';
import 'package:wms_app/services/api_response_handler.dart';

class FloorInventoryService {
  FloorInventoryService(this._dio);

  final Dio _dio;

  Future<InventoryTaskListData> getInventoryTasks(InventoryTaskQuery query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/getInventoryTask',
      queryParameters: query.toJson(),
    );

    return ApiResponseHandler.handleResponse(
      response: response,
      dataExtractor: (data) => InventoryTaskListData.fromJson(
        Map<String, dynamic>.from(data as Map<dynamic, dynamic>),
      ),
    );
  }

  Future<void> commitInventoryTask({
    required String taskComment,
    required String userId,
    required bool isCancel,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/commitInventoryTask',
      queryParameters: {
        'taskcomment': taskComment,
        'userId': userId,
        'isCanel': isCancel.toString(),
      },
    );

    ApiResponseHandler.handleResponse(
      response: response,
      dataExtractor: (data) => data,
    );
  }

  Future<InventoryTaskDetailListData> getInventoryTaskItems(
    InventoryTaskDetailQuery query,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/getInventoryTaskItem',
      queryParameters: query.toJson(),
    );

    return ApiResponseHandler.handleResponse(
      response: response,
      dataExtractor: (data) => InventoryTaskDetailListData.fromJson(
        Map<String, dynamic>.from(data as Map<dynamic, dynamic>),
      ),
    );
  }

  Future<InventoryCollectionListData> getInventoryCollectingItems(
    InventoryTaskDetailQuery query,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/getOutTaskItem',
      queryParameters: query.toJson(),
    );

    return ApiResponseHandler.handleResponse(
      response: response,
      dataExtractor: (data) {
        if (data is Map<String, dynamic>) {
          return InventoryCollectionListData.fromJson(data);
        }
        if (data is Map) {
          return InventoryCollectionListData.fromJson(
            Map<String, dynamic>.from(data as Map<dynamic, dynamic>),
          );
        }
        if (data is List) {
          return InventoryCollectionListData(rows: data
              .map((e) => InventoryCollectionRecord.fromJson(
                    Map<String, dynamic>.from(e as Map<dynamic, dynamic>),
                  ))
              .toList());
        }
        return InventoryCollectionListData(rows: const []);
      },
    );
  }

  Future<InventoryStoreSiteInfo?> getStoreSiteByRoom({
    required String storeRoomNo,
    required String storeSiteNo,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/getStoreSite',
      queryParameters: {
        'storeRoomNo': storeRoomNo,
        'storeSiteNo': storeSiteNo,
      },
    );

    final data = response.data?['rows'] ?? response.data?['data'];
    if (data is List && data.isNotEmpty) {
      return InventoryStoreSiteInfo.fromJson(
        Map<String, dynamic>.from(data.first as Map<dynamic, dynamic>),
      );
    }

    if (data is Map) {
      return InventoryStoreSiteInfo.fromJson(
        Map<String, dynamic>.from(data as Map<dynamic, dynamic>),
      );
    }

    return null;
  }

  Future<List<InventoryStockInfo>> getInventoryStocks({
    required String storeSite,
    required String matCode,
    String? erpStoreRoom,
    String? batchNo,
    String? sn,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/getRepertoryByStoresiteNo',
      queryParameters: {
        'storesiteno': storeSite,
        'matcode': matCode,
        'erpStoreroom': erpStoreRoom,
        'batchno': batchNo,
        'sn': sn,
      },
    );

    final rows = response.data?['rows'] ?? response.data?['data'];
    if (rows is List) {
      return rows
          .map(
            (e) => InventoryStockInfo.fromJson(
              Map<String, dynamic>.from(e as Map<dynamic, dynamic>),
            ),
          )
          .toList();
    }

    return const [];
  }

  Future<InventoryMaterialInfo> getMaterialInfoByQr(String qrContent) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/system/terminal/getPmMaterialInfoByQR',
      data: {'qrContent': qrContent},
    );

    return ApiResponseHandler.handleResponse(
      response: response,
      dataExtractor: (data) => InventoryMaterialInfo.fromJson(
        Map<String, dynamic>.from(data as Map<dynamic, dynamic>),
      ),
    );
  }

  Future<void> submitInventoryInfos({
    required List<InventoryCollectionRecord> inventoryInfos,
    required String taskComment,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/system/terminal/commitInventoryInfos',
      data: {
        'inventoryInfos':
            inventoryInfos.map((e) => e.toSubmitJson()).toList(),
        'taskComment': taskComment,
      },
      options: Options(
        headers: {'content-type': 'application/json;charset=UTF-8'},
      ),
    );

    ApiResponseHandler.handleResponse(
      response: response,
      dataExtractor: (data) => data,
    );
  }
}
