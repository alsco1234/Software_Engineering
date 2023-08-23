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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../bottombar.dart';
import '../providers/user_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      // backgroundColor: Theme.of(context).backgroundColor,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          // padding: const EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[
            const SizedBox(height: 120.0),
            // TODO: Remove filled: true values (103)
            SvgPicture.asset('assets/images/Chat-zziPT Access.svg'),

            const SizedBox(height: 100,),
            // Text('로그인', style: TextStyle(color: Color(0xff736E6D), fontSize: 18, fontFamily: "text"),),
            const SizedBox(height: 20,),
            Center(
              child: Container(
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(20))
                ),
                width: MediaQuery.of(context).size.width - 80,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Image.asset('assets/images/google.png')
                          // SvgPicture.asset('assets/images/openai_logo.jpg', fit: BoxFit.scaleDown,),
                        ),
                        const Expanded(
                          flex: 4,
                          child: Text('Sign in with Google', style: TextStyle(color: Color(0xff736E6D), fontSize: 16, fontFamily: "text"),),
                        ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [],
                          ),
                        ),
                      ],
                    ),
                  onPressed: () async {
                    bool? check = await userProvider.signInWithGoogle();

                    check! == false ?  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return GestureDetector(
                          onTap: () async {
                            Navigator.of(context).pop(); // AlertDialog 닫기
                            await userProvider.signOutGoogle();
                          },
                          child: AlertDialog(
                            title: Text('Consent to collect and use personal information and provide it to a third party', textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
                            content: Text('The clone function of this application is open source and therefore is protected by copyright and cannot be used for commercial use. Membership in this application allows you to view your email, name, and profile picture.', textAlign: TextAlign.center),
                            actionsAlignment: MainAxisAlignment.center,
                            actions: <Widget>[
                              TextButton(
                                child: Text('Agree', style: TextStyle(color: Colors.green)),
                                onPressed: () async {
                                  // Navigator.of(context).pop(); // AlertDialog 닫기
                                  await userProvider.signUp();
                                  const snackBar =  SnackBar(
                                    content: Text('회원가입 완료!'),
                                    duration: Duration(seconds: 2),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ButtonBarWidget()),);
                                },
                              ),
                              SizedBox(width: 10,),
                              TextButton(
                                child: Text('Disagree', style: TextStyle(color: Colors.green)),
                                onPressed: () async {
                                  Navigator.of(context).pop(); // AlertDialog 닫기
                                  await userProvider.signOutGoogle();
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    )
                    : null;


                    if (userProvider.user?.email != null && check == true){
                      // print('hiiiiiiiiiiiii${userProvider.user?.email}');
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ButtonBarWidget()),);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}