class User {
  final String id;
  final String email;
  final String? username;
  final String? phone;
  final bool isNewUser; 
  final bool emailVerified; 

  const User({
    required this.id,
    required this.email,
    this.username,
    this.phone,
    required this.isNewUser, 
    required this.emailVerified,
  });
}