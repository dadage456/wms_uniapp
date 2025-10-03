import 'package:dio/dio.dart';
import 'package:wms_app/modules/floor_exception/exception_task_list/models/exception_task.dart';
import 'package:wms_app/modules/floor_exception/message_center/sap_exceptions/models/sap_exception.dart';
import 'package:wms_app/modules/floor_exception/message_center/task_messages/models/exception_task_message.dart';
import 'package:wms_app/modules/outbound/collection_task/models/collection_models.dart';
import 'package:wms_app/services/api_response_handler.dart';

class FloorExceptionService {
  FloorExceptionService(this._dio);

  final Dio _dio;

  Future<ExceptionTaskListData> getExceptionTasks(ExceptionTaskQuery query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/selectPdaCollExceptList',
      queryParameters: query.toJson(),
    );

    return ApiResponseHandler.handleResponse(
      response: response,
      dataExtractor: (data) => ExceptionTaskListData.fromJson(
        Map<String, dynamic>.from(data as Map<dynamic, dynamic>),
      ),
    );
  }

  Future<void> reprocessException(String dcConnectId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/reprocessDconnect',
      queryParameters: {'dcConnectid': dcConnectId},
    );

    ApiResponseHandler.handleResponse(
      response: response,
      dataExtractor: (data) => data,
    );
  }

  Future<ExceptionTaskMessageList> getTaskMessages(
    ExceptionTaskMessageQuery query,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/selectTaskMessageList',
      queryParameters: query.toJson(),
    );

    return ApiResponseHandler.handleResponse(
      response: response,
      dataExtractor: (data) => ExceptionTaskMessageList.fromJson(
        Map<String, dynamic>.from(data as Map<dynamic, dynamic>),
      ),
    );
  }

  Future<void> confirmTaskMessage(String messageId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/messageConfim',
      queryParameters: {'messageId': messageId},
    );

    ApiResponseHandler.handleResponse(
      response: response,
      dataExtractor: (data) => data,
    );
  }

  Future<SapExceptionList> getSapExceptions(SapExceptionQuery query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/selectSapInteExceptList',
      queryParameters: query.toJson(),
    );

    return ApiResponseHandler.handleResponse(
      response: response,
      dataExtractor: (data) => SapExceptionList.fromJson(
        Map<String, dynamic>.from(data as Map<dynamic, dynamic>),
      ),
    );
  }

  Future<BarcodeContent> getMaterialInfoByQR(String barcode) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/materialInfo',
      queryParameters: {'QRstring': barcode},
    );

    return ApiResponseHandler.handleResponse(
      response: response,
      dataExtractor: (data) => BarcodeContent.fromJson(
        Map<String, dynamic>.from(data as Map<dynamic, dynamic>),
      ),
    );
  }

  Future<String?> getPalletStoreSite(String trayNo) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/getPalletSiteNo',
      queryParameters: {'taskNo': trayNo},
    );

    final sites = ApiResponseHandler.handleResponse(
      response: response,
      dataExtractor: (data) => data,
    );

    if (sites is List && sites.isNotEmpty) {
      final first = sites.first;
      if (first is Map<String, dynamic>) {
        final site = first['storesiteno'] ?? first['storeSiteNo'];
        if (site != null && site.toString().isNotEmpty) {
          return site.toString();
        }
      }
    }

    return null;
  }

  Future<void> commitExceptionShelves(
    List<Map<String, dynamic>> exceptionInfos,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/system/terminal/commitExceptShelves',
      data: {'exceptShelvesInfos': exceptionInfos},
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
