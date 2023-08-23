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

import 'package:chatgpt_course/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'clone.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/deployed_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';


class StorePage extends StatefulWidget {
  const StorePage({Key? key}) : super(key: key);

  @override
  _StorePageState createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  String _selectedOption = 'basic';
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: true);
    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.green, // Set the desired color here
          ),
          backgroundColor: Colors.white,
          centerTitle: true,
          title: const Text(
            'Market',
            style: TextStyle(color: Colors.black),
          ),
          leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back, color: Colors.blue,),
          )
      ),
      body: SafeArea(
        child: Column(
          // padding: const EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[
            // SizedBox(height: 30),
            DropdownButton(
              value: _selectedOption,
              items: <String>['basic', 'asc', 'desc'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() async{
                  _selectedOption = newValue!;
                  userProvider.setDeployOrder(_selectedOption);
                  await userProvider.loadDeployed();
                });
              },
            ),
            Container(
              height: MediaQuery.of(context).size.height - 180,
              // width: MediaQuery.of(context).size.width - 20,
              child: ListView.builder(
                itemCount: userProvider.deployed_list.length,
                itemBuilder: (BuildContext context, int index) => Card(
                  elevation: 5,
                  child: Container(
                    height: 100,
                    // width: 200,
                    child:    ListTile(
                        contentPadding: EdgeInsets.all(0),
                        onTap: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ClonePage(
                                    deployedModel:
                                    userProvider.deployed_list[index], index: index)),
                          );
                        },
                        leading: Container(
                            height: 100,
                            width: 100,
                            child: userProvider.deployed_list[index].image != ''
                                ? Image.network(
                              userProvider.deployed_list[index].image!,
                              fit: BoxFit.cover,
                            )
                                : SvgPicture.asset('assets/svg/clip.svg',
                                fit: BoxFit.scaleDown)),
                        title: Row(
                          children: [
                            Expanded(
                                flex: 7,
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          '${userProvider.deployed_list[index].title}',
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          '${userProvider.deployed_list[index].description}',
                                          style: TextStyle(fontSize: 20),
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
                                )),
                            Expanded(
                                flex: 3,
                                child: Container(
                                  // color: Colors.blue,
                                  child: Row(
                                    children: [
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
                                      Text('${userProvider.deployed_list[index].like}'),
                                    ],
                                  ),
                                ))
                          ],
                        )

                      // trailing: SizedBox(
                      //   child: Row(
                      //     children: [
                      //       Icon(Icons.star),
                      //       Icon(Icons.send),
                      //     ],
                      //   ),
                      // )
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