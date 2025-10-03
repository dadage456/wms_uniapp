
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/modules/account/profile/cubit/account_profile_edit_cubit.dart';

class AccountProfileEditPage extends StatefulWidget {
  const AccountProfileEditPage({super.key});

  @override
  State<AccountProfileEditPage> createState() => _AccountProfileEditPageState();
}

class _AccountProfileEditPageState extends State<AccountProfileEditPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nickNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  bool _autoValidate = false;

  @override
  void initState() {
    super.initState();
    final form = context.read<AccountProfileEditCubit>().state.form;
    _nickNameController = TextEditingController(text: form.nickName);
    _phoneController = TextEditingController(text: form.phonenumber ?? '');
    _emailController = TextEditingController(text: form.email ?? '');
  }

  @override
  void dispose() {
    _nickNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('编辑个人信息')),
      body: BlocListener<AccountProfileEditCubit, AccountProfileEditState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage && current.hasError,
        listener: (context, state) {
          if (state.hasError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(state.errorMessage ?? '提交失败')),
              );
          }
        },
        child: BlocBuilder<AccountProfileEditCubit, AccountProfileEditState>(
          builder: (context, state) {
            return Form(
              key: _formKey,
              autovalidateMode: _autoValidate
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _nickNameController,
                    decoration: const InputDecoration(
                      labelText: '用户昵称',
                      hintText: '请输入要展示的昵称',
                    ),
                    maxLength: 20,
                    textInputAction: TextInputAction.next,
                    onChanged: (value) =>
                        context.read<AccountProfileEditCubit>().updateNickName(value),
                    validator: _validateNickName,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: '手机号',
                      hintText: '请输入常用联系方式（可选）',
                    ),
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    onChanged: (value) =>
                        context.read<AccountProfileEditCubit>().updatePhone(value),
                    validator: _validatePhone,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: '邮箱',
                      hintText: '请输入常用邮箱（可选）',
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onChanged: (value) =>
                        context.read<AccountProfileEditCubit>().updateEmail(value),
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: '性别'),
                    value: state.form.sex?.isEmpty ?? true ? null : state.form.sex,
                    items: const [
                      DropdownMenuItem(value: '0', child: Text('男')),
                      DropdownMenuItem(value: '1', child: Text('女')),
                      DropdownMenuItem(value: '2', child: Text('未知')),
                    ],
                    onChanged: (value) =>
                        context.read<AccountProfileEditCubit>().updateSex(value),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    icon: state.saving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    onPressed: state.saving
                        ? null
                        : () => _handleSubmit(context),
                    label: const Text('保存'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _handleSubmit(BuildContext context) async {
    setState(() => _autoValidate = true);
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    final result = await context.read<AccountProfileEditCubit>().submit();
    if (!mounted) return;
    if (result != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('个人信息已更新')));
      Navigator.of(context).pop(true);
    }
  }

  String? _validateNickName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '请输入昵称';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return null;
    if (trimmed.length < 6 || trimmed.length > 15) {
      return '请输入6-15位数字';
    }
    for (final codeUnit in trimmed.codeUnits) {
      if (codeUnit < 48 || codeUnit > 57) {
        return '请输入6-15位数字';
      }
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return null;
    final atIndex = trimmed.indexOf('@');
    if (atIndex <= 0 || atIndex == trimmed.length - 1) {
      return '邮箱格式不正确';
    }
    final dotIndex = trimmed.indexOf('.', atIndex);
    if (dotIndex <= atIndex + 1 || dotIndex == trimmed.length - 1) {
      return '邮箱格式不正确';
    }
    return null;
  }
}
