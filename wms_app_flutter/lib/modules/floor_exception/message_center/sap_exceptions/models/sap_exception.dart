import 'package:equatable/equatable.dart';

class SapExceptionRecord extends Equatable {
  const SapExceptionRecord({
    required this.orderNumber,
    required this.sourceNumber,
    required this.orderType,
    required this.batchId,
    required this.processDate,
    required this.sourceHeaderId,
    required this.processStatus,
    required this.processMessage,
    required this.reserveF1,
    required this.interfaceName,
    required this.jobId,
    required this.orderTypeName,
  });

  factory SapExceptionRecord.fromJson(Map<String, dynamic> json) {
    return SapExceptionRecord(
      orderNumber: json['erp_ORDER_NUMBER']?.toString() ?? '',
      sourceNumber: json['source_NUMBER']?.toString() ?? '',
      orderType: json['order_TYPE']?.toString() ?? '',
      batchId: json['batch_ID']?.toString() ?? '',
      processDate: json['process_DATE']?.toString() ?? '',
      sourceHeaderId: json['source_header_id']?.toString() ?? '',
      processStatus: json['process_STATUS']?.toString() ?? '',
      processMessage: json['process_MESSAGE']?.toString() ?? '',
      reserveF1: json['reserve_F1']?.toString() ?? '',
      interfaceName: json['jkname']?.toString() ?? '',
      jobId: json['txjobid']?.toString() ?? '',
      orderTypeName: json['order_TYPE_NAME']?.toString() ?? '',
    );
  }

  final String orderNumber;
  final String sourceNumber;
  final String orderType;
  final String batchId;
  final String processDate;
  final String sourceHeaderId;
  final String processStatus;
  final String processMessage;
  final String reserveF1;
  final String interfaceName;
  final String jobId;
  final String orderTypeName;

  @override
  List<Object?> get props => [
        orderNumber,
        sourceNumber,
        orderType,
        batchId,
        processDate,
        sourceHeaderId,
        processStatus,
        processMessage,
        reserveF1,
        interfaceName,
        jobId,
        orderTypeName,
      ];
}

class SapExceptionList {
  SapExceptionList({required this.total, required this.rows});

  factory SapExceptionList.fromJson(Map<String, dynamic> json) {
    final rows = (json['rows'] as List<dynamic>? ?? [])
        .map((item) => SapExceptionRecord.fromJson(
              Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
            ))
        .toList();
    final total = json['total'] is int
        ? json['total'] as int
        : int.tryParse(json['total']?.toString() ?? '') ?? rows.length;
    return SapExceptionList(total: total, rows: rows);
  }

  final int total;
  final List<SapExceptionRecord> rows;
}

class SapExceptionQuery extends Equatable {
  const SapExceptionQuery({
    required this.userId,
    required this.roleOrUserId,
    this.searchKey = '',
    this.pageIndex = 1,
    this.pageSize = 100,
  });

  final String userId;
  final String roleOrUserId;
  final String searchKey;
  final int pageIndex;
  final int pageSize;

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'roleoRuserId': roleOrUserId,
      'searchKey': searchKey,
      'PageIndex': pageIndex.toString(),
      'PageSize': pageSize.toString(),
    };
  }

  SapExceptionQuery copyWith({
    String? userId,
    String? roleOrUserId,
    String? searchKey,
    int? pageIndex,
    int? pageSize,
  }) {
    return SapExceptionQuery(
      userId: userId ?? this.userId,
      roleOrUserId: roleOrUserId ?? this.roleOrUserId,
      searchKey: searchKey ?? this.searchKey,
      pageIndex: pageIndex ?? this.pageIndex,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  List<Object?> get props => [userId, roleOrUserId, searchKey, pageIndex, pageSize];
}
