import '../../domain/entities/banner.dart';

class BannerModel extends Banner {
  const BannerModel({
    required super.id,
    required super.title,
    required super.imageUrl,
    required super.link,
    required super.active,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
  // Debug prints

  
  // Direct access instead of through "attributes"
  String imageUrl = '';
  try {
    if (json['image'] != null && 
        json['image']['formats'] != null && 
        json['image']['formats']['small'] != null) {
      imageUrl = json['image']['formats']['small']['url'] ?? '';
    }
  } catch (e) {

  }
  
  return BannerModel(
    id: json['id'] ?? 0,
    title: json['title'] ?? '',
    imageUrl: imageUrl,
    link: json['link'] ?? '',
    active: json['active'] ?? false,
  );
}

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'link': link,
      'active': active,
    };
  }
}