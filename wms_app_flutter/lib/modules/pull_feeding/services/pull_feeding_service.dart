import 'package:dio/dio.dart';
import 'package:wms_app/modules/pull_feeding/models/pull_feeding_models.dart';
import 'package:wms_app/services/api_response_handler.dart';

class PullFeedingService {
  PullFeedingService(this._dio);

  final Dio _dio;

  Future<PullFeedingBarcodeContent> getMaterialInfo(String qrContent) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/system/terminal/getPmMaterialInfoByQR',
      data: {'qrContent': qrContent},
    );
    return ApiResponseHandler.handleResponse(
      response: response,
      dataExtractor: (data) => PullFeedingBarcodeContent.fromJson(
        Map<String, dynamic>.from(data as Map),
      ),
    );
  }

  Future<double> getInventoryQuantity({
    required String storeSite,
    required String materialCode,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/getLSMtlRepertoryByStoresiteNo',
      queryParameters: {
        'storeSite': storeSite,
        'matCode': materialCode,
      },
    );

    return ApiResponseHandler.handleResponse(
      response: response,
      dataExtractor: (data) {
        if (data is List) {
          if (data.isEmpty) return 0;
          final first = Map<String, dynamic>.from(data.first as Map);
          return double.tryParse(first['repqty']?.toString() ?? '') ?? 0;
        }
        if (data is Map<String, dynamic>) {
          final rows = data['rows'];
          if (rows is List && rows.isNotEmpty) {
            final first = Map<String, dynamic>.from(rows.first as Map);
            return double.tryParse(first['repqty']?.toString() ?? '') ?? 0;
          }
          return double.tryParse(data['repqty']?.toString() ?? '') ?? 0;
        }
        return 0;
      },
    );
  }

  Future<PullFeedingQuantityRule> getQuantityRule({
    required String materialCode,
    required String storeSite,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/getMtlQtyByMtlCode',
      queryParameters: {
        'mtlCode': materialCode,
        'siteNo': storeSite,
      },
    );

    return ApiResponseHandler.handleResponse(
      response: response,
      dataExtractor: (data) {
        if (data is List && data.isNotEmpty) {
          return PullFeedingQuantityRule.fromJson(
            Map<String, dynamic>.from(data.first as Map),
          );
        }
        if (data is Map<String, dynamic>) {
          return PullFeedingQuantityRule.fromJson(
            Map<String, dynamic>.from(data),
          );
        }
        return const PullFeedingQuantityRule();
      },
    );
  }

  Future<void> submit(List<PullFeedingRecord> records) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/system/terminal/commitMtlSender',
      data: {
        'mtlSenderInfos': records.map((e) => e.toJson()).toList(),
      },
      options: Options(headers: {'content-type': 'application/json;charset=UTF-8'}),
    );

    ApiResponseHandler.handleResponse(
      response: response,
      dataExtractor: (data) => data,
    );
  }
}
