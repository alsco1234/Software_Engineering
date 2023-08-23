import 'dart:developer';

import 'package:chatgpt_course/providers/chats_provider.dart';
import 'package:chatgpt_course/widgets/chat_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../providers/models_provider.dart';
import '../widgets/text_widget.dart';
import 'package:text_to_speech/text_to_speech.dart';
import '../models/chat_model.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../providers/user_provider.dart';
import '../models/chat_model.dart';
import './chatFeedback_screen.dart';

class ChatHisoryScreen extends StatefulWidget {
  final String title;
  final List<ChatModel> chatList;

  const ChatHisoryScreen({
    Key? key,
    required this.chatList,
    required this.title,
  }) : super(key: key);

  @override
  State<ChatHisoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHisoryScreen> {

  @override
  void initState() {
    super.initState();
  }

  List<ChatModel> chatList = [];

  @override
  Widget build(BuildContext context) {
    final modelsProvider = Provider.of<ModelsProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    List<ChatModel> chatList = widget.chatList;

    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_outlined,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        centerTitle: true,
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(children: [
          Flexible(
            child: ListView.builder(
                itemCount: chatList.length, //chatList.length,
                itemBuilder: (context, index) {
                  return ChatWidget(
                    msg: chatList[index].msg, // chatList[index].msg,
                    chatIndex:
                        chatList[index].chatIndex, //chatList[index].chatIndex,
                    shouldAnimate: chatProvider.getChatList.length - 1 == index,
                  );
                }),
          ),
        ]),
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: FloatingActionButton.extended(
          backgroundColor: Colors.green,
          label: Container(
            alignment: Alignment.center,
            width: 150,
            child: Text('Feedback',style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold,)),
          ),
          onPressed: () async{

            List<ChatModel> feedbackList = [];

            for (int i = 0; i < chatList.length; i++) {
              if (chatList[i].role == 'user') {


                String feedbackResult = await chatProvider.sendMessageAndGetFeedbacks(
                  msg: chatList[i].msg,
                  chosenModelId: modelsProvider.getCurrentModel,
                );
                feedbackList.add(
                  ChatModel(role: 'user', msg: feedbackResult, chatIndex: chatList[i].chatIndex),
                );
              }
            }
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatFeedbackScreen(
                chatList: widget.chatList,
                title: widget.title,
                  feedbackList: feedbackList
              )),
            );
          },
        ),
      )
    );
  }
}
