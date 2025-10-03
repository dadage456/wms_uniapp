import 'package:dio/dio.dart';
import 'package:wms_app/modules/message_center/models/notice.dart';
import 'package:wms_app/services/api_response_handler.dart';

class MessageCenterService {
  MessageCenterService(this._dio);

  final Dio _dio;

  Future<List<NoticeSummary>> fetchNotices() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/getMorNotice',
    );

    return ApiResponseHandler.handleResponse(
      response: response,
      dataExtractor: (data) {
        if (data is List) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(NoticeSummary.fromJson)
              .toList();
        }

        if (data is Map<String, dynamic>) {
          final rows = data['rows'];
          if (rows is List) {
            return rows
                .whereType<Map<String, dynamic>>()
                .map(NoticeSummary.fromJson)
                .toList();
          }
        }

        throw Exception('公告数据格式不正确');
      },
    );
  }

  Future<NoticeDetail> fetchNoticeDetail(String noticeId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/system/terminal/getNoticeDetail',
      queryParameters: {'noticeId': noticeId},
    );

    return ApiResponseHandler.handleResponse(
      response: response,
      dataExtractor: (data) {
        if (data is Map<String, dynamic>) {
          return NoticeDetail.fromJson(data);
        }
        throw Exception('公告详情格式不正确');
      },
    );
  }
}
