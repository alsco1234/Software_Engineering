class DeployedModel{
  DeployedModel({
    required this.image,
    required this.description,
    required this.title,
    required this.gptRole,
    required this.scenario,
    required this.myName,
    required this.owner,
    required this.key,
    required this.like,
  });
  final String gptRole;
  final String scenario;
  final String myName;
  final String? image;
  final String description;
  final String title;
  final String key;
  final String owner;
  final int like;
}