import 'dart:developer';

import 'package:chatgpt_course/constants/constants.dart';
import 'package:chatgpt_course/providers/chats_provider.dart';
import 'package:chatgpt_course/services/services.dart';
import 'package:chatgpt_course/widgets/chat_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'test.dart';
import '../providers/models_provider.dart';
import '../services/assets_manager.dart';
import '../widgets/text_widget.dart';
import 'package:text_to_speech/text_to_speech.dart';
import '../providers/user_provider.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../models/category_model.dart';

class ChatScreen extends StatefulWidget {
  final CategoryModel chatInformation;
  const ChatScreen(
      {
        Key? key,
        required this.chatInformation,
      }): super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isTyping = false;

  late TextEditingController textEditingController;
  late ScrollController _listScrollController;
  late FocusNode focusNode;
  TextToSpeech tts = TextToSpeech();
  String language = 'en';

  @override
  void initState() {
    _listScrollController = ScrollController();
    textEditingController = TextEditingController();
    focusNode = FocusNode();
    super.initState();
    _initSpeech();
    _lastWords = '';
    tts.setLanguage(language);
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.


  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
    });
  }
  final formKey = GlobalKey<FormState>();

  /// 여기다가 preinput 추가하는 코드 작성하시면 됩니다.
  /// msg: 사용자 입력
  /// index == 0: user의 첫 입력
  /// return 값
  String addPreinput(String msg, int index){

    return msg;
  }

  // List<ChatModel> chatList = [];
  @override
  Widget build(BuildContext context) {
    final modelsProvider = Provider.of<ModelsProvider>(context);
    final chatProvider = Provider.of<ChatProvider>(context);
    final userProvider = Provider.of<UserProvider>(context,listen: false);
    /// Each time to start a speech recognition session
    int index = 0;
    int count = 0;
    final chatInformation = widget.chatInformation;
    void _stopListening() async {
      await _speechToText.stop();
      // setState(() async{
      //   await sendMessageVoiceFCT(
      //       modelsProvider: modelsProvider,
      //       chatProvider: chatProvider);
      // });
    }
    void _startListening() async {
      await _speechToText.listen(onResult: _onSpeechResult);
    }
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_outlined,color: Colors.black,),
            onPressed: (){
              Navigator.pop(context);
            },
          ),
        ),
        centerTitle: true,

        title: Text(widget.chatInformation.title, style: TextStyle(color: Colors.black),),
        actions: [
          IconButton(
            onPressed: () async {
              await Services.showModalSheet(context: context);
            },
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
          ),
          Padding(
              padding: const EdgeInsets.all(8.0),
              child:  InkWell(
                child: Container(
                  width: 50,
                  alignment: Alignment.center,
                  child: Text('end'),
                  decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle
                  ),
                ),
                onTap: (){
                  // chatProvider.
                  showDialog(
                      context: context,
                      barrierDismissible: true, // 바깥 영역 터치시 닫을지 여부
                      builder: (BuildContext context) {
                        return AlertDialog(
                          insetPadding: const  EdgeInsets.fromLTRB(0,80,0, 80),
                          alignment: Alignment.center,
                          actions: [
                            Align(
                              alignment: Alignment.center,
                              child: TextButton(
                                child: const Text('이 대화를 저장 하시겠습니까?',style: TextStyle(color: Colors.black),),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                    onPressed: () async{

                                      await chatProvider.saveChat(widget.chatInformation.title);
                                      chatProvider.clearChatList();
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                      userProvider.loadChatHistory();

                                      const snackBar =  SnackBar(
                                        content: Text('저장 완료!'),
                                        duration: Duration(seconds: 2),
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                    },
                                    child: Text('저장',style: TextStyle(color: Colors.black),)
                                ),
                                TextButton(
                                    onPressed: (){
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                      chatProvider.clearChatList();
                                    },
                                    child: Text('저장 안함',style: TextStyle(color: Colors.black),)
                                ),
                              ],
                            )
                          ],
                        );
                      }
                  );
                },
              )
          ),
        ],
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                  controller: _listScrollController,
                  itemCount: chatProvider.getChatList.length, //chatList.length,
                  itemBuilder: (context, index) {
                    return ChatWidget(
                      msg: chatProvider
                          .getChatList[index].msg, // chatList[index].msg,
                      chatIndex: chatProvider.getChatList[index]
                          .chatIndex, //chatList[index].chatIndex,
                      shouldAnimate:
                      chatProvider.getChatList.length -1 == index,
                    );
                  }),
            ),

            if (_isTyping) ...[
              const SpinKitThreeBounce(
                color: Colors.white,
                size: 18,
              ),
            ],
            const SizedBox(
              height: 15,
            ),
            Material(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Form(
                        key: formKey,
                        child:
                        TextFormField(
                          focusNode: focusNode,
                          style: const TextStyle(color: Colors.black),
                          controller: TextEditingController(
                            text:_lastWords,
                          ),
                          onSaved: (String? value) {
                            setState(() async{
                              _lastWords = value!;
                              //print("count: ");
                              //print(count);
                              if (chatProvider.msgList.isEmpty){
                                //print('pass isempty');
                                chatProvider.addStartPrompt(
                                    systemPrompt: "Can you play role-playing simulation? "
                                        "But please do not give me the full dialogue all at once. "
                                        "Say one sentence and wait for my response. "
                                        "And don't describe the situation, just print out the lines of the characters. "
                                        "The user's English is as good as ${chatInformation.userEnglishLevel *5
                                    } years old. "
                                        "Scenario: ${chatInformation.scenario}, Scenario description: ${chatInformation.description}",
                                    assistantPrompt: 'Your position is ${chatInformation.gptRole}.');
                              }

                              await sendMessageFCT(
                                modelsProvider: modelsProvider,
                                chatProvider: chatProvider,
                                index: index,
                                  speakingLevel: userProvider.myProfile.speakingLevel.toInt()
                              );
                              if (index < chatProvider.getChatList.length){
                                index +=1;
                              }
                            });
                          },
                          decoration: const InputDecoration.collapsed(
                              hintText: "How can I help you",
                              hintStyle: TextStyle(color: Colors.grey)),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _speechToText.isNotListening ? _startListening : _stopListening,
                      icon: Icon(Icons.mic,color: Colors.black),
                    ),

                    IconButton(
                        onPressed: () async {
                          formKey.currentState?.save();
                          print(_lastWords);
                          print('addStartPrompt');
                          await sendMessageFCT(
                            modelsProvider: modelsProvider,
                            chatProvider: chatProvider,
                            index: index,
                            speakingLevel: userProvider.myProfile.speakingLevel.toInt()
                          );
                          if (index < chatProvider.getChatList.length){
                            index +=1;
                          }
                        },
                        icon: const Icon(
                          Icons.send,
                          color: Colors.black,
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void scrollListToEND() {
    _listScrollController.animateTo(
        _listScrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 2),
        curve: Curves.easeOut);
  }



  Future<void> sendMessageFCT(
      {required ModelsProvider modelsProvider,
        required ChatProvider chatProvider, required int index, required int speakingLevel}) async {
    if (_isTyping) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: TextWidget(
            label: "You cant send multiple messages at a time",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_lastWords == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: TextWidget(
            label: "Please type a message",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    try {
      // String msg = _lastWords;
      // String role = 'user';
      String msg = addPreinput(_lastWords, index);
      setState(() {
        _isTyping = true;
        chatProvider.addUserMessage(msg: msg);
        textEditingController.clear();
        _lastWords = '';
        focusNode.unfocus();
      });
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      /// TODO : 쳇 생성 직후 유저가 한번 입력해줘야 회화가 시작됨. 쳇 생성하자말자 모델의 답번이 나온채로 시작하게끔 고쳐야됨.
      await chatProvider.sendMessageAndGetAnswers(
          msg: msg, chosenModelId: modelsProvider.getCurrentModel, speakingLevel: userProvider.myProfile.speakingLevel.toInt());

      setState(() {});
    } catch (error) {
      log("error $error");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: TextWidget(
          label: error.toString(),
        ),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        scrollListToEND();
        _isTyping = false;
      });
    }
  }
}
