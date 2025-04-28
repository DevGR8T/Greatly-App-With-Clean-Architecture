import 'package:equatable/equatable.dart';

/// Represents a banner with details like title, image, and link.
class Banner extends Equatable {
  final int id; // Unique identifier for the banner.
  final String title; // Title of the banner.
  final String imageUrl; // URL of the banner's image.
  final String link; // Link associated with the banner.
  final bool active; // Indicates if the banner is active.

  /// Creates a fully defined [Banner] instance.
  const Banner({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.link,
    required this.active,
  });

  /// Properties used to compare equality of [Banner] instances.
  @override
  List<Object?> get props => [id, title, imageUrl, link, active];
}