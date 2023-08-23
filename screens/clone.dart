import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import '../models/category_model.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/deployed_model.dart';


class ClonePage extends StatefulWidget {
  final DeployedModel deployedModel;
  final int index;
  const ClonePage({Key? key, required this.deployedModel, required this.index}) : super(key: key);

  @override
  State<ClonePage> createState() => _ClonePageState();
}

class _ClonePageState extends State<ClonePage> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final deployedModel = widget.deployedModel;
    int index = widget.index;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          title: Text('Clone ${deployedModel.title}',style: TextStyle(color: Colors.black),),
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
                          child:   deployedModel.image == '' ?   SvgPicture.asset('assets/svg/clip.svg', fit: BoxFit.scaleDown,) : Image.network(deployedModel.image!,fit: BoxFit.scaleDown),
                        ),
                        onTap: () async {
                        },
                      )
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 35),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(width: 10,),

                    IconButton(
                      onPressed:() async{
                        await saveLike(userProvider.deployed_list[index].key, userProvider.myProfile.email, userProvider.deployed_list[index].like);
                        await userProvider.loadDeployed();
                        await userProvider.loadLike();
                        // bool set = await userProvider.isLike(userProvider.deployed_list[index].key);
                        print(userProvider.likeList.contains(userProvider.deployed_list[index].key));
                      } ,

                      icon: userProvider.likeList.contains(userProvider.deployed_list[index].key) ? Icon(Icons.thumb_up_alt_rounded,color: Colors.red,):
                      Icon(Icons.thumb_up_alt_outlined),
                    ),
                    SizedBox(width: 10,),
                    Text('${userProvider.deployed_list[index].like}'),
                  ],
                ),
              ),
              SizedBox(height: 20,),
              Form(
                // key: _formKey,
                child:  Container(
                  alignment: AlignmentDirectional.topStart,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:  <Widget>[
                      TextFormField(
                        enabled: false,
                        controller: TextEditingController(text: deployedModel.title) ,
                        decoration: InputDecoration(
                          labelText: 'title',
                        ),
                        maxLines: 3,
                      ),
                      TextFormField(
                        enabled: false,
                        controller: TextEditingController(text: deployedModel.gptRole),
                        decoration: InputDecoration(
                          labelText: 'gpt role',
                        ),
                      ),
                      TextFormField(
                        enabled: false,
                        controller: TextEditingController(text: deployedModel.description),
                        decoration: InputDecoration(
                          labelText: 'description',
                        ),
                      ),

                      TextFormField(
                        enabled: false,
                        controller: TextEditingController(text: deployedModel.scenario),
                        decoration: InputDecoration(
                          labelText: 'scenario',
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                  padding: const EdgeInsets.all(20),

                  child: ElevatedButton(
                    onPressed: () async {
                      await save(userProvider, deployedModel);
                      await userProvider.loadCategory();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green, // Set the desired color here
                    ),
                    child: Text('Clone'),
                  )

              ),

            ],
          ),
        )
    );
  }
  Future save(final userProvider,DeployedModel deployedModel) async{
    try {

      DocumentReference document = FirebaseFirestore.instance
          .collection('user')
          .doc(userProvider.myProfile.email)
          .collection('subjects')
          .doc(deployedModel.key);
      final snapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(userProvider.myProfile.email)
          .collection('subjects')
          .doc(deployedModel.key).get();

      if(snapshot.exists){
        const snackBar = SnackBar(
          content: Text('이미 존재하는 category 입니다!'),
          duration: Duration(seconds: 2),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return null;
      }

      Map<String, dynamic> data ={
        'myName': userProvider.myProfile.name,
        'gptRole': deployedModel.gptRole,
        'scenario': deployedModel.scenario,
        'description': deployedModel.description,
        'title': deployedModel.title,
        'image' : deployedModel.image,
        'userEnglishLevel': userProvider.myProfile.englishLevel * 5,
        'key' : deployedModel.key,
      };
      await document.set(data);

      const snackBar = SnackBar(
        content: Text('clone 성공!'),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Navigator.pop(context);
    } catch (e) {
      const snackBar = SnackBar(
        content: Text('clone 실패!'),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
  Future saveLike(String hash,String email, int like) async{
    final snapshot = await FirebaseFirestore.instance
        .collection('deploy').doc(hash)
        .collection('like').doc(email).get();

    if (snapshot.exists) {
      await FirebaseFirestore.instance
          .collection('deploy')
          .doc(hash)
          .collection('like')
          .doc(email)
          .delete();
      like = like-1;
      await FirebaseFirestore.instance
          .collection('deploy')
          .doc(hash)
          .update({
        'like': like,
      })
          .then((_) => print('Updated'))
          .catchError((error) => print('Update failed: $error'));

      await FirebaseFirestore.instance
          .collection('user')
          .doc(email)
          .collection('like')
          .doc(hash)
          .delete();
    } else {
      await FirebaseFirestore.instance
          .collection('deploy')
          .doc(hash)
          .collection('like')
          .doc(email).set({
        'email': email
      });
      like = like +1;
      await FirebaseFirestore.instance
          .collection('deploy')
          .doc(hash)
          .update({
        'like': like,
      })
          .then((_) => print('Updated'))
          .catchError((error) => print('Update failed: $error'));
      await FirebaseFirestore.instance
          .collection('user')
          .doc(email)
          .collection('like')
          .doc(hash).set({'deployID':hash});
    }
  }
}
