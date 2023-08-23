import 'package:chatgpt_course/models/chat_history.dart';
import 'package:chatgpt_course/models/models_model.dart';
import 'package:chatgpt_course/services/api_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/userModel.dart';
import '../models/category_model.dart';
import '../models/deployed_model.dart';

class UserProvider with ChangeNotifier {

  User? get user => FirebaseAuth.instance.currentUser;

  Future<bool?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return false;
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser
          .authentication;
      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final _result = await FirebaseAuth.instance.signInWithCredential(
          credential);
      var doc = await FirebaseFirestore.instance.collection('user').doc(
        FirebaseAuth.instance.currentUser!.email,).get();
      if (doc.exists == false) {
        print('pass');
        // await signOutGoogle();
        return false;
      }

      // await signOutGoogle();

      await loadMyProfile();
      await loadChatHistory();
      await loadCategory();
      await loadDeployed();
      notifyListeners();
      return true;
    }
    catch (e) {
      print(e);
    }
  }
  Future<void> signUp() async{
    print('start');
    await FirebaseFirestore.instance
        .collection('user')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .set(<String, dynamic>{
      'uid': FirebaseAuth.instance.currentUser!.uid,
      'email': FirebaseAuth.instance.currentUser!.email,
      'name': FirebaseAuth.instance.currentUser!.displayName,
      'profileImageUrl': FirebaseAuth.instance.currentUser!.photoURL,
      'speakingLevel': 5.0,
      'englishLevel': 5.0,
    });

}

  Future<void> signOutGoogle() async{
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    final isSignedIn = await _googleSignIn.isSignedIn();
    if (isSignedIn) {
      await _googleSignIn.disconnect();
    }
    await FirebaseAuth.instance.signOut();
    // _userList = [];
    // _categoryList = [];
    // _myProfile = null;
    // _chatHistoryList = [];
    notifyListeners();
  }

  List<UserModel> _userList = [];

  List<UserModel> get userList => _userList;

  late UserModel _myProfile;
  UserModel get myProfile => _myProfile;

  Future<void> loadMyProfile() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('user')
        .doc(user?.email)
        .get();
    if (doc.exists) {
      print('profile succeed');
      _myProfile = UserModel(
        uid: doc['uid'] ?? '',
        email: doc['email'] ?? '',
        name: doc['name'] ?? '',
        profileImageUrl: doc['profileImageUrl'] ?? '',
        englishLevel: (doc['englishLevel'] ?? 1.0),
        speakingLevel: (doc['speakingLevel'] ?? 1.0),
      );
      print('englishLevel ${_myProfile.speakingLevel}');
      print('speakingLevel ${_myProfile.speakingLevel}');
      print('email  ${_myProfile.email}');
    }
    else{
      print('profile error');
    }
    notifyListeners();
  }


  List<CategoryModel> _categoryList = [];

  List<CategoryModel> get categoryList => _categoryList;

  Future<void> loadCategory() async {
    _categoryList.clear();
    print('hhhhhhhhhhhhhh');
    final snapshot = await FirebaseFirestore.instance
        .collection('user')
        .doc(user?.email)
        .collection('subjects')
        .get();
    for (final doc in snapshot.docs) {
      print('hereeeeeeeeeeee${doc.id}');
      final category = await load_category(doc.id);
      if (category != null) {
        _categoryList.add(category);
      }
    }
    notifyListeners();
  }

  Future<CategoryModel?> load_category(String docId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('user')
        .doc(user?.email)
        .collection('subjects')
        .doc(docId)
        .get();
    if (snapshot.exists) {
      final data = snapshot.data()!;
      final category = CategoryModel(
        image: data['image'] ?? '',
        description: data['description'],
        userEnglishLevel: _myProfile.englishLevel.toInt(),
        title: data['title'],
        gptRole: data['gptRole'],
        scenario: data['scenario'],
        myName: data['myName'],
        key: data['key'],
      );
      print(category.myName);
      return category;
    }
  }

  List<ChatHistoryModel> _chatHistoryList = [];
  List<ChatHistoryModel> get chatHistoryList => _chatHistoryList;

  Future<void> loadChatHistory() async {
    _chatHistoryList = [];
    final snapshot = await FirebaseFirestore.instance
        .collection('user')
        .doc(user?.email)
        .collection('chatHistory')
        .get();
    for (final doc in snapshot.docs) {
      final chatHistory = await load_chatHistory(doc.id.toString());
      if (chatHistory != null) {
        _chatHistoryList.add(chatHistory);
      }
    }
    notifyListeners();
  }

  Future<ChatHistoryModel?> load_chatHistory(String dateTime) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('user')
        .doc(user?.email)
        .collection('chatHistory')
        .doc(dateTime)
        .get();
    if (snapshot.exists) {
      final data = snapshot.data()!;
      final chatHistory = ChatHistoryModel(
        dateTime: int.parse(dateTime) ?? 0,
        title: data['title'] ?? '',
      );
      return chatHistory;
    }
    return null;
  }

  Future<void> deleteCategory(String key) async{
    await FirebaseFirestore.instance
        .collection('user')
        .doc(user?.email)
        .collection('subjects')
        .doc(key).delete();
    await loadCategory();
  }
  Future<void> deleteChatHistory(String key) async{
    await FirebaseFirestore.instance
        .collection('user')
        .doc(user?.email)
        .collection('chatHistory')
        .doc(key).delete();
    await loadCategory();
  }

  List<DeployedModel> _deployed_list = [];
  List<DeployedModel> get deployed_list => _deployed_list;

  Future<void> loadDeployed() async{
    _deployed_list = [];
    late final snapshot;
    if (order == 'basic'){
      snapshot = await FirebaseFirestore.instance
          .collection('deploy').get();
    }
    else if (order == 'asc'){
      snapshot = await FirebaseFirestore.instance
          .collection('deploy').orderBy('like',descending:false ).get();
    }
    else{
      snapshot = await FirebaseFirestore.instance
          .collection('deploy').orderBy('like', descending: true).get();
    }

    for (var doc in snapshot.docs) {
      final deployed = await load_deploy(doc.id);
      if (deployed != null) {
        deployed_list.add(deployed);
      }
    }
    notifyListeners();
  }

  Future<DeployedModel?> load_deploy(String docId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('deploy').doc(docId)
        .get();
    if (snapshot.exists) {
      final doc = snapshot.data()!;
      print('here');
      final category = DeployedModel(
        image: doc['image'],
        description: doc['description'] ?? '',
        title: doc['title'] ?? '',
        gptRole: doc['gptRole'] ?? '',
        scenario: doc['scenario'] ?? '',
        myName: doc['myName'] ?? '',
        owner: doc['owner']?? '',
        key: doc['key'] ?? '',
        like: doc['like'],
      );
      return category;
    }
  }
  List<String> _likeList = [];
  List<String>  get likeList => _likeList;

  Future<void> loadLike() async {
    FirebaseFirestore.instance
        .collection('user').doc(user!.email).collection('like').snapshots().
    listen((QuerySnapshot snapshot) async {
      _likeList = [];
      for (var doc in snapshot.docs) {
        _likeList.add(doc.id);
        print(doc.id);
      }
    });
    notifyListeners();
  }
  String order = 'basic';
  void setDeployOrder(String neworder){
    order = neworder;
  }
}