import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/PrimaryButton.dart';
import '../components/custom_textfield.dart';
import '../utils/constants.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail = '', this.oobCode});

  final String initialEmail;
  final String? oobCode;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isSending = false;
  bool _emailSent = false;
  bool _isResetting = false;
  bool _resetComplete = false;
  String? _resetEmail;
  String? _codeError;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
    if (widget.oobCode != null) _verifyResetCode();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _verifyResetCode() async {
    try {
      final email = await FirebaseAuth.instance.verifyPasswordResetCode(
        widget.oobCode!,
      );
      if (mounted) setState(() => _resetEmail = email);
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _codeError = switch (error.code) {
          'expired-action-code' =>
            'This reset link has expired. Request a new one.',
          'invalid-action-code' =>
            'This reset link is invalid or has already been used.',
          _ =>
            error.message ?? 'This reset link is not valid. Request a new one.',
        };
      });
    } catch (_) {
      if (mounted) {
        setState(
          () =>
              _codeError = 'Could not verify this link. Check your connection.',
        );
      }
    }
  }

  Future<void> _confirmNewPassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isResetting = true);
    try {
      await FirebaseAuth.instance.confirmPasswordReset(
        code: widget.oobCode!,
        newPassword: _passwordController.text,
      );
      if (mounted) setState(() => _resetComplete = true);
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      final message = switch (error.code) {
        'expired-action-code' =>
          'This reset link has expired. Request a new one.',
        'weak-password' => 'Choose a stronger password.',
        'invalid-action-code' =>
          'This reset link is invalid or has already been used.',
        _ =>
          error.message ?? 'Could not reset your password. Please try again.',
      };
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check your internet connection and try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isResetting = false);
    }
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSending = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
        actionCodeSettings: ActionCodeSettings(
          url: 'https://womensafety-4fe3d.firebaseapp.com',
          handleCodeInApp: true,
          androidPackageName: 'com.example.womensafety',
          androidInstallApp: false,
        ),
      );
      if (mounted) setState(() => _emailSent = true);
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      final message = switch (error.code) {
        'invalid-email' => 'Please enter a valid email address.',
        'unauthorized-continue-uri' =>
          'The reset link domain is not authorized in Firebase Console.',
        'missing-android-pkg-name' =>
          'Android app details are missing from Firebase settings.',
        'too-many-requests' => 'Too many attempts. Please try again later.',
        _ =>
          error.message ?? 'Could not send the reset email. Please try again.',
      };
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check your internet connection and try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget content;
    if (widget.oobCode != null) {
      content = _resetPasswordContent();
    } else if (_emailSent) {
      content = _emailSentContent();
    } else {
      content = _sendEmailContent();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
        foregroundColor: kColorRed,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: content,
          ),
        ),
      ),
    );
  }

  Widget _sendEmailContent() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_reset, size: 72, color: kColorRed),
          const SizedBox(height: 20),
          const Text(
            'Reset your password',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'Enter the email address linked to your account. We will send you a password reset link.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          CustomTextField(
            hintText: 'Enter your email',
            keyboardtype: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            prefix: const Icon(Icons.email_outlined),
            controller: _emailController,
            validate: (value) {
              final email = value?.trim() ?? '';
              if (email.isEmpty ||
                  !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                return 'Enter a valid email address.';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          if (_isSending)
            const CircularProgressIndicator()
          else
            PrimaryButton(title: 'SEND RESET LINK', onPressed: _sendResetEmail),
        ],
      ),
    );
  }

  Widget _emailSentContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.mark_email_read_outlined, size: 72, color: kColorRed),
        const SizedBox(height: 20),
        const Text(
          'Check your email',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          'If an account exists for ${_emailController.text.trim()}, HerShield has sent a password reset link. Open it on this device to reset your password in the app.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: () => setState(() => _emailSent = false),
          child: const Text('Try another email'),
        ),
      ],
    );
  }

  Widget _resetPasswordContent() {
    if (_resetComplete) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline, size: 72, color: kColorRed),
          const SizedBox(height: 20),
          const Text(
            'Password updated',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'Your HerShield password has been reset. Return to the app and sign in.',
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Back to login'),
          ),
        ],
      );
    }
    if (_codeError != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.link_off, size: 64, color: kColorRed),
          const SizedBox(height: 16),
          Text(_codeError!, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Back to login'),
          ),
        ],
      );
    }
    if (_resetEmail == null) {
      return const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Verifying reset link…'),
        ],
      );
    }
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_reset, size: 72, color: kColorRed),
          const SizedBox(height: 20),
          const Text(
            'Choose a new password',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Resetting password for $_resetEmail',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CustomTextField(
            hintText: 'New password',
            isPassword: true,
            controller: _passwordController,
            validate: (value) =>
                (value?.length ?? 0) < 6 ? 'Use at least 6 characters.' : null,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            hintText: 'Confirm new password',
            isPassword: true,
            controller: _confirmPasswordController,
            validate: (value) => value != _passwordController.text
                ? 'Passwords do not match.'
                : null,
          ),
          const SizedBox(height: 24),
          if (_isResetting)
            const CircularProgressIndicator()
          else
            PrimaryButton(
              title: 'RESET PASSWORD',
              onPressed: _confirmNewPassword,
            ),
        ],
      ),
    );
  }
}
