import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import '../models/category_model.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';


class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final myController = TextEditingController();
  late ImagePicker _picker = ImagePicker();
  PickedFile? _image;

  final _formKey = GlobalKey<FormState>();
  //TextEditingController _nameController = TextEditingController();
  TextEditingController _gptRoleController = TextEditingController();
  TextEditingController _scenarioController = TextEditingController();
  //TextEditingController _mySexController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _chatGptController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Add Categories',style: TextStyle(color: Colors.black),),
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context); // 이전 페이지로 이동
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20,),
              Text('아래 클립을 누르면 앨범으로 이동합니다.'),
              Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 35),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 150,
                      color: Colors.grey.shade300,
                    ),
                  ),
                  Positioned(
                      child: InkWell(
                        child:Container(
                          width: MediaQuery.of(context).size.width,
                          height: 150,
                          child:   _image == null ?   SvgPicture.asset('assets/svg/clip.svg', fit: BoxFit.scaleDown,) : Image.file(File(_image!.path),fit: BoxFit.scaleDown),
                        ),
                        onTap: () async {
                          // // 갤러리에서 사진을 선택하는 로직 추가
                          // final pickedImage = await _picker.getImage(source: ImageSource.gallery);
                          // if (pickedImage != null) {
                          //   // 선택한 이미지가 있을 경우, 해당 이미지를 사용하여 원하는 작업을 수행합니다.
                          // }
                          await getImageFromGallery();

                        },
                      )
                  ),
                ],
              ),
              SizedBox(height: 20,),
              Form(
                key: _formKey,
                child:  Container(
                  alignment: AlignmentDirectional.topStart,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:  <Widget>[
                      TextFormField(
                        controller: _titleController ,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter title';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Title',
                        ),
                      ),
                      TextFormField(
                        controller: _gptRoleController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter role of the chat gpt';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'GPT Role',
                        ),
                      ),
                      TextFormField(
                        controller: _descriptionController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter description';
                          }
                          return null;
                        },
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Description',
                        ),
                      ),

                      TextFormField(
                        controller: _scenarioController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter scenario';
                          }
                          return null;
                        },
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Scenario',
                        ),
                      ),
                      // TextFormField(
                      //   controller: _nameController,
                      //   validator: (value) {
                      //     if (value!.isEmpty) {
                      //       return 'Please enter role of the chat gpt ';
                      //     }
                      //     return null;
                      //   },
                      //   decoration: InputDecoration(
                      //     labelText: 'role of the chat gpt ',
                      //   ),
                      // ),
                      // TextFormField(
                      //   controller: _mySexController,
                      //   validator: (value) {
                      //     if (value!.isEmpty) {
                      //       return 'Please enter your sex';
                      //     }
                      //     return null;
                      //   },
                      //   decoration: InputDecoration(
                      //     labelText: 'sex',
                      //   ),
                      // ),
                      // TextFormField(
                      //   controller: _chatGptController,
                      //   validator: (value) {
                      //     if (value!.isEmpty) {
                      //       return 'Please enter chatgpt\'s sex';
                      //     }
                      //     return null;
                      //   },
                      //   decoration: InputDecoration(
                      //     labelText: 'chatgpt\'s sex',
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),

                child: ElevatedButton(
                  onPressed: () async {
                    save(userProvider);
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green, // 색상을 원하는 색으로 변경
                  ),
                  child: Text('Create Category'),
                )

              ),

            ],
          ),
        )
    );
  }
  Future getImageFromGallery() async{
    var image = await ImagePicker.platform.pickImage(source: ImageSource.gallery);
    setState((){
      _image = image!;
    });
  }
  Future save(final userProvider) async{
    if (_formKey.currentState!.validate()) {
      try {
        Reference reference = FirebaseStorage.instance.ref('test');
        String? url;
        UploadTask uploadTask;

        if(_image==null) {
          url = null;
          print('url is null');
        }
        else{
          uploadTask = reference.putFile(File(_image!.path));
          print('no error');
          TaskSnapshot snapshot = await uploadTask;
          url = await snapshot.ref.getDownloadURL();
        }

        DocumentReference document =  FirebaseFirestore.instance
            .collection('user')
            .doc(userProvider.myProfile.email)
            .collection('subjects')
            .doc();

        Map<String, dynamic> data ={
          'myName': userProvider.myProfile.name,
          'gptRole': 'gptrole',
          'scenario': _scenarioController.text,
          'description': _descriptionController.text,
          'title': _titleController.text,
          'image' : url,
          'userEnglishLevel': userProvider.myProfile.englishLevel * 5,
          'key' : document.id,
        };
        await document.set(data);
        await userProvider.loadCategory();
        const snackBar = SnackBar(
          content: Text('성공!'),
          duration: Duration(seconds: 2),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.pop(context);
      } catch (e) {
        const snackBar = SnackBar(
          content: Text('실패!'),
          duration: Duration(seconds: 2),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }
}