import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/update_profile_request.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/upload_profile_picture_usecase.dart';
import '../../domain/usecases/delete_profile_picture_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUsecase getProfileUsecase;
  final UpdateProfileUsecase updateProfileUsecase;
  final UploadProfilePictureUsecase uploadProfilePictureUsecase;
  final DeleteProfilePictureUsecase deleteProfilePictureUsecase;
  final LogoutUsecase logoutUsecase;

  ProfileBloc({
    required this.getProfileUsecase,
    required this.updateProfileUsecase,
    required this.uploadProfilePictureUsecase,
    required this.deleteProfilePictureUsecase,
    required this.logoutUsecase,
  }) : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<UploadProfilePicture>(_onUploadProfilePicture);
    on<DeleteProfilePicture>(_onDeleteProfilePicture);
  }

  Future<void> _onLoadProfile(LoadProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    
    final result = await getProfileUsecase(NoParams());
    
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) => emit(ProfileLoaded(profile)),
    );
  }

  Future<void> _onUpdateProfile(UpdateProfile event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    
    final result = await updateProfileUsecase(UpdateProfileParams(request: event.request));
    
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (profile) => emit(ProfileUpdateSuccess(profile)),
    );
  }

Future<void> _onUploadProfilePicture(UploadProfilePicture event, Emitter<ProfileState> emit) async {
  emit(ProfilePictureUploading());
  
  // Step 1: Upload the image file
  final uploadResult = await uploadProfilePictureUsecase(
    UploadProfilePictureParams(imageFile: event.imageFile),
  );
  
  await uploadResult.fold(
    (failure) async => emit(ProfileError(failure.message)),
    (imageUrl) async {
      // Step 2: Update profile with the new image URL
      final updateRequest = UpdateProfileRequest(
        profilePictureUrl: imageUrl,
      );
      
      final updateResult = await updateProfileUsecase(
        UpdateProfileParams(request: updateRequest),
      );
      
      updateResult.fold(
        (failure) => emit(ProfileError(failure.message)),
        (profile) => emit(ProfilePictureUploadSuccess(imageUrl)),
      );
    },
  );
}

  Future<void> _onDeleteProfilePicture(DeleteProfilePicture event, Emitter<ProfileState> emit) async {
    emit(ProfileLoading());
    
    final result = await deleteProfilePictureUsecase(NoParams());
    
    result.fold(
      (failure) => emit(ProfileError(failure.message)),
      (_) => emit(ProfilePictureDeleted()),
    );
  }

  
}
