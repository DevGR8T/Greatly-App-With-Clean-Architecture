import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/profile.dart';

class ProfileInfoWidget extends StatelessWidget {
  final Profile profile;

  const ProfileInfoWidget({
    Key? key,
    required this.profile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Username', profile.username),
            const SizedBox(height: 20),
            _buildInfoRow('Email', profile.email),
            const SizedBox(height: 20),
            _buildInfoRow(
              'Email Status',
              profile.isEmailVerified ? 'Verified' : 'Not Verified',
              trailing: profile.isEmailVerified
                  ? const Icon(Icons.verified, color: Colors.green, size: 20)
                  : const Icon(Icons.warning, color: Colors.orange, size: 20),
            ),
            const SizedBox(height: 20),
            _buildInfoRow(
              'Member Since',
              DateFormat('MMM dd, yyyy').format(profile.createdAt),
            ),
            const SizedBox(height: 20),
            _buildInfoRow(
              'Last Updated',
              DateFormat('MMM dd, yyyy').format(profile.updatedAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Widget? trailing}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w400),
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }
}
