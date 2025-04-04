import 'package:flutter/material.dart';

import '../../core/constants/strings.dart';

class EmailVerificationDialog extends StatelessWidget {
  final String email;
  final VoidCallback onResend;
  final VoidCallback onOk;

  const EmailVerificationDialog({
    super.key,
    required this.email,
    required this.onResend,
    required this.onOk,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      title: const Text(Strings.dialogTitle),
      content: Text(
        Strings.dialogtext(email),
      ),
      actions: [
        TextButton(
          onPressed: onOk,
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