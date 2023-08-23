import 'package:chatgpt_course/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class profilePage extends StatefulWidget {
  const profilePage({Key? key}) : super(key: key);

  @override
  State<profilePage> createState() => _profilePageState();
}
class SliderController {
  double sliderValue;
  SliderController(this.sliderValue);
}

class _profilePageState extends State<profilePage> {
  final myController = TextEditingController();
  List<double> sliderValue = [1, 2, 3, 4, 5, 6,7,8,9];
  List<String> sliderValIndicators = ["level 1", "level 2", "level 3", "level 4","level 5", "level 6","level 7",
    "level 8","level 9"];
  // SliderController _firstSliderController = SliderController(0.0);

  late double currentEnglishValue;
  late double currentSpeakingValue;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentEnglishValue = Provider.of<UserProvider>(context, listen: false).myProfile!.englishLevel.toDouble();
    currentSpeakingValue = Provider.of<UserProvider>(context, listen: false).myProfile!.speakingLevel.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    bool edit = false;
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          title: const Text('User Profile',style: TextStyle(color: Colors.black),),
          backgroundColor: Colors.white,
        ),
        body: Container(
          child: Column(
            children: [
              SizedBox(height: 20,),
              Container(
                alignment: Alignment.topLeft,
                child:   Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 25),
                          child: Container(
                            width: MediaQuery.of(context).size.width / 2.5,
                            height: 130,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: NetworkImage(userProvider.myProfile!.profileImageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        )
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(top: 30, left: 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Name', style: TextStyle(fontSize: 15)),
                            const SizedBox(
                              height: 5,
                            ),
                            Container(
                              alignment: Alignment.topLeft,
                              width: 200,
                              // height: 100,
                              child: Text(
                                userProvider.myProfile!.name,
                                style: TextStyle(fontSize: 15),
                                overflow: TextOverflow.clip,
                                maxLines: 2,
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            const Text('Email', style: TextStyle(fontSize: 15)),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              userProvider.myProfile!.email,
                              style: TextStyle(fontSize: 14),
                              overflow: TextOverflow.clip,
                              maxLines: 2,
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(
                height: 20,
              ),
              Container(
                alignment: AlignmentDirectional.topStart,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: 25),
                        child: const Text('English Level'),
                      ),
                      Slider(
                        value: currentEnglishValue,
                        max: 10.0,
                        divisions: 10,
                        label: currentEnglishValue.round().toString(),
                        activeColor: Colors.green,
                        onChanged: (double value) {
                          setState(() {
                            currentEnglishValue = value;
                            edit = true;
                          }
                          );
                        },
                      ),
                      Container(
                        child:  Row(
                          children: [
                            Expanded(
                                child: Container(
                                  child: Text('Low'),
                                )
                            ),
                            Expanded(
                                child: Container(
                                  alignment: AlignmentDirectional.topEnd,
                                  child: Text('High'),
                                )
                            ),
                          ],
                        ),
                      )
                    ]
                ),
              ),
              SizedBox(height: 20,),
              Container(
                alignment: AlignmentDirectional.topStart,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(left: 25),
                        child: const Text('Speaking Level'),
                      ),
                      Slider(
                        value: currentSpeakingValue,
                        max: 10.0,
                        divisions: 10,
                        label: currentSpeakingValue.round().toString(),
                        activeColor: Colors.green,
                        onChanged: (double value) {
                          setState(() {
                            currentSpeakingValue = value +1;
                            edit = true;
                          }
                          );
                        },
                      ),
                      Container(
                        child:  Row(
                          children: [
                            Expanded(
                                child: Container(
                                  child: Text('Low'),
                                )
                            ),
                            Expanded(
                                child: Container(
                                  alignment: AlignmentDirectional.topEnd,
                                  child: Text('High'),
                                )
                            ),
                          ],
                        ),
                      )
                    ]
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                      onPressed: () async{
                        await FirebaseFirestore.instance
                            .collection('user')
                            .doc(FirebaseAuth.instance.currentUser!.email)
                            .update({'englishLevel' : currentEnglishValue, 'speakingLevel': currentSpeakingValue});
                        await userProvider.loadMyProfile();

                        const snackBar =  SnackBar(
                          content: Text('성공!'),
                          duration: Duration(seconds: 2),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      },
                      child: Text('save',style: TextStyle(color: Colors.green),)
                  ),
                  // SizedBox(width: 30,),
                  // TextButton(
                  //     onPressed: (){
                  //       userProvider.loadMyProfile();
                  //     },
                  //     child: Text('취소')
                  // ),
                ],
              ),
              SizedBox(height: 30,),
              Container(
                child: Text('Your English level is ${userProvider.myProfile.englishLevel}'),
              ),
              TextButton(
                  onPressed: () async{
                    await userProvider.signOutGoogle();

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                    );
                  },
                  child: const Text('Sign out',style: TextStyle(color: Colors.green),)
              )
            ],
          ),

        )
    );
  }
}