import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:chatgpt_course/constants/api_consts.dart';
import 'package:chatgpt_course/models/chat_model.dart';
import '../models/messages_model.dart';
import 'package:chatgpt_course/models/models_model.dart';
import 'package:http/http.dart' as http;
import 'package:text_to_speech/text_to_speech.dart';

class ApiService {
  static Future<List<ModelsModel>> getModels() async {
    try {
      var response = await http.get(
        Uri.parse("$BASE_URL/models"),
        headers: {'Authorization': 'Bearer $API_KEY'},
      );

      Map jsonResponse = jsonDecode(response.body);

      if (jsonResponse['error'] != null) {
        // print("jsonResponse['error'] ${jsonResponse['error']["message"]}");
        throw HttpException(jsonResponse['error']["message"]);
      }
      // print("jsonResponse $jsonResponse");
      List temp = [];
      for (var value in jsonResponse["data"]) {
        temp.add(value);
        // log("temp ${value["id"]}");
      }
      return ModelsModel.modelsFromSnapshot(temp);
    } catch (error) {
      log("error $error");
      rethrow;
    }
  }

  /// Send Message using ChatGPT API (사용자가 GPT에게 메세지를 전달하는 함수)
  ///  - 파라미터
  /// msgList: 이전에 대화한 message list와 마지막에 모델에게 주는 요청을 msgList라는 list형태로 제공
  /// modelId: task에 사용되는 모델의 id
  static Future<List<ChatModel>> sendMessageGPT(
      {required List<Map<String, dynamic>> msgList, required String modelId, required int speakingLevel}) async {
    try {
      log("modelId $modelId");
      var response = await http.post(
        Uri.parse("$BASE_URL/chat/completions"),
        headers: {
          'Authorization': 'Bearer $API_KEY',
          "Content-Type": "application/json"
        },
        body: jsonEncode(
          {
            "model": modelId,
            "messages": msgList,
          },
        ),
      );
      print(msgList.toString());  // msg test용

      // Map jsonResponse = jsonDecode(response.body);
      Map jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      if (jsonResponse['error'] != null) {
        // print("jsonResponse['error'] ${jsonResponse['error']["message"]}");
        throw HttpException(jsonResponse['error']["message"]);
      }
      List<ChatModel> chatList = [];
      if (jsonResponse["choices"].length > 0) {
        // log("jsonResponse[choices]text ${jsonResponse["choices"][0]["text"]}");
        chatList = List.generate(
          jsonResponse["choices"].length,
              (index) => ChatModel(
            role: jsonResponse["choices"][index]["message"]["role"],
            msg: jsonResponse["choices"][index]["message"]["content"],
            chatIndex: 1,
          ),
        );
      }

      TextToSpeech tts = TextToSpeech();
      tts.setRate(speakingLevel/8 + 0.5);
      tts.speak(chatList[chatList.length - 1].msg);

      return chatList;
    } catch (error) {
      log("error $error");
      rethrow;
    }
  }

  static Future<String> sendFeedbackPromptGPT(
      {required String userMsg, required String modelId}) async {
    try {
      log("modelId $modelId");
      var response = await http.post(
        Uri.parse("$BASE_URL/chat/completions"),
        headers: {
          'Authorization': 'Bearer $API_KEY',
          "Content-Type": "application/json"
        },
        body: jsonEncode(
          {
            "model": modelId,
            "messages": [
              {'role': 'user', 'content': userMsg},
              {'role': 'assistant', 'content': 'Please correct the contents that come in order from the user to natural expressions in grammar and conversation, and make the revised sentence into one sentence in the form of "original sentence" -> "modified sentence", and if there are several revised sentences, please present only one of them.'}
            ],
          },
        ),
      );

      // Map jsonResponse = jsonDecode(response.body);
      Map jsonResponse = json.decode(utf8.decode(response.bodyBytes));
      if (jsonResponse['error'] != null) {
        throw HttpException(jsonResponse['error']["message"]);
      }
      String feedbackResult = '';
      if (jsonResponse["choices"].length > 0) {
        feedbackResult = '$userMsg\n->${jsonResponse["choices"][0]["message"]["content"]}';
      }

      return feedbackResult;
    } catch (error) {
      log("error $error");
      rethrow;
    }
  }

}
