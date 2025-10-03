import 'package:dio/dio.dart';
import 'package:wms_app/modules/floor_inbound/task_details/models/inbound_task_item.dart';
import 'package:wms_app/modules/floor_inbound/task_list/models/inbound_task.dart';
import 'package:wms_app/modules/outbound/task_details/models/commit_task_item_result.dart';
import 'package:wms_app/modules/floor_inbound/collection_task/models/inbound_collection_models.dart';
import 'package:wms_app/services/api_response_handler.dart';

class FloorInboundService {
  FloorInboundService(this._dio);

  final Dio _dio;

  Future<InboundTaskListData> getTaskList(InboundTaskQuery query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/intaskList',
      queryParameters: query.toJson(),
    );
    return ApiResponseHandler.handleResponse(
      response: response,
      dataExtractor: (data) => InboundTaskListData.fromJson(data),
    );
  }

  Future<InboundTaskItemListData> getTaskItems(InboundTaskItemQuery query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/intaskitemList',
      queryParameters: query.toJson(),
    );
    return ApiResponseHandler.handleResponse(
      response: response,
      dataExtractor: (data) => InboundTaskItemListData.fromJson(data),
    );
  }

  Future<CommitTaskItemResult> commitTaskItems({
    required List<String> taskItemIds,
    String roomTag = '0',
    bool isCancel = false,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/system/terminal/commitRCInTaskItem',
      data: {
        'intaskitemids': taskItemIds,
        'roomTag': roomTag,
        'isCanel': isCancel.toString(),
      },
      options: Options(headers: {'content-type': 'application/json;charset=UTF-8'}),
    );
    return ApiResponseHandler.handleResponse(
      response: response,
      dataExtractor: (data) =>
          CommitTaskItemResult.fromJson(Map<String, dynamic>.from(data as Map)),
    );
  }

  Future<Map<String, dynamic>> getStoreSite({
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

    return response.data ?? <String, dynamic>{};
  }

  Future<Map<String, dynamic>> getInventoryBySite({
    required String storeSite,
    required String matCode,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/getMtlRepertory',
      queryParameters: {
        'storeSite': storeSite,
        'matCode': matCode,
      },
    );

    return response.data ?? <String, dynamic>{};
  }

  Future<InboundBarcodeContent> getMaterialInfo(String qrContent) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/system/terminal/getPmMaterialInfoByQR',
      data: {'qrContent': qrContent},
    );
    return ApiResponseHandler.handleResponse(
      response: response,
      dataExtractor: (data) => InboundBarcodeContent.fromJson(
        Map<String, dynamic>.from(data as Map),
      ),
    );
  }

  Future<void> submitCollection({
    required List<Map<String, dynamic>> upShelvesInfos,
    required List<Map<String, dynamic>> itemListInfos,
    required String serialFilter,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/system/terminal/commitUp',
      data: {
        'upShelvesInfos': upShelvesInfos,
        'itemListInfos': itemListInfos,
        'filter': serialFilter,
      },
      options: Options(headers: {'content-type': 'application/json;charset=UTF-8'}),
    );

    ApiResponseHandler.handleResponse(
      response: response,
      dataExtractor: (data) => data,
    );
  }

  Future<List<InboundTaskItem>> getCollectionDetail(
    InboundCollectionQuery query,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/intaskitemList',
      queryParameters: query.toJson(),
    );

    return ApiResponseHandler.handleResponse(
      response: response,
      dataExtractor: (data) {
        if (data is Map<String, dynamic>) {
          final rows = data['rows'] as List<dynamic>? ?? const [];
          return rows
              .map((e) => InboundTaskItem.fromJson(
                  Map<String, dynamic>.from(e as Map<dynamic, dynamic>)))
              .toList();
        }

        if (data is List) {
          return data
              .map((e) => InboundTaskItem.fromJson(
                  Map<String, dynamic>.from(e as Map<dynamic, dynamic>)))
              .toList();
        }

        return const <InboundTaskItem>[];
      },
    );
  }
}
