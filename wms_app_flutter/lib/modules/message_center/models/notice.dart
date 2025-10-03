class NoticeSummary {
  NoticeSummary({
    required this.noticeId,
    required this.noticeTitle,
    required this.createBy,
    required this.createDate,
    this.isRead = false,
  });

  final String noticeId;
  final String noticeTitle;
  final String? createBy;
  final String? createDate;
  final bool isRead;

  factory NoticeSummary.fromJson(Map<String, dynamic> json) => NoticeSummary(
        noticeId: json['noticeId']?.toString() ?? '',
        noticeTitle: json['noticeTitle']?.toString() ?? '',
        createBy: json['createBy']?.toString(),
        createDate: (json['createDate'] ?? json['createTime'])?.toString(),
      );

  NoticeSummary copyWith({bool? isRead}) => NoticeSummary(
        noticeId: noticeId,
        noticeTitle: noticeTitle,
        createBy: createBy,
        createDate: createDate,
        isRead: isRead ?? this.isRead,
      );
}

class NoticeDetail {
  NoticeDetail({
    required this.noticeId,
    required this.noticeTitle,
    required this.noticeContent,
    this.nickName,
    this.createTime,
  });

  final String noticeId;
  final String noticeTitle;
  final String noticeContent;
  final String? nickName;
  final String? createTime;

  factory NoticeDetail.fromJson(Map<String, dynamic> json) => NoticeDetail(
        noticeId: json['noticeId']?.toString() ?? '',
        noticeTitle: json['noticeTitle']?.toString() ?? '',
        noticeContent: json['noticeContent']?.toString() ?? '',
        nickName: json['nickName']?.toString(),
        createTime: (json['createTime'] ?? json['createDate'])?.toString(),
      );
}
