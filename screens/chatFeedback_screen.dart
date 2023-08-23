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

class ChatFeedbackScreen extends StatefulWidget {
  final String title;
  final List<ChatModel> chatList;
  final List<ChatModel> feedbackList;

  const ChatFeedbackScreen({
    Key? key,
    required this.chatList,
    required this.title,
    required this.feedbackList,
  }) : super(key: key);

  @override
  State<ChatFeedbackScreen> createState() => _ChatFeedbackScreen();
}

class _ChatFeedbackScreen extends State<ChatFeedbackScreen> {
  get feedbackResult => null;

  @override
  void initState() {
    super.initState();
    print(feedbackResult);
    // feedbackList.add(ChatModel(role: 'user', msg: feedbackResult, chatIndex: 0));

  }

  List<ChatModel> chatList = [];

  @override
  Widget build(BuildContext context) {
    final modelsProvider = Provider.of<ModelsProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    List<ChatModel> feedbackList = widget.feedbackList;

    List<ChatModel> chatList = widget.chatList;

    // for (int i = 0; i < chatList.length; i++) {
    //   if (chatList[i].role == 'user') {
    //     String feedbackResult = (chatProvider.sendMessageAndGetFeedbacks(msg: chatList[i].msg, chosenModelId: modelsProvider.getCurrentModel)).toString();
    //     //String feedbackResult = await chatProvider.sendMessageAndGetFeedbacks(msg: chatList[i].msg, chosenModelId: modelsProvider.getCurrentModel);
    //     feedbackList.add(ChatModel(role: 'user', msg: feedbackResult, chatIndex: chatList[i].chatIndex));
    //   }
    // }
    //

    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        title: Text('Chat Feed back'),
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
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Column(children: [
          Flexible(
            child: ListView.builder(
                itemCount: feedbackList.length, //feedbackList.length,
                itemBuilder: (context, index) {
                  return ChatWidget(
                    msg: feedbackList[index].msg, // feedbackList[index].msg,
                    chatIndex: feedbackList[index].chatIndex, //feedbackList[index].chatIndex,
                    shouldAnimate: feedbackList.length - 1 == index,
                  );
                }),
          ),
        ]),
      ),
    );
  }
}
