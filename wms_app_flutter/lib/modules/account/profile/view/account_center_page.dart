import 'package:characters/characters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:wms_app/modules/account/models/account_profile.dart';
import 'package:wms_app/modules/account/profile/cubit/account_profile_cubit.dart';
import 'package:wms_app/services/api_service.dart';

class AccountCenterPage extends StatelessWidget {
  const AccountCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('个人中心')),
      body: BlocConsumer<AccountProfileCubit, AccountProfileState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage && current.hasError,
        listener: (context, state) {
          if (state.hasError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(state.errorMessage ?? '加载失败')),
              );
          }
        },
        builder: (context, state) {
          if (state.loading && !state.ready) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!state.ready) {
            return _EmptyState(onRetry: () {
              context.read<AccountProfileCubit>().loadProfile();
            });
          }

          final profile = state.profile!;

          return RefreshIndicator(
            onRefresh: () =>
                context.read<AccountProfileCubit>().loadProfile(refresh: true),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _ProfileHeader(profile: profile),
                const SizedBox(height: 24),
                _InfoSection(profile: profile),
                const SizedBox(height: 24),
                _ActionList(profile: profile),
                if (state.refreshing)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final AccountProfile profile;

  @override
  Widget build(BuildContext context) {
    final displayName = profile.user.nickName.isNotEmpty
        ? profile.user.nickName
        : profile.user.userName;
    final initial = displayName.isNotEmpty ? displayName.characters.first : '?';

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                initial.toUpperCase(),
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text('账号：${profile.user.userName}'),
                  if ((profile.user.deptName ?? '').isNotEmpty)
                    Text('部门：${profile.user.deptName}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({required this.profile});

  final AccountProfile profile;

  @override
  Widget build(BuildContext context) {
    final rows = [
      _InfoRow(icon: Icons.badge_outlined, label: '角色', value: profile.roleGroup),
      _InfoRow(icon: Icons.work_outline, label: '岗位', value: profile.postGroup),
      _InfoRow(
        icon: Icons.phone_iphone,
        label: '手机号',
        value: profile.user.phonenumber ?? '未设置',
      ),
      _InfoRow(
        icon: Icons.email_outlined,
        label: '邮箱',
        value: profile.user.email ?? '未设置',
      ),
      _InfoRow(
        icon: Icons.wc_outlined,
        label: '性别',
        value: _sexLabel(profile.user.sex),
      ),
    ];

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(children: rows),
    );
  }

  String _sexLabel(String? sex) {
    switch (sex) {
      case '0':
        return '男';
      case '1':
        return '女';
      case '2':
        return '未知';
      default:
        return '未设置';
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: Text(value),
      dense: true,
    );
  }
}

class _ActionList extends StatelessWidget {
  const _ActionList({required this.profile});

  final AccountProfile profile;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('编辑个人信息'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final success = await Modular.to.pushNamed<bool>(
                '/account/edit',
                arguments: profile,
              );
              if (success == true && context.mounted) {
                await context
                    .read<AccountProfileCubit>()
                    .loadProfile(refresh: true);
              }
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.lock_reset_outlined),
            title: const Text('修改密码'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Modular.to.pushNamed('/account/change-password'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('退出登录'),
            onTap: () => _confirmLogout(context),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出当前账号吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('退出'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await Modular.get<ApiService>().logout();
      if (context.mounted) {
        Modular.to.navigate('/login');
      }
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person_off_outlined, size: 48),
          const SizedBox(height: 12),
          const Text('暂未获取到个人信息'),
          const SizedBox(height: 20),
          FilledButton(onPressed: onRetry, child: const Text('重新加载')),
        ],
      ),
    );
  }
}
