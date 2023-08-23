import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import '../models/category_model.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';


class EditPage extends StatefulWidget {
  final CategoryModel categoryModel;
  const EditPage({Key? key, required this.categoryModel}) : super(key: key);

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final myController = TextEditingController();
  late ImagePicker _picker = ImagePicker();
  PickedFile? _image;

  final _formKey = GlobalKey<FormState>();
  String? _rolePlay;
  String? _scenario;
  String? _description;
  String? _title;
  String? _gptRole;
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final categoryModel =  widget.categoryModel;
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
                          child:  (() {
                            if (categoryModel.image == '' && _image == null) {
                              return SvgPicture.asset('assets/svg/clip.svg', fit: BoxFit.scaleDown);
                            } else if (_image == null) {
                              return Image.network(categoryModel.image!);
                            }
                            else{
                              return Image.file(File(_image!.path), fit: BoxFit.scaleDown);
                            }
                          })(),

                          // categoryModel.image == null ?   SvgPicture.asset('assets/svg/clip.svg', fit: BoxFit.scaleDown,) : Image.file(File(_image!.path),fit: BoxFit.scaleDown),
                        ),
                        onTap: () async {
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
                        controller: TextEditingController(text: categoryModel.title) ,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter title';
                          }
                          _title = value;
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'title',
                        ),
                        autofocus: false,
                      ),
                      TextFormField(
                        controller: TextEditingController(text: categoryModel.gptRole),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter gptRole';
                          }
                          _gptRole = value;
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: '_gptRole',
                        ),
                        autofocus: false,
                      ),
                      TextFormField(
                        controller: TextEditingController(text: categoryModel.description) ,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter description';
                          }
                          _description = value;
                          return null;
                        },
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'description',
                        ),
                        autofocus: false,
                      ),

                      TextFormField(
                        controller: TextEditingController(text: categoryModel.scenario),
                        autofocus: false,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter scenario';
                          }
                          _scenario = value;
                          return null;
                        },
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'scenario',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: () async {
                    await edit(userProvider,categoryModel);
                    userProvider.loadCategory();
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green, // 색상을 원하는 색으로 변경
                  ),
                  child: Text('edit Category'),
                ),
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
  Future edit(final userProvider, CategoryModel categoryModel) async{
    if (_formKey.currentState!.validate()) {
      try {
        DocumentReference document =  FirebaseFirestore.instance
            .collection('user')
            .doc(userProvider.myProfile.email)
            .collection('subjects')
            .doc(categoryModel.key);
        Reference reference = FirebaseStorage.instance.ref('${document.id}');
        String? url;
        UploadTask uploadTask;

        if(_image==null) {
          url = null;
          if(categoryModel.image != null){
            url = categoryModel.image;
          }
          print('url is null');
        }
        else{
          uploadTask = reference.putFile(File(_image!.path));
          print('no error');
          TaskSnapshot? snapshot = await uploadTask;
          url = await snapshot.ref.getDownloadURL();
        }
        await document.update(
            {
              'myName': userProvider.myProfile.name,
              'gptRole': _gptRole,
              'scenario': _scenario,
              'description': _description,
              'title': _title,
              'image' : url,
              'userEnglishLevel': userProvider.myProfile.englishLevel * 5,
              'key' : document.id,
            }).then((_) => print('Updated'))
            .catchError((error) => print('Update failed: $error'));

        const snackBar = SnackBar(
          content: Text('편집성공!'),
          duration: Duration(seconds: 2),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        Navigator.pop(context);
      } catch (e) {
        const snackBar = SnackBar(
          content: Text('편집실패!'),
          duration: Duration(seconds: 2),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }
}
