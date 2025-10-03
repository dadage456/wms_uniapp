import 'package:dio/dio.dart';
import 'package:wms_app/modules/asrs_inventory/models/asrs_inventory_models.dart';
import 'package:wms_app/services/api_response_handler.dart';

class AsrsInventoryService {
  AsrsInventoryService(this._dio);

  final Dio _dio;

  Future<List<AsrsInventoryTask>> fetchTaskList({
    String? keyword,
    bool onlyProcessing = true,
    int pageIndex = 1,
    int pageSize = 100,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/getInventoryTask',
      queryParameters: {
        if (keyword != null && keyword.isNotEmpty) 'searchKey': keyword,
        'PageIndex': '$pageIndex',
        'PageSize': '$pageSize',
        if (onlyProcessing) 'finshFlg': '0',
      },
    );

    final rows = ApiResponseHandler.handleResponse<List<dynamic>>(
      response: response,
      dataExtractor: (raw) {
        if (raw is List) return raw;
        if (raw is Map<String, dynamic> && raw['rows'] is List) {
          return raw['rows'] as List;
        }
        throw Exception('立库盘点任务响应格式不正确');
      },
    );

    return rows
        .map(
          (e) => AsrsInventoryTask.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }

  Future<void> commitTask({
    required String taskComment,
    required String userId,
    bool cancel = false,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/commitInventoryTask',
      queryParameters: {
        'taskcomment': taskComment,
        'userId': userId,
        'isCanel': cancel ? 'true' : 'false',
      },
    );

    ApiResponseHandler.handleResponse(
      response: response,
      dataExtractor: (raw) => raw,
    );
  }

  Future<List<AsrsInventoryTaskDetail>> fetchTaskDetails({
    required String taskComment,
    required String taskNo,
    required String roomTag,
    String? keyword,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/getInventoryTaskItem',
      queryParameters: {
        'taskcomment': taskComment,
        'taskNo': taskNo,
        'roomTag': roomTag,
        if (keyword != null && keyword.isNotEmpty) 'searchKey': keyword,
      },
    );

    final rows = ApiResponseHandler.handleResponse<List<dynamic>>(
      response: response,
      dataExtractor: (raw) {
        if (raw is List) return raw;
        if (raw is Map<String, dynamic> && raw['rows'] is List) {
          return raw['rows'] as List;
        }
        throw Exception('立库盘点任务明细响应格式不正确');
      },
    );

    return rows
        .map(
          (e) => AsrsInventoryTaskDetail.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }

  Future<List<AsrsInventoryTrayItem>> fetchTrayItems({
    required String taskId,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/getPalletItemByTaskID',
      queryParameters: {'taskId': taskId},
    );

    final rows = ApiResponseHandler.handleResponse<List<dynamic>>(
      response: response,
      dataExtractor: (raw) {
        if (raw is List) return raw;
        if (raw is Map<String, dynamic> && raw['rows'] is List) {
          return raw['rows'] as List;
        }
        throw Exception('托盘采集记录响应格式不正确');
      },
    );

    return rows
        .map(
          (e) => AsrsInventoryTrayItem.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }

  Future<void> submitCollection({
    required String taskComment,
    required List<AsrsInventoryCollectionRecord> records,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/system/terminal/commitInventoryInfos',
      data: {
        'inventoryInfos': records.map((e) => e.toJson()).toList(),
        'taskComment': taskComment,
      },
      options: Options(headers: {
        'content-type': 'application/json;charset=UTF-8',
      }),
    );

    ApiResponseHandler.handleResponse(
      response: response,
      dataExtractor: (raw) => raw,
    );
  }

  Future<List<AsrsInventoryWcsCommand>> fetchCommandHistory({
    required String taskId,
    required String taskComment,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/getWmsToWcsByTaskID',
      queryParameters: {
        'taskId': taskId,
        'taskComment': taskComment,
        'TaskType': 'INV',
      },
    );

    final rows = ApiResponseHandler.handleResponse<List<dynamic>>(
      response: response,
      dataExtractor: (raw) {
        if (raw is List) return raw;
        if (raw is Map<String, dynamic> && raw['rows'] is List) {
          return raw['rows'] as List;
        }
        throw Exception('指令历史响应格式不正确');
      },
    );

    return rows
        .map(
          (e) => AsrsInventoryWcsCommand.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }

  Future<void> submitDownCommand({
    required String taskId,
    required String taskNo,
    required String trayNo,
    required String startAddress,
    required String endAddress,
    bool singleFlag = false,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/commitInvDownWmsToWcs',
      queryParameters: {
        'taskId': taskId,
        'taskNo': taskNo,
        'trayNo': trayNo,
        'startAddr': startAddress,
        'endAddr': endAddress,
        'singleFlag': singleFlag ? '1' : '0',
      },
    );

    ApiResponseHandler.handleResponse(
      response: response,
      dataExtractor: (raw) => raw,
    );
  }

  Future<void> submitResetCommand({
    required String taskId,
    required String taskNo,
    required String trayNo,
    required String startAddress,
    required String endAddress,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/commitInvResetWmsToWcs',
      queryParameters: {
        'taskId': taskId,
        'taskNo': taskNo,
        'trayNo': trayNo,
        'startAddr': startAddress,
        'endAddr': endAddress,
      },
    );

    ApiResponseHandler.handleResponse(
      response: response,
      dataExtractor: (raw) => raw,
    );
  }
}
