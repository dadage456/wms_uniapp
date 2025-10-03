import 'package:dio/dio.dart';
import 'package:wms_app/modules/floor_transfer/models/transfer_models.dart';
import 'package:wms_app/modules/outbound/collection_task/models/collection_models.dart';
import 'package:wms_app/services/api_response_handler.dart';

class FloorTransferService {
  FloorTransferService(this._dio);

  final Dio _dio;

  Future<List<StoreSiteInfo>> getStoreSiteByRoom({
    String? storeRoomNo,
    required String storeSiteNo,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/getStoreSite',
      queryParameters: {
        if (storeRoomNo != null && storeRoomNo.isNotEmpty) 'storeRoomNo': storeRoomNo,
        'storeSiteNo': storeSiteNo,
      },
    );

    final data = ApiResponseHandler.handleResponse<List<dynamic>>(
      response: response,
      dataExtractor: (raw) {
        if (raw is List) return raw;
        if (raw is Map && raw['rows'] is List) {
          return raw['rows'] as List;
        }
        throw Exception('库位响应格式不正确');
      },
    );

    return data
        .map((e) => StoreSiteInfo.fromJson(
              Map<String, dynamic>.from(e as Map<dynamic, dynamic>),
            ))
        .toList();
  }

  Future<List<InventoryStock>> getRepertoryByStoresiteNoTransfer(
    String sourceSite,
    String targetSite,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/GetRepertoryByStoresiteNoTransfer',
      queryParameters: {
        'sourceStoresiteNo': sourceSite,
        'targetStoresiteNo': targetSite,
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
        .map((e) => InventoryStock.fromJson(
              Map<String, dynamic>.from(e as Map<dynamic, dynamic>),
            ))
        .toList();
  }

  Future<BarcodeContent> getMaterialInfoByQR(String barcode) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/materialInfo',
      queryParameters: {'QRstring': barcode},
    );

    return ApiResponseHandler.handleResponse(
      response: response,
      dataExtractor: (raw) => BarcodeContent.fromJson(
        Map<String, dynamic>.from(raw as Map<dynamic, dynamic>),
      ),
    );
  }

  Future<InventoryQueryPage> getRepertoryByBarcode({
    required String barcode,
    required String step,
    required int pageIndex,
    required int pageSize,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/getRepertoryByBarCode',
      queryParameters: {
        'barcode': barcode,
        'currStep': step,
        'PageIndex': pageIndex,
        'PageSize': pageSize,
      },
    );

    return ApiResponseHandler.handleResponse(
      response: response,
      dataExtractor: (raw) {
        if (raw is Map<String, dynamic>) {
          return InventoryQueryPage.fromJson(raw, pageIndex, pageSize);
        }
        throw Exception('库存查询响应格式不正确');
      },
    );
  }

  Future<void> commitTransfer(TransferFilterResult payload) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/system/terminal/commitTransfer',
      data: {
        'transferInfos': payload.transferInfos,
        'filter': payload.filter,
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
}
