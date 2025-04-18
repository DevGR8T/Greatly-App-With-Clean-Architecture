import 'package:equatable/equatable.dart';

class Banner extends Equatable {
  final int id;
  final String title;
  final String imageUrl;
  final String link;
  final bool active;

  const Banner({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.link,
    required this.active,
  });

  @override
  List<Object?> get props => [id, title, imageUrl, link, active];
}