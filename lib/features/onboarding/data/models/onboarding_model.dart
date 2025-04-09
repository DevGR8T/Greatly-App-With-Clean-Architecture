/// Data model for an onboarding item.
/// Represents the title, description, and image URL of an onboarding step.
class OnboardingModel {
  final String title; // Title of the onboarding item
  final String description; // Description of the onboarding item
  final String imageUrl; // Image URL for the onboarding item

  /// Constructor to initialize the onboarding item.
  OnboardingModel({
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  /// Converts the model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
    };
  }

  /// Creates an instance of the model from a JSON map.
  factory OnboardingModel.fromJson(Map<String, dynamic> json) {
    return OnboardingModel(
      title: json['title'],
      description: json['description'],
      imageUrl: json['imageUrl'],
    );
  }
}