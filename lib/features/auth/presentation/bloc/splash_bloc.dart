import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import 'splash_event.dart';
import 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final GetCurrentUserUseCase getCurrentUserUseCase;

  SplashBloc(this.getCurrentUserUseCase) : super(SplashInitial()) {
    on<CheckAuthenticationEvent>((event, emit) async {
      emit(SplashLoading());

      final result = await getCurrentUserUseCase();

      result.fold(
        (failure) => emit(SplashError('Failed to check authentication: ${failure.message}')),
        (user) {
          if (user != null && user.emailVerified) {
            emit(SplashAuthenticated());
          } else {
            emit(SplashUnauthenticated());
          }
        },
      );
    });
  }
}