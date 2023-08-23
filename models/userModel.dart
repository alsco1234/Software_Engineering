class UserModel{
  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.profileImageUrl,
    required this.englishLevel,
    required this.speakingLevel,
  });
  final String uid;
  final String email;
  final String name;
  final String profileImageUrl;
  final double englishLevel;
  final double speakingLevel;
}