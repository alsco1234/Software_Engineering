// Copyright 2018-present the Flutter authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:chatgpt_course/models/category_model.dart';
import 'package:chatgpt_course/models/chat_model.dart';
import 'package:chatgpt_course/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'store.dart';
import 'chat_screen.dart';
import 'setting.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/api_service.dart';
import '../providers/models_provider.dart';
import '../screens/edit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/chats_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final modelProvider = Provider.of<ModelsProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Categories',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
              onPressed: () async{
                await userProvider.loadDeployed();
                await userProvider.loadLike();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StorePage()),
                );
              },
              icon: const Icon(
                Icons.shopping_bag_rounded,
                color: Colors.green,
              )
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          // Add your onPressed code here!
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SettingPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Column(
          // padding: const EdgeInsets.symmetric(horizontal: 24.0),

          children: <Widget>[
            SizedBox(height: 30),
            Container(
              height: MediaQuery.of(context).size.height - 180,
              // width: MediaQuery.of(context).size.width - 20,
              child: ListView.builder(
                itemCount: userProvider.categoryList.length,
                itemBuilder: (BuildContext context, int index) => Card(
                  elevation: 5,
                  child: Container(
                    height: 100,
                    child:    ListTile(
                        contentPadding: EdgeInsets.all(0),
                        onTap: () async{
                          CategoryModel chatInformation = userProvider.categoryList[index];
                          chatProvider.clearChatList();
                          chatProvider.clearMsgList();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChatScreen(chatInformation: chatInformation)),
                          );
                        },
                        leading: Container(
                            height: 100,
                            width: 100,
                            child:  userProvider.categoryList[index].image != '' ?
                            Image.network(
                              userProvider.categoryList[index].image!,
                              fit: BoxFit.cover,
                            ):
                            SvgPicture.asset('assets/svg/clip.svg', fit: BoxFit.scaleDown)
                        ),
                        title: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  '${userProvider.categoryList[index].title}',
                                  style: TextStyle(fontSize: 20),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  '${userProvider.categoryList[index].description}',
                                  style: TextStyle(fontSize: 20),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              // Image.asset('assets/images/google.png'),
                              // SizedBox(
                              //   child: const DecoratedBox(
                              //     decoration: BoxDecoration(color: Colors.grey),
                              //   ),
                              //   width: MediaQuery.of(context).size.width,
                              //   height: 1,
                              // ),
                            ],
                          ),
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem(
                              child: Text("Delete"),
                              value: "delete",
                            ),
                            PopupMenuItem(
                              child: Text("Edit"),
                              value: "edit",
                            ),
                            PopupMenuItem(
                              child: Text("deploy"),
                              value: "deploy",
                            ),
                          ],
                          onSelected: (value) {
                            if (value == "delete") {
                              // 삭제 기능 실행
                              userProvider.deleteCategory(userProvider.categoryList[index].key);
                              const snackBar =  SnackBar(
                                content: Text('delete!'),
                                duration: Duration(seconds: 2),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                            } else if (value == "edit") {
                              // 수정 기능 실행
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => EditPage(categoryModel: userProvider.categoryList[index],)),
                              );
                              // userProvider.editCategory(userProvider.categoryList[index].title);
                            }
                            else if (value == "deploy") {
                              // 수정 기능 실행
                              // userProvider.editCategory(userProvider.categoryList[index].title);
                              showDialog(
                                  context: context,
                                  barrierDismissible: true, // 바깥 영역 터치시 닫을지 여부
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      content: Text('${userProvider.categoryList[index].title}를 배포하시겠습니까?'),
                                      insetPadding: const  EdgeInsets.fromLTRB(0,80,0, 80),
                                      actions: [
                                        TextButton(
                                          child: const Text('확인'),
                                          onPressed: ()  async{
                                            try {
                                              final check = await deploy(userProvider.categoryList[index].key,userProvider.categoryList[index], userProvider.myProfile.email, userProvider.myProfile.englishLevel.toInt(),userProvider.myProfile.name);

                                              const snackBar =  SnackBar(
                                                content: Text('저장 완료!'),
                                                duration: Duration(seconds: 2),
                                              );
                                              check != null ? ScaffoldMessenger.of(context).showSnackBar(snackBar) : null;
                                            } catch (e) {
                                              const snackBar =  SnackBar(
                                                content: Text('저장 실패',style: TextStyle(color: Colors.red),),
                                                duration: Duration(seconds: 2),
                                              );
                                              ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                            }
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: const Text('취소'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  }
                              );
                            }
                          },
                        )

                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future deploy(String hash, CategoryModel categoryModel,String userEmail, int englishLevel,String myName ) async{

    // final userProvider = Provider.of<UserProvider>(context);
    DocumentReference document =  FirebaseFirestore.instance
        .collection('deploy')
        .doc(hash);

    final snapshot = await FirebaseFirestore.instance
        .collection('deploy')
        .doc(hash).get();

    if(snapshot.exists){
      const snackBar = SnackBar(
        content: Text('이미 존재하는 category 입니다!'),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return null;
    }

    Map<String, dynamic> data ={
      'gptRole': categoryModel.gptRole,
      'scenario': categoryModel.scenario,
      'description': categoryModel.description,
      'title': categoryModel.title,
      'image' : categoryModel.image,
      'key' : document.id,
      'owner': userEmail,
      'like': 0,
    };
    await document.set(data);
  }
}