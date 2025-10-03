import 'package:dio/dio.dart';
import 'package:wms_app/modules/arrival/task_details/models/arrival_task_detail.dart';
import 'package:wms_app/modules/arrival/task_list/models/arrival_task.dart';
import 'package:wms_app/services/api_response_handler.dart';

/// 到货接收相关接口封装
class ArrivalService {
  ArrivalService(this._dio);

  final Dio _dio;

  /// 已接收待完成单据列表
  Future<ArrivalTaskListData> getReceivedTasks(ArrivalTaskQuery query) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/arriveSignList',
      queryParameters: query.toJson(),
    );

    return ApiResponseHandler.handleResponse(
      response: response,
      dataExtractor: (data) => ArrivalTaskListData.fromJson(
        Map<String, dynamic>.from(data as Map<dynamic, dynamic>),
      ),
    );
  }

  /// 待接收单据列表
  Future<ArrivalTaskListData> getPendingReceiveTasks(
    ArrivalTaskQuery query,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/arriveUnSignList',
      queryParameters: query.toJson(),
    );

    return ApiResponseHandler.handleResponse(
      response: response,
      dataExtractor: (data) => ArrivalTaskListData.fromJson(
        Map<String, dynamic>.from(data as Map<dynamic, dynamic>),
      ),
    );
  }

  /// 撤销已接收单据
  Future<void> cancelArrivalTask(String arrivalsBillId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/cancleArriveSign',
      queryParameters: {'arrivalsBillid': arrivalsBillId},
    );

    ApiResponseHandler.handleResponse(
      response: response,
      dataExtractor: (data) => data,
    );
  }

  /// 接收到货单据
  Future<void> receiveArrivalTask(String arrivalsBillId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/receArriveSign',
      queryParameters: {'arrivalsBillid': arrivalsBillId},
    );

    ApiResponseHandler.handleResponse(
      response: response,
      dataExtractor: (data) => data,
    );
  }

  /// 查询到货单明细
  Future<ArrivalTaskDetailListData> getArrivalDetails(
    ArrivalTaskDetailQuery query,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/arriveSignDetailList',
      queryParameters: query.toJson(),
    );

    return ApiResponseHandler.handleResponse(
      response: response,
      dataExtractor: (data) => ArrivalTaskDetailListData.fromJson(
        Map<String, dynamic>.from(data as Map<dynamic, dynamic>),
      ),
    );
  }
}
