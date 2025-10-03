
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wms_app/modules/account/password/cubit/change_password_cubit.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _oldController = TextEditingController();
  final TextEditingController _newController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _autoValidate = false;
  bool _showOld = false;
  bool _showNew = false;
  bool _showConfirm = false;

  @override
  void dispose() {
    _oldController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('修改密码')),
      body: BlocListener<ChangePasswordCubit, ChangePasswordState>(
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
        child: BlocBuilder<ChangePasswordCubit, ChangePasswordState>(
          builder: (context, state) {
            return Form(
              key: _formKey,
              autovalidateMode: _autoValidate
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _PasswordField(
                    controller: _oldController,
                    label: '原密码',
                    hint: '请输入当前密码',
                    obscureText: !_showOld,
                    toggleVisibility: () =>
                        setState(() => _showOld = !_showOld),
                    validator: (value) =>
                        value == null || value.isEmpty ? '请输入原密码' : null,
                    onChanged: (value) =>
                        context.read<ChangePasswordCubit>().updateOldPassword(value),
                  ),
                  const SizedBox(height: 12),
                  _PasswordField(
                    controller: _newController,
                    label: '新密码',
                    hint: '请输入新的登录密码',
                    obscureText: !_showNew,
                    toggleVisibility: () =>
                        setState(() => _showNew = !_showNew),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入新密码';
                      }
                      if (value.length < 6) {
                        return '新密码至少6位';
                      }
                      return null;
                    },
                    onChanged: (value) =>
                        context.read<ChangePasswordCubit>().updateNewPassword(value),
                  ),
                  const SizedBox(height: 12),
                  _PasswordField(
                    controller: _confirmController,
                    label: '确认新密码',
                    hint: '请再次输入新密码',
                    obscureText: !_showConfirm,
                    toggleVisibility: () =>
                        setState(() => _showConfirm = !_showConfirm),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请再次输入新密码';
                      }
                      if (value != _newController.text) {
                        return '两次输入不一致';
                      }
                      return null;
                    },
                    onChanged: (value) => context
                        .read<ChangePasswordCubit>()
                        .updateConfirmPassword(value),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    icon: state.submitting
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.lock_reset_outlined),
                    onPressed: state.submitting
                        ? null
                        : () => _handleSubmit(context),
                    label: const Text('确认修改'),
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

    final success = await context.read<ChangePasswordCubit>().submit();
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('密码修改成功')));
      Navigator.of(context).pop(true);
    }
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.obscureText,
    required this.toggleVisibility,
    required this.validator,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool obscureText;
  final VoidCallback toggleVisibility;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
          onPressed: toggleVisibility,
        ),
      ),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
