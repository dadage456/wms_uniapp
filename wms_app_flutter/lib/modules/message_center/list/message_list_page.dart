import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:wms_app/common_widgets/custom_app_bar.dart';
import 'package:wms_app/modules/message_center/list/bloc/message_list_bloc.dart';
import 'package:wms_app/modules/message_center/list/bloc/message_list_event.dart';
import 'package:wms_app/modules/message_center/list/bloc/message_list_state.dart';
import 'package:wms_app/modules/message_center/models/notice.dart';

class MessageListPage extends StatelessWidget {
  const MessageListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '通知列表',
        onBackPressed: Modular.to.pop,
      ).appBar,
      body: BlocConsumer<MessageListBloc, MessageListState>(
        listener: (context, state) {
          if (state.status == MessageListStatus.failure && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          final isInitialLoading =
              state.status == MessageListStatus.loading && state.notices.isEmpty;
          if (isInitialLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final isFailureWithoutData =
              state.status == MessageListStatus.failure && state.notices.isEmpty;
          if (isFailureWithoutData) {
            return _ErrorView(
              message: state.errorMessage ?? '公告获取失败',
              onRetry: () => context
                  .read<MessageListBloc>()
                  .add(const MessageListSubscriptionRequested()),
            );
          }

          final listView = state.notices.isEmpty
              ? const _EmptyView()
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemBuilder: (context, index) =>
                      _NoticeTile(notice: state.notices[index]),
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemCount: state.notices.length,
                );

          return RefreshIndicator(
            onRefresh: () async {
              final bloc = context.read<MessageListBloc>();
              bloc.add(const MessageListRefreshRequested());
              await bloc.stream.firstWhere(
                (next) => next.status != MessageListStatus.loading,
              );
            },
            child: listView,
          );
        },
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 120),
        Icon(Icons.notifications_none, size: 64, color: Colors.grey),
        SizedBox(height: 16),
        Center(
          child: Text(
            '暂无公告',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

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
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('重新加载'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoticeTile extends StatelessWidget {
  const _NoticeTile({required this.notice});

  final NoticeSummary notice;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      title: Text(
        notice.noticeTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 16,
          fontWeight: notice.isRead ? FontWeight.w400 : FontWeight.w600,
          color: notice.isRead ? const Color(0xFF6B7280) : const Color(0xFF111827),
        ),
      ),
      subtitle: Row(
        children: [
          if ((notice.createBy ?? '').isNotEmpty)
            Expanded(
              child: Text(
                notice.createBy!,
                style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if ((notice.createBy ?? '').isNotEmpty) const SizedBox(width: 8),
          if ((notice.createDate ?? '').isNotEmpty)
            Text(
              notice.createDate!,
              style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
            ),
        ],
      ),
      leading: notice.isRead
          ? const Icon(Icons.mark_email_read, color: Color(0xFF9CA3AF))
          : const Icon(Icons.markunread, color: Color(0xFF2563EB)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        context
            .read<MessageListBloc>()
            .add(MessageListMarkAsReadRequested(notice.noticeId));
        Modular.to.pushNamed(
          '/message-center/detail',
          arguments: {'noticeId': notice.noticeId, 'title': notice.noticeTitle},
        );
      },
    );
  }
}
