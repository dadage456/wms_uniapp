import 'package:equatable/equatable.dart';

class ExceptionTaskMessage extends Equatable {
  const ExceptionTaskMessage({
    required this.messageId,
    required this.messageType,
    required this.messageStatus,
    required this.messageTitle,
    required this.messageContent,
    required this.createTime,
    required this.receiveTime,
  });

  factory ExceptionTaskMessage.fromJson(Map<String, dynamic> json) {
    return ExceptionTaskMessage(
      messageId: json['messageId']?.toString() ?? '',
      messageType: json['messageType']?.toString() ?? '',
      messageStatus: json['messageStatus']?.toString() ?? '',
      messageTitle: json['messageTitle']?.toString() ?? '',
      messageContent: json['messageConcent']?.toString() ?? '',
      createTime: json['createTime']?.toString() ?? '',
      receiveTime: json['receiveTime']?.toString() ?? '',
    );
  }

  final String messageId;
  final String messageType;
  final String messageStatus;
  final String messageTitle;
  final String messageContent;
  final String createTime;
  final String receiveTime;

  @override
  List<Object?> get props => [
        messageId,
        messageType,
        messageStatus,
        messageTitle,
        messageContent,
        createTime,
        receiveTime,
      ];
}

class ExceptionTaskMessageList {
  ExceptionTaskMessageList({required this.total, required this.rows});

  factory ExceptionTaskMessageList.fromJson(Map<String, dynamic> json) {
    final rows = (json['rows'] as List<dynamic>? ?? [])
        .map((item) => ExceptionTaskMessage.fromJson(
              Map<String, dynamic>.from(item as Map<dynamic, dynamic>),
            ))
        .toList();
    final total = json['total'] is int
        ? json['total'] as int
        : int.tryParse(json['total']?.toString() ?? '') ?? rows.length;
    return ExceptionTaskMessageList(total: total, rows: rows);
  }

  final int total;
  final List<ExceptionTaskMessage> rows;
}

class ExceptionTaskMessageQuery extends Equatable {
  const ExceptionTaskMessageQuery({
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

  ExceptionTaskMessageQuery copyWith({
    String? userId,
    String? roleOrUserId,
    String? searchKey,
    int? pageIndex,
    int? pageSize,
  }) {
    return ExceptionTaskMessageQuery(
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
