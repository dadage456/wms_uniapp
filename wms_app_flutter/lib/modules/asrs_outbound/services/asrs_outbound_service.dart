import 'package:dio/dio.dart';
import 'package:wms_app/modules/asrs_outbound/models/asrs_outbound_models.dart';
import 'package:wms_app/services/api_response_handler.dart';

class AsrsOutboundService {
  AsrsOutboundService(this._dio);

  final Dio _dio;

  Future<List<AsrsOutboundTask>> fetchTaskList({
    String? keyword,
    bool onlyProcessing = true,
    int pageIndex = 1,
    int pageSize = 100,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/outList',
      queryParameters: {
        if (keyword != null && keyword.isNotEmpty) 'searchKey': keyword,
        'PageIndex': '$pageIndex',
        'PageSize': '$pageSize',
        if (onlyProcessing) 'finshFlg': '0',
      },
    );

    final data = ApiResponseHandler.handleResponse<List<dynamic>>(
      response: response,
      dataExtractor: (raw) {
        if (raw is List) return raw;
        if (raw is Map && raw['rows'] is List) {
          return raw['rows'] as List;
        }
        throw Exception('立库出库任务响应格式不正确');
      },
    );

    return data
        .map((e) => AsrsOutboundTask.fromJson(
              Map<String, dynamic>.from(e as Map<dynamic, dynamic>),
            ))
        .toList();
  }

  Future<List<AsrsOutboundTaskDetail>> fetchTaskDetails({
    required String taskId,
    String? searchKey,
    int pageIndex = 1,
    int pageSize = 100,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/outTaskitemList',
      queryParameters: {
        'outtaskid': taskId,
        if (searchKey != null && searchKey.isNotEmpty) 'searchKey': searchKey,
        'PageIndex': '$pageIndex',
        'PageSize': '$pageSize',
      },
    );

    final data = ApiResponseHandler.handleResponse<List<dynamic>>(
      response: response,
      dataExtractor: (raw) {
        if (raw is List) return raw;
        if (raw is Map && raw['rows'] is List) {
          return raw['rows'] as List;
        }
        throw Exception('立库出库明细响应格式不正确');
      },
    );

    return data
        .map((e) => AsrsOutboundTaskDetail.fromJson(
              Map<String, dynamic>.from(e as Map<dynamic, dynamic>),
            ))
        .toList();
  }

  Future<List<AsrsOutboundTaskDetail>> fetchCollectedDetails({
    required String taskId,
    int pageIndex = 1,
    int pageSize = 100,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/getOutTaskItem',
      queryParameters: {
        'outtaskid': taskId,
        'PageIndex': '$pageIndex',
        'PageSize': '$pageSize',
      },
    );

    final data = ApiResponseHandler.handleResponse<List<dynamic>>(
      response: response,
      dataExtractor: (raw) {
        if (raw is List) return raw;
        if (raw is Map && raw['rows'] is List) {
          return raw['rows'] as List;
        }
        throw Exception('采集记录响应格式不正确');
      },
    );

    return data
        .map((e) => AsrsOutboundTaskDetail.fromJson(
              Map<String, dynamic>.from(e as Map<dynamic, dynamic>),
            ))
        .toList();
  }

