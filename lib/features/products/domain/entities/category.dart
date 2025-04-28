
import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final String? imageUrl;
  final String? description;
  final int? productCount;

  const Category({
    required this.id,
    required this.name,
    this.imageUrl,
    this.description,
    this.productCount,
  });

  @override
  List<Object?> get props => [id, name, imageUrl, description, productCount];
}