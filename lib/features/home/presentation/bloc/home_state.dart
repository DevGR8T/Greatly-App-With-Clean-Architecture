import 'package:equatable/equatable.dart';

import '../../domain/entities/banner.dart';
import '../../domain/entities/featured_product.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class BannersLoading extends HomeState {}

class BannersLoaded extends HomeState {
  final List<Banner> banners;

  const BannersLoaded(this.banners);

  @override
  List<Object> get props => [banners];
}

class BannersError extends HomeState {
  final String message;

  const BannersError(this.message);

  @override
  List<Object> get props => [message];
}

class FeaturedProductsLoading extends HomeState {}

class FeaturedProductsLoaded extends HomeState {
  final List<FeaturedProduct> products;

  const FeaturedProductsLoaded(this.products);

  @override
  List<Object> get props => [products];
}

class FeaturedProductsError extends HomeState {
  final String message;

  const FeaturedProductsError(this.message);

  @override
  List<Object> get props => [message];
}