  Future<void> commitReceive({
    required List<String> taskItemIds,
    required String roomTag,
    required bool cancel,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/system/terminal/commitRCOutTaskItem',
      data: {
        'outtaskitemids': taskItemIds,
        'roomTag': roomTag,
        'isCanel': cancel ? 'true' : 'false',
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

  Future<AsrsMaterialInfo> getMaterialInfo(String barcode) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/materialInfo',
      queryParameters: {'QRstring': barcode},
    );

    return ApiResponseHandler.handleResponse(
      response: response,
      dataExtractor: (raw) => AsrsMaterialInfo.fromJson(
        Map<String, dynamic>.from(raw as Map<dynamic, dynamic>),
      ),
    );
  }

  Future<List<AsrsInventoryStock>> getInventoryByStoreSite({
    required String storeSiteNo,
    required String materialCode,
    String? storeRoomNo,
    String? batchNo,
    String? serialNo,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/getRepertoryByStoresiteNo',
      queryParameters: {
        'storesiteno': storeSiteNo,
        'matcode': materialCode,
        if (storeRoomNo != null && storeRoomNo.isNotEmpty) 'erpStoreroom': storeRoomNo,
        if (batchNo != null && batchNo.isNotEmpty) 'batchno': batchNo,
        if (serialNo != null && serialNo.isNotEmpty) 'sn': serialNo,
      },
    );

    final data = ApiResponseHandler.handleResponse<List<dynamic>>(
      response: response,
      dataExtractor: (raw) {
        if (raw is List) return raw;
        if (raw is Map && raw['rows'] is List) {
          return raw['rows'] as List;
        }
        throw Exception('库存响应格式不正确');
      },
    );

    return data
        .map((e) => AsrsInventoryStock.fromJson(
              Map<String, dynamic>.from(e as Map<dynamic, dynamic>),
            ))
        .toList();
  }

  Future<void> commitDownShelves({
    required List<Map<String, dynamic>> downShelvesInfos,
    required List<Map<String, dynamic>> itemListInfos,
    List<Map<String, dynamic>>? invCheckInfos,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/system/terminal/commitASWHDownShelves',
      data: {
        'downShelvesInfos': downShelvesInfos,
        'itemListInfos': itemListInfos,
        'invCheckInfos': invCheckInfos ?? <Map<String, dynamic>>[],
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

  Future<void> commitWcsCommand(AsrsWcsCommandPayload payload) async {
    final endpoint = () {
      switch (payload.type) {
        case AsrsCommandType.normal:
          return '/system/terminal/commitDownWmsToWcs';
        case AsrsCommandType.inventory:
          return '/system/terminal/commitInvDownWmsToWcs';
        case AsrsCommandType.empty:
          return '/system/terminal/commitEmptyTrayWmsToWcs';
      }
    }();

    final response = await _dio.get<Map<String, dynamic>>(
      endpoint,
      queryParameters: {
        'taskId': payload.taskId,
        'taskNo': payload.taskNo,
        'trayNo': payload.trayNo,
        'startAddr': payload.startAddress,
        'endAddr': payload.endAddress,
        'singleFlag': payload.singleFlag,
      },
    );

    ApiResponseHandler.handleResponse(
      response: response,
      dataExtractor: (raw) => raw,
    );
  }

  Future<List<AsrsLocation>> fetchInOutLocations(String locationType) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/getInOutLocation',
      queryParameters: {
        'locationType': locationType,
      },
    );

    final data = ApiResponseHandler.handleResponse<List<dynamic>>(
      response: response,
      dataExtractor: (raw) {
        if (raw is List) return raw;
        if (raw is Map && raw['rows'] is List) {
          return raw['rows'] as List;
        }
        throw Exception('站点地址响应格式不正确');
      },
    );

    return data
        .map((e) => AsrsLocation.fromJson(
              Map<String, dynamic>.from(e as Map<dynamic, dynamic>),
            ))
        .toList();
  }

  Future<List<AsrsLocation>> fetchPalletSites(String taskNo) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/getPalletSiteNo',
      queryParameters: {
        'taskNo': taskNo,
      },
    );

    final data = ApiResponseHandler.handleResponse<List<dynamic>>(
      response: response,
      dataExtractor: (raw) {
        if (raw is List) return raw;
        if (raw is Map && raw['rows'] is List) {
          return raw['rows'] as List;
        }
        throw Exception('托盘口响应格式不正确');
      },
    );

    return data
        .map((e) => AsrsLocation.fromJson(
              Map<String, dynamic>.from(e as Map<dynamic, dynamic>),
            ))
        .toList();
  }
}
