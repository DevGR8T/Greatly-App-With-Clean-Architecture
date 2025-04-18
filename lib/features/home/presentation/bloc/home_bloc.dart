import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_banners.dart';
import '../../domain/usecases/get_featured_products.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetBanners getBanners;
  final GetFeaturedProducts getFeaturedProducts;

  HomeBloc({
    required this.getBanners,
    required this.getFeaturedProducts,
  }) : super(HomeInitial()) {
    on<GetBannersEvent>(_onGetBannersEvent);
    on<GetFeaturedProductsEvent>(_onGetFeaturedProductsEvent);
  }

 // In home_bloc.dart:
Future<void> _onGetBannersEvent(
  GetBannersEvent event,
  Emitter<HomeState> emit,
) async {
  print('Processing GetBannersEvent');
  emit(BannersLoading());
  final result = await getBanners();
  result.fold(
    (failure) {
      print('Banner error: ${failure.message}');
      emit(BannersError(failure.message));
    },
    (banners) {
      print('Banners loaded successfully: ${banners.length}');
      emit(BannersLoaded(banners));
    },
  );
}

  Future<void> _onGetFeaturedProductsEvent(
    GetFeaturedProductsEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(FeaturedProductsLoading());
    final result = await getFeaturedProducts();
    result.fold(
      (failure) => emit(FeaturedProductsError(failure.message)),
      (products) => emit(FeaturedProductsLoaded(products)),
    );
  }
}