import 'package:equatable/equatable.dart';

class FeaturedProduct extends Equatable {
  final int id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final int stock;
  final String category;

  const FeaturedProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.stock,
    required this.category,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        imageUrl,
        stock,
        category,
      ];
}