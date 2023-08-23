class CategoryModel{
  CategoryModel({
    required this.image,
    required this.description,
    required this.title,
    required this.gptRole,
    required this.scenario,
    required this.myName,
    //required this.mySex,
    //required this.yourName,
    required this.userEnglishLevel,
    //required this.yourSex,
    required this.key,
  });
  final String gptRole;
  final String scenario;
  final String myName;
  //final String mySex;
  //final String yourName;
  //final String yourSex;
  final int userEnglishLevel;
  final String? image;
  final String description;
  final String title;
  final String key;
}
