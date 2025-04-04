import 'package:flutter/material.dart';
import 'package:greatly_user/core/constants/strings.dart';

class EmailNotVerifiedDialog extends StatelessWidget {
  final VoidCallback onResend;

  const EmailNotVerifiedDialog({required this.onResend, super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      title: const Text('⚠️ Email Not Verified'), 
      content: const Text(
        Strings.emailVerificationRequired,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
           FocusScope.of(context).unfocus();
          },
          child: const Text(Strings.ok),
        ),
        TextButton(
          onPressed: onResend,
          child: const Text(Strings.resendEmail),
        ),
      ],
    );
  }
}