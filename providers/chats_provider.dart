import 'package:flutter/cupertino.dart';

import '../models/chat_model.dart';
import '../models/messages_model.dart';
import '../services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:text_to_speech/text_to_speech.dart';
import 'user_provider.dart';

class ChatProvider with ChangeNotifier {
  List<ChatModel> chatList = [];
  List<ChatModel> get getChatList {
    return chatList;
  }

  List<Map<String, dynamic>> msgList = [];
  List<Map<String, dynamic>> get getMsgList {
    return msgList;
  }

  // List<Map<String, dynamic>> feedbackPromptMessage = [];

  TextToSpeech tts = TextToSpeech();

  // String language = 'en';
  // tts.setLanguage(language);

  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';

  String _onSpeechResult(SpeechRecognitionResult result) {
    _lastWords = result.recognizedWords;
    notifyListeners();
    return _lastWords;
  }

  bool Isspeaking(SpeechToText _speechToText) {
    return _speechToText.isNotListening;
  }

  void _stopListening() async {
    await _speechToText.stop();
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
  }

  /// This has to happen only once per app
  /// 해당 부분은 chatList 생성용 단발성 함수임
  void addUserMessage({required String msg}) {
    chatList.add(ChatModel(role: 'user', msg: msg, chatIndex: 0));
    notifyListeners();
  }

  /// 해당 함수는 쳇 시작시 한번만 적용됨
  void addStartPrompt(
      {required String systemPrompt, required String assistantPrompt}) {
    msgList.add(MessagesModel('system', systemPrompt).toJson());
    msgList.add(MessagesModel('assistant', assistantPrompt).toJson());
    notifyListeners();
  }

  /// 유저가 gpt모델에게 request를 보내고 그 결과를 받는 함수
  Future<void> sendMessageAndGetAnswers(
      {required String msg, required String chosenModelId, required int speakingLevel}) async {
    msgList.add(MessagesModel('user', msg).toJson());

    if (chosenModelId.toLowerCase().startsWith("gpt")) {
      chatList.addAll(await ApiService.sendMessageGPT(
        msgList: msgList,
        modelId: chosenModelId,
          speakingLevel: speakingLevel
      ));

      msgList.add(MessagesModel(chatList[chatList.length - 1].role,
          chatList[chatList.length - 1].msg).toJson());
    }

    notifyListeners();
  }

  /// 유저가 gpt모델에게 feedback request를 보내고 그 결과를 받는 함수
  Future<String> sendMessageAndGetFeedbacks(
      {required String msg, required String chosenModelId}) async {
    String feedbackResult = '';

    if (chosenModelId.toLowerCase().startsWith("gpt")) {
      feedbackResult = await ApiService.sendFeedbackPromptGPT(userMsg: msg, modelId: chosenModelId,
      );
    }

    // print('feedback result: $feedbackResult');
    return feedbackResult;
  }

  Future<void> saveChat(String title) async {
    DateTime date = DateTime.now();

    final chatHistoryCollection = FirebaseFirestore.instance
        .collection('user')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection('chatHistory').doc(
        date.microsecondsSinceEpoch.toString());

    await chatHistoryCollection.set(<String, dynamic>{
      'time': date.microsecondsSinceEpoch,
      'title': title
    });

    for (int i = 0; i < chatList.length; i++) {
      await chatHistoryCollection
          .collection('chat')
          .doc(i.toString())
          .set(<String, dynamic>{
        'role': chatList[i].role,
        'msg': chatList[i].msg,
        'chatIndex': chatList[i].chatIndex,
      });
    }
  }

  void clearChatList() {
    chatList.clear();
  }

  void clearMsgList() {
    msgList.clear();
  }
}
