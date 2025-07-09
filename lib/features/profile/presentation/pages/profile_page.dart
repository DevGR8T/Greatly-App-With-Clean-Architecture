import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:delightful_toast/delight_toast.dart';
import 'package:delightful_toast/toast/components/toast_card.dart';
import 'package:delightful_toast/toast/utils/enums.dart';
import 'package:greatly_user/core/theme/app_colors.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/mixins/snackbar_mixin.dart';
import '../../../../shared/components/error_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

import '../../../../shared/components/app_shimmer.dart';
import '../widgets/edit_profile_form.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_info_widget.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SnackBarMixin {
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ProfileBloc>()..add(LoadProfile()),
      child: MultiBlocListener(
        listeners: [
          // Listen to AuthBloc for logout state changes
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthInitial) {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/login', (route) => false);
                _showToast(context, 'Successfully signed out!', Icons.check,
                    AppColors.primary);
              } else if (state is AuthSignOutError) {
                // Listen to specific sign-out error
                Navigator.of(context, rootNavigator: true).pop();
                _showToast(context, 'Failed to sign out!', Icons.error,
                    Colors.red[500]!);
              }
            },
          ),
          // Listen to ProfileBloc for profile-related state changes
          BlocListener<ProfileBloc, ProfileState>(
            listener: (context, state) {
              if (state is ProfileError) {
                showSnackBar(context, state.message, Colors.red);
              } else if (state is ProfileUpdateSuccess) {
                showSnackBar(
                    context, 'Profile updated successfully', Colors.green);
                setState(() {
                  _isEditing = false;
                });
                context.read<ProfileBloc>().add(LoadProfile());
              } else if (state is ProfilePictureUploadSuccess) {
                showSnackBar(context, 'Profile picture updated successfully',
                    Colors.green);
                context.read<ProfileBloc>().add(LoadProfile());
              } else if (state is ProfilePictureDeleted) {
                showSnackBar(context, 'Profile picture deleted successfully',
                    Colors.green);
                context.read<ProfileBloc>().add(LoadProfile());
              }
            },
          ),
        ],
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            actions: [
              BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, state) {
                  if (state is ProfileLoaded) {
                    return IconButton(
                      icon: Icon(_isEditing ? Icons.close : Icons.edit),
                      onPressed: () {
                        setState(() {
                          _isEditing = !_isEditing;
                        });
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'logout') {
                    _showSignOutDialog(context);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading) {
                return const _ProfileLoadingWidget();
              } else if (state is ProfileError) {
                return ErrorStateWidget(
                  message: state.message,
                  onRetry: () => context.read<ProfileBloc>().add(LoadProfile()),
                );
              } else if (state is ProfileLoaded) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ProfileAvatar(
                        imageUrl: state.profile.profilePictureUrl,
                        isEditable: _isEditing,
                        onImageSelected: (file) {
                          context
                              .read<ProfileBloc>()
                              .add(UploadProfilePicture(file));
                        },
                        onImageDeleted: () {
                          context
                              .read<ProfileBloc>()
                              .add(DeleteProfilePicture());
                        },
                      ),
                      const SizedBox(height: 24),
                      if (_isEditing)
                        EditProfileForm(
                          profile: state.profile,
                          onSave: (request) {
                            context
                                .read<ProfileBloc>()
                                .add(UpdateProfile(request));
                          },
                          onCancel: () {
                            setState(() {
                              _isEditing = false;
                            });
                          },
                        )
                      else
                        ProfileInfoWidget(profile: state.profile),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  // Enhanced logout dialog similar to your reference
  void _showSignOutDialog(BuildContext context) {
    print("Showing sign out dialog");
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3.0),
        ),
        title: const Text('Confirm Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _performSignOut(context);
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  // Method to perform the sign out process with loading indicator
  void _performSignOut(BuildContext context) {
    print("Starting sign out process");

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext loadingContext) => WillPopScope(
        onWillPop: () async => false,
        child: const Center(
          child: CircularProgressIndicator(
            backgroundColor: Colors.white,
          ),
        ),
      ),
    );

    // Add minimum delay and trigger sign out
    Future.wait([
      Future.delayed(const Duration(
          seconds: 2)), // Ensure loading shows for at least 2 seconds
      Future(() => context.read<AuthBloc>().add(SignOut())),
    ]).then((_) {
      print("Sign out process initiated");
      // The actual completion will be handled by the BlocListener
    }).catchError((error) {
      print("Error during sign out initiation: $error");
      // Dismiss loading dialog
      Navigator.of(context, rootNavigator: true).pop();
      // Show error toast
      _showToast(context, 'Failed to sign out!', Icons.error, Colors.red[500]!);
    });
  }

  // Method to show toast notifications
  void _showToast(
      BuildContext context, String message, IconData icon, Color color) {
    print("Showing toast: $message");
    DelightToastBar(
      snackbarDuration: const Duration(seconds: 2),
      autoDismiss: true,
      position: DelightSnackbarPosition.top,
      builder: (context) => ToastCard(
        title: Text(message, style: const TextStyle(color: Colors.white)),
        leading: Icon(icon, color: Colors.white),
        color: color,
      ),
    ).show(context);
  }
}

class _ProfileLoadingWidget extends StatelessWidget {
  const _ProfileLoadingWidget();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppShimmer(
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 24),
          AppShimmer(
            child: Container(
              height: 20,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),
          AppShimmer(
            child: Container(
              height: 16,
              width: 150,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
