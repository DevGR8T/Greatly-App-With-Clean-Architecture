import 'package:flutter/material.dart';
import '../../../../core/utils/mixins/form_validation_mixin.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../domain/entities/profile.dart';
import '../../domain/entities/update_profile_request.dart';

class EditProfileForm extends StatefulWidget {
  final Profile profile;
  final Function(UpdateProfileRequest) onSave;
  final VoidCallback onCancel;

  const EditProfileForm({
    Key? key,
    required this.profile,
    required this.onSave,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> with FormValidationMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.profile.username);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _usernameController,
                labelText: 'Username',
                hintText: 'Enter your username',
                validator: validateUsername,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onCancel,
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      final request = UpdateProfileRequest(
        username: _usernameController.text.trim() != widget.profile.username
            ? _usernameController.text.trim()
            : null,
      );

      // Only save if there are actual changes
      if (request.hasChanges) {
        widget.onSave(request);
      } else {
        widget.onCancel();
      }
    }
  }
}