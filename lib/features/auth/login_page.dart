import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../auth/firebase_auth/auth_util.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _signingUp = false; // false=登录, true=注册
  bool _pwdVisible = false;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _doEmailAction() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    User? user;
    if (_signingUp) {
      user = await authService.signUpWithEmail(
        context,
        email: _email.text,
        password: _password.text,
      );
    } else {
      user = await authService.signInWithEmail(
        context,
        email: _email.text,
        password: _password.text,
      );
    }
    setState(() => _busy = false);
    if (mounted && user != null) {
      // 交给 main.dart 的 StreamBuilder 跳转；这里可选手动 pop
    }
  }

  Future<void> _doGoogle() async {
    setState(() => _busy = true);
    final user = await authService.signInWithGoogle(context);
    setState(() => _busy = false);
    if (mounted && user != null) {
      // 同上
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _signingUp ? 'Create account' : 'Sign in';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: AutofillGroup(
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    ToggleButtons(
                      isSelected: [_signingUp, !_signingUp],
                      onPressed: (i) => setState(() => _signingUp = (i == 0)),
                      borderRadius: BorderRadius.circular(8),
                      children: const [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('Sign up'),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('Sign in'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _email,
                      autofillHints: const [AutofillHints.username, AutofillHints.email],
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                      (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _password,
                      obscureText: !_pwdVisible,
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _pwdVisible = !_pwdVisible),
                          icon: Icon(_pwdVisible ? Icons.visibility_off : Icons.visibility),
                        ),
                      ),
                      validator: (v) =>
                      (v == null || v.length < 6) ? 'At least 6 characters' : null,
                    ),
                    if (_signingUp) ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _confirm,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Confirm password',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                        (v != _password.text) ? 'Passwords do not match' : null,
                      ),
                    ],
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _busy ? null : _doEmailAction,
                      child: _busy
                          ? const SizedBox(
                          height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(_signingUp ? 'Create account' : 'Sign in'),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _busy
                            ? null
                            : () async {
                          if (_email.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Enter your email first')),
                            );
                            return;
                          }
                          await authService.sendPasswordResetEmail(context, _email.text);
                        },
                        child: const Text('Forgot password?'),
                      ),
                    ),
                    const Divider(height: 32),
                    OutlinedButton.icon(
                      onPressed: _busy ? null : _doGoogle,
                      icon: const Icon(Icons.login),
                      label: const Text('Continue with Google'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
