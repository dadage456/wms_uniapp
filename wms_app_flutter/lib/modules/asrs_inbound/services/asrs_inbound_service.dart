import 'package:dio/dio.dart';
import 'package:wms_app/modules/asrs_inbound/models/asrs_inbound_models.dart';
import 'package:wms_app/services/api_response_handler.dart';

class AsrsInboundService {
  AsrsInboundService(this._dio);

  final Dio _dio;

  Future<List<AsrsInboundTask>> fetchTaskList({
    String? keyword,
    bool onlyProcessing = true,
    int pageIndex = 1,
    int pageSize = 100,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/intaskList',
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
        if (raw is Map && raw['rows'] is List) {
          return raw['rows'] as List;
        }
        throw Exception('立库入库任务响应格式不正确');
      },
    );

    return rows
        .map((e) => AsrsInboundTask.fromJson(
              Map<String, dynamic>.from(e as Map),
            ))
        .toList();
  }

  Future<List<AsrsInboundTaskDetail>> fetchTaskDetails({
    required String taskId,
    String? keyword,
    int pageIndex = 1,
    int pageSize = 200,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/intaskitemList',
      queryParameters: {
        'intaskid': taskId,
        'PageIndex': '$pageIndex',
        'PageSize': '$pageSize',
        if (keyword != null && keyword.isNotEmpty) 'searchKey': keyword,
      },
    );

    final rows = ApiResponseHandler.handleResponse<List<dynamic>>(
      response: response,
      dataExtractor: (raw) {
        if (raw is List) return raw;
        if (raw is Map && raw['rows'] is List) {
          return raw['rows'] as List;
        }
        throw Exception('立库入库明细响应格式不正确');
      },
    );

    return rows
        .map((e) => AsrsInboundTaskDetail.fromJson(
              Map<String, dynamic>.from(e as Map),
            ))
        .toList();
  }

  Future<List<AsrsInboundTrayInfo>> fetchTrayInfos(String taskId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/getInTaskPalletNo',
      queryParameters: {'intaskid': taskId},
    );

    final rows = ApiResponseHandler.handleResponse<List<dynamic>>(
      response: response,
      dataExtractor: (raw) {
        if (raw is List) return raw;
        if (raw is Map && raw['rows'] is List) {
          return raw['rows'] as List;
        }
        throw Exception('托盘信息响应格式不正确');
      },
    );

    return rows
        .map((e) => AsrsInboundTrayInfo.fromJson(
              Map<String, dynamic>.from(e as Map),
            ))
        .toList();
  }

  Future<List<AsrsInboundWcsCommand>> fetchCommandHistory({
    required String taskId,
    required String taskComment,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/getWmsToWcsByTaskID',
      queryParameters: {
        'taskId': taskId,
        'taskComment': taskComment,
        'TaskType': 'IN',
      },
    );

    final rows = ApiResponseHandler.handleResponse<List<dynamic>>(
      response: response,
      dataExtractor: (raw) {
        if (raw is List) return raw;
        if (raw is Map && raw['rows'] is List) {
          return raw['rows'] as List;
        }
        throw Exception('指令历史响应格式不正确');
      },
    );

    return rows
        .map((e) => AsrsInboundWcsCommand.fromJson(
              Map<String, dynamic>.from(e as Map),
            ))
        .toList();
  }

  Future<void> submitWcsCommand({
    required String taskId,
    required String taskNo,
    required String trayNo,
    required String startAddress,
    required String endAddress,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/commitUpWmsToWcs',
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

  Future<void> commitUpShelves({
    required String taskNo,
    required String trayNo,
    required List<Map<String, dynamic>> upShelvesInfos,
    required List<Map<String, dynamic>> itemListInfos,
    required String filter,
    double? currentWeight,
    double? currentCapacity,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/system/terminal/commitUpTray',
      data: {
        'upShelvesInfos': upShelvesInfos,
        'itemListInfos': itemListInfos,
        'taskNo': taskNo,
        'trayNo': trayNo,
        'filter': filter,
        'currentWeight': currentWeight?.toString(),
        'currentCapacity': currentCapacity?.toString(),
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

  Future<void> commitTrayUpShelves({
    required String taskNo,
    required List<Map<String, dynamic>> trayInfos,
    required List<Map<String, dynamic>> itemListInfos,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/system/terminal/commitTrayUpShelves',
      data: {
        'trayInfos': trayInfos,
        'itemListInfos': itemListInfos,
        'taskNo': taskNo,
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

  Future<void> checkTray(String trayNo) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/checkTray',
      queryParameters: {'trayNo': trayNo},
    );

    ApiResponseHandler.handleResponse(
      response: response,
      dataExtractor: (raw) => raw,
    );
  }

  Future<void> checkTrayBinding({
    required String taskId,
    required String trayNo,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/checkBindingTray',
      queryParameters: {
        'taskId': taskId,
        'trayNo': trayNo,
        'taskType': 'IN',
      },
    );

    ApiResponseHandler.handleResponse(
      response: response,
      dataExtractor: (raw) => raw,
    );
  }

  Future<AsrsInboundTaskDetail> getMaterialInfoByBarcode({
    required String barcode,
    required String taskId,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/materialInfo',
      queryParameters: {'QRstring': barcode, 'taskId': taskId},
    );

    return ApiResponseHandler.handleResponse(
      response: response,
      dataExtractor: (raw) => AsrsInboundTaskDetail.fromJson(
        Map<String, dynamic>.from(raw as Map),
      ),
    );
  }
}
