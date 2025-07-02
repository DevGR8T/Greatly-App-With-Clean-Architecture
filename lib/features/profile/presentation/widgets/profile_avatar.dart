import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final bool isEditable;
  final Function(File)? onImageSelected;
  final VoidCallback? onImageDeleted;

  const ProfileAvatar({
    Key? key,
    this.imageUrl,
    this.isEditable = false,
    this.onImageSelected,
    this.onImageDeleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey[300],
          backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
              ? NetworkImage(imageUrl!)
              : null,
          child: imageUrl == null || imageUrl!.isEmpty
              ? const Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.grey,
                )
              : null,
        ),
        if (isEditable)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: PopupMenuButton<String>(
                icon: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
                onSelected: (value) {
                  if (value == 'camera') {
                    _pickImage(ImageSource.camera);
                  } else if (value == 'gallery') {
                    _pickImage(ImageSource.gallery);
                  } else if (value == 'delete') {
                    onImageDeleted?.call();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'camera',
                    child: Row(
                      children: [
                        Icon(Icons.camera_alt),
                        SizedBox(width: 8),
                        Text('Camera'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'gallery',
                    child: Row(
                      children: [
                        Icon(Icons.photo_library),
                        SizedBox(width: 8),
                        Text('Gallery'),
                      ],
                    ),
                  ),
                  if (imageUrl != null && imageUrl!.isNotEmpty)
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    
    if (pickedFile != null) {
      onImageSelected?.call(File(pickedFile.path));
    }
  }
}