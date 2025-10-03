import 'package:dio/dio.dart';
import 'package:wms_app/modules/arrival/collection_task/models/arrival_collection_models.dart';
import 'package:wms_app/modules/arrival/task_details/models/arrival_task_detail.dart';
import 'package:wms_app/modules/arrival/task_list/models/arrival_task.dart';
import 'package:wms_app/modules/floor_inbound/collection_task/models/inbound_collection_models.dart';
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

  /// 扫码查询物料信息
  Future<InboundBarcodeContent> getMaterialInfo(String barcode) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/materialInfo',
      queryParameters: {'QRstring': barcode},
    );

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw Exception('物料条码识别失败');
    }
    if (data['code'] != 200 || data['data'] == null) {
      throw Exception(data['msg']?.toString() ?? '物料条码识别失败');
    }

    return InboundBarcodeContent.fromJson(
      Map<String, dynamic>.from(data['data'] as Map<dynamic, dynamic>),
    );
  }

  /// 提交到货采集结果
  Future<void> submitArrivalCollection({
    required ArrivalTask task,
    required List<ArrivalCollectionRecord> records,
    required List<ArrivalTaskDetail> details,
    required Map<String, double> initialCollected,
  }) async {
    final upShelvesInfos = records
        .map((record) => {
              'taskNo': record.arrivalsBillId,
              'matCode': record.materialCode,
              'batchNo': record.batchNo,
              'sn': record.serialNo,
              'taskQty': record.taskQty,
              'collectQty': record.quantity,
              'storeRoomNo': record.storeRoom,
              'storeSiteNo': '',
              'taskid': record.arrivalsBillId,
              'inTaskItemid': record.detailId,
              'matchingFlg': record.collectFlag,
              if (record.productionDate != null)
                'data1': _formatDate(record.productionDate!),
              if (record.validDays != null) 'data2': record.validDays,
            })
        .toList();

    final itemListInfos = details
        .map((detail) => {
              'inTaskItemid': detail.detailId,
              'mtlCode': detail.materialCode,
              'mtlQty': [
                initialCollected[detail.detailId] ?? detail.collectedQty,
                detail.collectedQty,
              ],
            })
        .toList();

    final response = await _dio.post<Map<String, dynamic>>(
      '/system/terminal/commitSign',
      data: {
        'upShelvesInfos': upShelvesInfos,
        'itemListInfos': itemListInfos,
        'filter': '',
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

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
