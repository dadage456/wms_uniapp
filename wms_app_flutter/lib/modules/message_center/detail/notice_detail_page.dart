import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:wms_app/common_widgets/custom_app_bar.dart';
import 'package:wms_app/modules/message_center/detail/bloc/notice_detail_cubit.dart';
import 'package:wms_app/modules/message_center/models/notice.dart';

class NoticeDetailPage extends StatelessWidget {
  const NoticeDetailPage({
    super.key,
    required this.noticeId,
    this.initialTitle,
  });

  final String? noticeId;
  final String? initialTitle;

  @override
  Widget build(BuildContext context) {
    final bloc = BlocProvider.of<NoticeDetailCubit>(context);

    final title = initialTitle ?? '公告详情';
    return Scaffold(
      appBar: CustomAppBar(title: title, onBackPressed: Modular.to.pop).appBar,
      body: BlocBuilder<NoticeDetailCubit, NoticeDetailState>(
        builder: (context, state) {
          switch (state.status) {
            case NoticeDetailStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case NoticeDetailStatus.failure:
              return _ErrorView(
                message: state.errorMessage ?? '公告详情获取失败',
                onRetry: () => bloc.loadNotice(noticeId),
              );
            case NoticeDetailStatus.success:
              final detail = state.detail;
              if (detail == null) {
                return const _ErrorView(message: '公告详情为空');
              }
              return _DetailContent(detail: detail);
            case NoticeDetailStatus.initial:
              return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.detail});

  final NoticeDetail detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            detail.noticeTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if ((detail.nickName ?? '').isNotEmpty)
                Flexible(
                  child: Text(
                    detail.nickName!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              if ((detail.nickName ?? '').isNotEmpty) const SizedBox(width: 12),
              if ((detail.createTime ?? '').isNotEmpty)
                Text(
                  detail.createTime!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          SelectableText(
            _normalizeContent(detail.noticeContent),
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
              color: const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  String _normalizeContent(String content) {
    var text = content
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n')
        .replaceAll(RegExp(r'<li>', caseSensitive: false), '• ')
        .replaceAll(RegExp(r'</li>', caseSensitive: false), '\n');
    text = text.replaceAll(RegExp(r'<[^>]+>'), '');
    return text.trim();
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 52),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, fontSize: 16),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(onPressed: onRetry, child: const Text('重新加载')),
            ],
          ],
        ),
      ),
    );
  }
}
